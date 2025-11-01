//
//  DDNSContentView.swift
//  wWw NGPortal
//
//  DuckDNS configuration and status display with persistent settings
//  2025-10-31 19:17 CDT
//

import SwiftUI

struct DDNSContentView: View {
    @Environment(AppState.self) private var appState
    @State private var isEnabled = false
    @State private var domain = ""
    @State private var token = ""
    @State private var updateInterval = 5
    @State private var lastUpdate = "Never"
    @State private var currentIP = "Not detected"
    @State private var lastStatus = "Idle"
    
    // UserDefaults keys
    private let enabledKey = "ddns.enabled"
    private let domainKey = "ddns.domain"
    private let tokenKey = "ddns.token"
    private let intervalKey = "ddns.interval"
    private let lastUpdateKey = "ddns.lastUpdate"
    private let currentIPKey = "ddns.currentIP"
    private let lastStatusKey = "ddns.lastStatus"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dynamic DNS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Keep your domain pointed to your current IP address")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // DDNS Status
                GroupBox("Status") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Service:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(isEnabled ? "Enabled" : "Disabled")
                                .foregroundStyle(isEnabled ? .green : .secondary)
                        }
                        
                        HStack {
                            Text("Current IP:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(currentIP)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Last Update:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(lastUpdate)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Status:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(lastStatus)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // DDNS Configuration
                GroupBox("DuckDNS Configuration") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Domain
                        HStack {
                            Text("Subdomain:")
                                .frame(width: 100, alignment: .leading)
                            
                            TextField("myhouse", text: $domain)
                                .textFieldStyle(.roundedBorder)
                                .disabled(isEnabled)
                                .onChange(of: domain) { _, newValue in
                                    saveSettings()
                                }
                            
                            Text(".duckdns.org")
                                .foregroundStyle(.secondary)
                        }
                        
                        // Token/Password
                        HStack {
                            Text("Token:")
                                .frame(width: 100, alignment: .leading)
                            
                            SecureField("API Token", text: $token)
                                .textFieldStyle(.roundedBorder)
                                .disabled(isEnabled)
                                .onChange(of: token) { _, newValue in
                                    saveSettings()
                                }
                        }
                        
                        // Update Interval
                        HStack {
                            Text("Update Every:")
                                .frame(width: 100, alignment: .leading)
                            
                            Picker("", selection: $updateInterval) {
                                Text("5 minutes").tag(5)
                                Text("10 minutes").tag(10)
                                Text("15 minutes").tag(15)
                                Text("30 minutes").tag(30)
                            }
                            .labelsHidden()
                            .disabled(isEnabled)
                            .onChange(of: updateInterval) { _, newValue in
                                saveSettings()
                            }
                        }
                        
                        // Enable/Disable Button
                        Button(action: toggleDDNS) {
                            HStack {
                                Image(systemName: isEnabled ? "stop.fill" : "play.fill")
                                Text(isEnabled ? "Disable DDNS" : "Enable DDNS")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(domain.isEmpty || token.isEmpty)
                        
                        if !isEnabled && (domain.isEmpty || token.isEmpty) {
                            Text("Please configure domain and token to enable DDNS")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
            }
            .padding(24)
        }
        .onAppear {
            loadSettings()
        }
    }
    
    // MARK: - Persistence Methods
    
    private func saveSettings() {
        UserDefaults.standard.set(isEnabled, forKey: enabledKey)
        UserDefaults.standard.set(domain, forKey: domainKey)
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(updateInterval, forKey: intervalKey)
        UserDefaults.standard.set(lastUpdate, forKey: lastUpdateKey)
        UserDefaults.standard.set(currentIP, forKey: currentIPKey)
        UserDefaults.standard.set(lastStatus, forKey: lastStatusKey)
    }
    
    private func loadSettings() {
        isEnabled = UserDefaults.standard.bool(forKey: enabledKey)
        domain = UserDefaults.standard.string(forKey: domainKey) ?? ""
        token = UserDefaults.standard.string(forKey: tokenKey) ?? ""
        updateInterval = UserDefaults.standard.integer(forKey: intervalKey) != 0 ?
            UserDefaults.standard.integer(forKey: intervalKey) : 5
        lastUpdate = UserDefaults.standard.string(forKey: lastUpdateKey) ?? "Never"
        currentIP = UserDefaults.standard.string(forKey: currentIPKey) ?? "Not detected"
        lastStatus = UserDefaults.standard.string(forKey: lastStatusKey) ?? "Idle"
        
        // If was enabled when app closed, restart DDNS
        if isEnabled && !domain.isEmpty && !token.isEmpty {
            appState.addDebugMessage("Restoring DDNS service for \(domain)", type: .info)
            detectCurrentIP()
            performUpdate()
        }
    }
    
    // MARK: - DDNS Methods
    
    @MainActor
    private func toggleDDNS() {
        isEnabled.toggle()
        saveSettings()
        
        if isEnabled {
            appState.addDebugMessage("Starting DDNS updates for \(domain)", type: .info)
            detectCurrentIP()
            performUpdate()
            // TODO: Start periodic updates
        } else {
            appState.addDebugMessage("Stopping DDNS updates", type: .info)
            lastStatus = "Disabled"
            saveSettings()
            // TODO: Stop periodic updates
        }
    }
    
    private func detectCurrentIP() {
        // TODO: Implement actual IP detection
        currentIP = "203.0.113.42"
        saveSettings()
    }
    
    @MainActor
    private func performUpdate() {
        appState.addDebugMessage("Updating DDNS record for \(domain)", type: .info)
        // TODO: Implement actual DDNS update
        lastUpdate = Date().formatted(date: .abbreviated, time: .shortened)
        lastStatus = "Success"
        saveSettings()
        appState.addDebugMessage("DDNS update successful", type: .success)
    }
}

#Preview {
    DDNSContentView()
        .environment(AppState())
        .frame(width: 600, height: 700)
}
