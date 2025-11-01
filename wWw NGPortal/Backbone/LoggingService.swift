//
//  LoggingService.swift
//  wWw NGPortal
//
//  Comprehensive logging system with rotation and expiration
//  2025-11-01 13:14 CDT
//

import Foundation
import Combine

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARN"
    case error = "ERROR"
}

enum LogCategory: String {
    case server = "server"
    case ddns = "ddns"
    case system = "system"
    case debug = "debug"
}

@MainActor
class LoggingService {
    static let shared = LoggingService()

    private var logsDirectory: URL?
    private let maxLogSize: Int64 = 10_000_000 // 10MB
    private let maxArchivedLogs = 10
    private let fileManager = FileManager.default

    // Settings
    var logExpirationDays: Int = 30 {
        didSet {
            Task {
                await cleanExpiredLogs()
            }
        }
    }

    private init() {}

    /// Initialize logging service with nightgard root directory
    func initialize(nightgardRoot: URL) {
        let logsDir = nightgardRoot.appendingPathComponent("logs")

        // Create logs directory if needed
        try? fileManager.createDirectory(at: logsDir, withIntermediateDirectories: true)

        self.logsDirectory = logsDir

        // Log initialization
        log("Logging service initialized at: \(logsDir.path)", category: .system, level: .info)
    }

    /// Main logging function - source of truth
    func log(_ message: String, category: LogCategory, level: LogLevel) {
        guard let logsDirectory = logsDirectory else {
            print("[LoggingService] Not initialized - cannot log: \(message)")
            return
        }

        // Format: 2025 NOV 01 1314
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMM dd HHmm"
        formatter.locale = Locale(identifier: "en_US")
        let timestamp = formatter.string(from: Date()).uppercased()
        let logEntry = "[\(timestamp)] [\(level.rawValue)] \(message)\n"

        let logFile = logsDirectory.appendingPathComponent("\(category.rawValue).log")

        // Check if rotation needed
        rotateIfNeeded(logFile: logFile)

        // Append to log file
        if let data = logEntry.data(using: .utf8) {
            if fileManager.fileExists(atPath: logFile.path) {
                // Append to existing file
                if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    try? fileHandle.close()
                }
            } else {
                // Create new file
                try? data.write(to: logFile)
            }
        }

        // Also print to console during development
        print("[\(category.rawValue.uppercased())] [\(level.rawValue)] \(message)")
    }

    /// Rotate log file if it exceeds max size
    private func rotateIfNeeded(logFile: URL) {
        guard let attributes = try? fileManager.attributesOfItem(atPath: logFile.path),
              let fileSize = attributes[.size] as? Int64,
              fileSize >= maxLogSize else {
            return
        }

        // Rotate existing archived logs (server.log.9 -> server.log.10, etc.)
        for i in stride(from: maxArchivedLogs - 1, through: 1, by: -1) {
            let oldArchive = logFile.appendingPathExtension("\(i)")
            let newArchive = logFile.appendingPathExtension("\(i + 1)")

            if fileManager.fileExists(atPath: oldArchive.path) {
                try? fileManager.removeItem(at: newArchive) // Remove if exists
                try? fileManager.moveItem(at: oldArchive, to: newArchive)
            }
        }

        // Rotate current log to .1
        let firstArchive = logFile.appendingPathExtension("1")
        try? fileManager.removeItem(at: firstArchive) // Remove if exists
        try? fileManager.moveItem(at: logFile, to: firstArchive)

        log("Log rotated: \(logFile.lastPathComponent)", category: .system, level: .info)
    }

    /// Clean logs older than expiration setting
    func cleanExpiredLogs() async {
        guard let logsDirectory = logsDirectory else { return }

        let expirationDate = Calendar.current.date(byAdding: .day, value: -logExpirationDays, to: Date()) ?? Date()

        guard let files = try? fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }

        var deletedCount = 0

        for file in files {
            // Only process archived logs (*.log.1, *.log.2, etc.)
            guard file.pathExtension.allSatisfy({ $0.isNumber }) else { continue }

            if let attributes = try? fileManager.attributesOfItem(atPath: file.path),
               let creationDate = attributes[.creationDate] as? Date,
               creationDate < expirationDate {
                try? fileManager.removeItem(at: file)
                deletedCount += 1
            }
        }

        if deletedCount > 0 {
            log("Cleaned \(deletedCount) expired log files", category: .system, level: .info)
        }
    }

    /// Get current log file sizes
    func getLogSizes() -> [String: String] {
        guard let logsDirectory = logsDirectory else { return [:] }

        var sizes: [String: String] = [:]

        for category in [LogCategory.server, .ddns, .system, .debug] {
            let logFile = logsDirectory.appendingPathComponent("\(category.rawValue).log")

            if let attributes = try? fileManager.attributesOfItem(atPath: logFile.path),
               let fileSize = attributes[.size] as? Int64 {
                sizes[category.rawValue] = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
            } else {
                sizes[category.rawValue] = "0 bytes"
            }
        }

        return sizes
    }

    /// Get logs directory URL for user access
    func getLogsDirectory() -> URL? {
        return logsDirectory
    }

    /// Manually clear all archived logs (keeps current .log files)
    func clearArchivedLogs() {
        guard let logsDirectory = logsDirectory else { return }

        guard let files = try? fileManager.contentsOfDirectory(at: logsDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        var deletedCount = 0

        for file in files {
            // Only delete archived logs (*.log.1, *.log.2, etc.)
            if file.pathExtension.allSatisfy({ $0.isNumber }) {
                try? fileManager.removeItem(at: file)
                deletedCount += 1
            }
        }

        log("Manually cleared \(deletedCount) archived log files", category: .system, level: .info)
    }
}

// MARK: - Convenience logging functions

extension LoggingService {
    func debug(_ message: String, category: LogCategory = .debug) {
        log(message, category: category, level: .debug)
    }

    func info(_ message: String, category: LogCategory = .system) {
        log(message, category: category, level: .info)
    }

    func warning(_ message: String, category: LogCategory = .system) {
        log(message, category: category, level: .warning)
    }

    func error(_ message: String, category: LogCategory = .system) {
        log(message, category: category, level: .error)
    }
}
