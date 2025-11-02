//
//  ConfigurationContentView.swift
//  wWw NGPortal
//
//  Configuration panel for nightgard file structure and settings
//  2025-11-01 15:01 CDT
//

import SwiftUI
import AppKit

struct ConfigurationContentView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedAppearanceMode: AppearanceMode = .dark
    @State private var fileStructure = NightgardFileStructure.shared
    @State private var logExpirationDays = 30
    @State private var showingFolderPicker = false
    @State private var showingConfirmationDialog = false
    @State private var selectedFolder: URL?
    @State private var foldersToCreate: [String] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Configuration")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Nightgard file structure and system settings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Nightgard Root Location
                GroupBox("Nightgard Root Location") {
                    VStack(alignment: .leading, spacing: 12) {
                        if fileStructure.isConfigured, let root = fileStructure.nightgardRoot {
                            HStack {
                                Text("Current Location:")
                                    .fontWeight(.medium)
                                Spacer()
                            }

                            Text(root.path)
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .textSelection(.enabled)

                            HStack(spacing: 12) {
                                Button("Choose Different Folder...") {
                                    chooseFolderDialog()
                                }
                                .buttonStyle(.bordered)

                                Button("Open in Finder") {
                                    NSWorkspace.shared.open(root)
                                }
                                .buttonStyle(.bordered)
                            }
                        } else {
                            Text("No nightgard installation configured")
                                .foregroundStyle(.secondary)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Default location: ~/Nightgard.root/")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                HStack(spacing: 12) {
                                    Button("Initialize Default Location") {
                                        initializeDefault()
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Choose Custom Location...") {
                                        chooseFolderDialog()
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Appearance Settings
                GroupBox("Appearance") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Theme:")
                                .fontWeight(.medium)

                            Picker("", selection: $selectedAppearanceMode) {
                                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                            .onChange(of: selectedAppearanceMode) { _, newValue in
                                appState.appearanceMode = newValue
                                appState.addDebugMessage("Appearance mode changed to \(newValue.rawValue)", type: .info)
                            }

                            Spacer()
                        }

                        Text("Choose between Light or Dark mode for the application appearance.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                }

                // Logging Settings
                if fileStructure.isConfigured {
                    GroupBox("Logging Settings") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Log Expiration:")
                                    .fontWeight(.medium)

                                Picker("", selection: $logExpirationDays) {
                                    Text("7 days").tag(7)
                                    Text("30 days").tag(30)
                                    Text("60 days").tag(60)
                                    Text("90 days").tag(90)
                                }
                                .pickerStyle(.menu)
                                .frame(width: 120)
                                .onChange(of: logExpirationDays) { _, newValue in
                                    updateLogExpiration(newValue)
                                }

                                Spacer()
                            }

                            Divider()

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Log File Sizes:")
                                    .fontWeight(.medium)

                                let logSizes = LoggingService.shared.getLogSizes()
                                ForEach(Array(logSizes.keys.sorted()), id: \.self) { key in
                                    HStack {
                                        Text("\(key).log")
                                            .font(.system(.body, design: .monospaced))
                                        Spacer()
                                        Text(logSizes[key] ?? "0 bytes")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }

                            Divider()

                            HStack(spacing: 12) {
                                if let logsDir = LoggingService.shared.getLogsDirectory() {
                                    Button("Open Logs Folder") {
                                        NSWorkspace.shared.open(logsDir)
                                    }
                                    .buttonStyle(.bordered)
                                }

                                Button("Clear Archived Logs") {
                                    LoggingService.shared.clearArchivedLogs()
                                    appState.addDebugMessage("Archived logs cleared", type: .info)
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .alert("Create Nightgard Structure?", isPresented: $showingConfirmationDialog) {
            Button("Cancel", role: .cancel) {
                selectedFolder = nil
                foldersToCreate = []
            }
            Button("Create") {
                confirmFolderCreation()
            }
        } message: {
            if let folder = selectedFolder {
                Text("""
                This folder doesn't contain nightgard structure.

                The following folders will be created at:
                \(folder.path)

                \(foldersToCreate.map { "• \($0)/" }.joined(separator: "\n"))
                """)
            }
        }
        .onAppear {
            loadConfiguration()
        }
    }

    // MARK: - Actions

    private func loadConfiguration() {
        if let config = fileStructure.getCurrentConfig() {
            logExpirationDays = config.logExpirationDays
        }
        selectedAppearanceMode = appState.appearanceMode
    }

    private func initializeDefault() {
        Task {
            do {
                try await fileStructure.initializeDefault()
                appState.addDebugMessage("Nightgard initialized at default location", type: .success)
            } catch {
                appState.addDebugMessage("Failed to initialize: \(error.localizedDescription)", type: .error)
            }
        }
    }

    private func chooseFolderDialog() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Choose or create a folder for Nightgard"

        panel.begin { response in
            if response == .OK, let url = panel.url {
                handleFolderSelection(url)
            }
        }
    }

    private func handleFolderSelection(_ url: URL) {
        let hasStructure = fileStructure.checkNightgardStructure(at: url)

        if hasStructure {
            // Existing structure found, use it directly
            Task {
                do {
                    try await fileStructure.setCustomLocation(url)
                    appState.addDebugMessage("Using existing nightgard installation at \(url.path)", type: .success)
                } catch {
                    appState.addDebugMessage("Failed to set location: \(error.localizedDescription)", type: .error)
                }
            }
        } else {
            // Need to create structure, show confirmation dialog
            selectedFolder = url
            foldersToCreate = fileStructure.getFoldersToCreate(at: url)
            showingConfirmationDialog = true
        }
    }

    private func confirmFolderCreation() {
        guard let folder = selectedFolder else { return }

        Task {
            do {
                try await fileStructure.createNightgardStructure(at: folder)
                try await fileStructure.setCustomLocation(folder)
                appState.addDebugMessage("Nightgard structure created at \(folder.path)", type: .success)
            } catch {
                appState.addDebugMessage("Failed to create structure: \(error.localizedDescription)", type: .error)
            }

            selectedFolder = nil
            foldersToCreate = []
        }
    }

    private func updateLogExpiration(_ days: Int) {
        do {
            try fileStructure.updateConfig(logExpirationDays: days)
            LoggingService.shared.logExpirationDays = days
            appState.addDebugMessage("Log expiration updated to \(days) days", type: .info)
        } catch {
            appState.addDebugMessage("Failed to update config: \(error.localizedDescription)", type: .error)
        }
    }
}

#Preview {
    ConfigurationContentView()
        .environment(AppState())
        .frame(width: 600, height: 600)
}
