//
//  NightgardFileStructure.swift
//  wWw NGPortal
//
//  Manages nightgard folder structure and configuration
//  2025-11-01 14:09 CDT
//

import Foundation
import SwiftUI
import Combine

struct NightgardConfig: Codable {
    var nightgardRootPath: String
    var logExpirationDays: Int
    var serverPort: Int
    var lastModified: String

    static var defaultPort: Int = 8080
    static var defaultLogExpiration: Int = 30
}

@MainActor
class NightgardFileStructure: ObservableObject {
    static let shared = NightgardFileStructure()

    @Published var nightgardRoot: URL?
    @Published var isConfigured: Bool = false

    private let fileManager = FileManager.default
    private let requiredFolders = ["public", "config", "logs"]

    // Default location for new installations
    private var defaultLocation: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Nightgard.root")
    }

    private init() {
        loadConfiguration()
    }

    /// Load saved configuration on app launch
    func loadConfiguration() {
        // Try to load from UserDefaults first (bootstrap path)
        if let savedPath = UserDefaults.standard.string(forKey: "nightgardRootPath"),
           let savedURL = URL(string: savedPath),
           fileManager.fileExists(atPath: savedURL.path) {

            // Try to load full config from JSON
            let configURL = savedURL.appendingPathComponent("config/app-config.json")
            if let config = loadConfigJSON(from: configURL) {
                self.nightgardRoot = URL(fileURLWithPath: config.nightgardRootPath)
                self.isConfigured = true
                LoggingService.shared.initialize(nightgardRoot: self.nightgardRoot!)
            }
        }
    }

    /// Initialize with default location (first launch)
    func initializeDefault() async throws {
        let location = defaultLocation
        try await createNightgardStructure(at: location)
        try saveConfiguration(rootPath: location)

        self.nightgardRoot = location
        self.isConfigured = true
        LoggingService.shared.initialize(nightgardRoot: location)
    }

    /// Set custom nightgard root location
    func setCustomLocation(_ url: URL) async throws {
        // Check if nightgard structure exists
        let hasStructure = checkNightgardStructure(at: url)

        if !hasStructure {
            // Will need user confirmation before creating
            throw NightgardError.needsUserConfirmation
        }

        try saveConfiguration(rootPath: url)
        self.nightgardRoot = url
        self.isConfigured = true
        LoggingService.shared.initialize(nightgardRoot: url)
    }

    /// Create nightgard structure at location (after user confirms)
    func createNightgardStructure(at location: URL) async throws {
        // Create root if needed
        if !fileManager.fileExists(atPath: location.path) {
            try fileManager.createDirectory(at: location, withIntermediateDirectories: true)
        }

        // Create required subfolders
        for folder in requiredFolders {
            let folderURL = location.appendingPathComponent(folder)
            if !fileManager.fileExists(atPath: folderURL.path) {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
        }

        // Create default index.html in public folder
        let publicFolder = location.appendingPathComponent("public")
        let indexFile = publicFolder.appendingPathComponent("index.html")

        if !fileManager.fileExists(atPath: indexFile.path) {
            let defaultHTML = createDefaultIndexHTML()
            try defaultHTML.write(to: indexFile, atomically: true, encoding: .utf8)
        }
    }

    /// Check if location has nightgard structure
    func checkNightgardStructure(at location: URL) -> Bool {
        for folder in requiredFolders {
            let folderURL = location.appendingPathComponent(folder)
            var isDirectory: ObjCBool = false

            if !fileManager.fileExists(atPath: folderURL.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
                return false
            }
        }
        return true
    }

    /// Get list of folders that will be created (for user confirmation dialog)
    func getFoldersToCreate(at location: URL) -> [String] {
        var missingFolders: [String] = []

        for folder in requiredFolders {
            let folderURL = location.appendingPathComponent(folder)
            if !fileManager.fileExists(atPath: folderURL.path) {
                missingFolders.append(folder)
            }
        }

        return missingFolders
    }

    /// Save configuration to JSON file
    private func saveConfiguration(rootPath: URL) throws {
        let configDir = rootPath.appendingPathComponent("config")
        let configFile = configDir.appendingPathComponent("app-config.json")

        // Create config directory if needed
        if !fileManager.fileExists(atPath: configDir.path) {
            try fileManager.createDirectory(at: configDir, withIntermediateDirectories: true)
        }

        // Create configuration
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM dd HHmm"
        formatter.locale = Locale(identifier: "en_US")
        let timestamp = formatter.string(from: Date()).uppercased()

        let config = NightgardConfig(
            nightgardRootPath: rootPath.path,
            logExpirationDays: NightgardConfig.defaultLogExpiration,
            serverPort: NightgardConfig.defaultPort,
            lastModified: timestamp
        )

        // Write to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(config)
        try jsonData.write(to: configFile)

        // Also save to UserDefaults as bootstrap
        UserDefaults.standard.set(rootPath.absoluteString, forKey: "nightgardRootPath")
    }

    /// Load configuration from JSON file
    private func loadConfigJSON(from url: URL) -> NightgardConfig? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(NightgardConfig.self, from: data)
    }

    /// Update specific config value and save
    func updateConfig(logExpirationDays: Int? = nil, serverPort: Int? = nil) throws {
        guard let nightgardRoot = nightgardRoot else { return }

        let configFile = nightgardRoot.appendingPathComponent("config/app-config.json")
        guard var config = loadConfigJSON(from: configFile) else { return }

        // Update values
        if let expiration = logExpirationDays {
            config.logExpirationDays = expiration
        }
        if let port = serverPort {
            config.serverPort = port
        }

        // Update timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM dd HHmm"
        formatter.locale = Locale(identifier: "en_US")
        config.lastModified = formatter.string(from: Date()).uppercased()

        // Save
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let jsonData = try encoder.encode(config)
        try jsonData.write(to: configFile)
    }

    /// Get current config
    func getCurrentConfig() -> NightgardConfig? {
        guard let nightgardRoot = nightgardRoot else { return nil }
        let configFile = nightgardRoot.appendingPathComponent("config/app-config.json")
        return loadConfigJSON(from: configFile)
    }

    /// Create default index.html for public folder
    private func createDefaultIndexHTML() -> String {
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Nightgard Portal</title>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                    max-width: 800px;
                    margin: 50px auto;
                    padding: 20px;
                    background: #f5f5f7;
                }
                h1 { color: #1d1d1f; }
                .info {
                    background: white;
                    padding: 20px;
                    border-radius: 10px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                }
            </style>
        </head>
        <body>
            <h1>Welcome to Nightgard Portal</h1>
            <div class="info">
                <p>Your intranet portal is now running.</p>
                <p>To customize this page, edit: <code>public/index.html</code></p>
            </div>
        </body>
        </html>
        """
    }
}

// MARK: - Errors

enum NightgardError: Error {
    case needsUserConfirmation
    case invalidLocation
    case configurationFailed
}
