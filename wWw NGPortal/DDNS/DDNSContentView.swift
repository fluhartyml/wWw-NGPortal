//
//  DDNSContentView.swift
//  wWw NGPortal
//
//  DDNS configuration and status display
//  2025-10-31 13:05 CDT
//

import SwiftUI

struct DDNSContentView: View {
    @Environment(AppState.self) private var appState
    @State private var isEnabled = false
    @State private var provider = DDNSProvider.duckDNS
    @State private var domain = ""
    @State private var token = ""
    @State private var updateInterval = 5
    @State private var lastUpdate = "Never"
    @State private var currentIP = "Not detected"
    @State private var lastStatus = "Idle"
    
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
                GroupBox("Configuration") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Provider Selection
                        HStack {
                            Text("Provider:")
                                .frame(width: 100, alignment: .leading)
                            
                            Picker("", selection: $provider) {
                                ForEach(DDNSProvider.allCases, id: \.self) { provider in
                                    Text(provider.rawValue).tag(provider)
                                }
                            }
                            .labelsHidden()
                            .disabled(isEnabled)
                        }
                        
                        // Domain
                        HStack {
                            Text("Domain:")
                                .frame(width: 100, alignment: .leading)
                            
                            TextField("example.duckdns.org", text: $domain)
                                .textFieldStyle(.roundedBorder)
                                .disabled(isEnabled)
                        }
                        
                        // Token/Password
                        HStack {
                            Text("Token:")
                                .frame(width: 100, alignment: .leading)
                            
                            SecureField("API Token", text: $token)
                                .textFieldStyle(.roundedBorder)
                                .disabled(isEnabled)
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
    }
    
    @MainActor
    private func toggleDDNS() {
        isEnabled.toggle()
        
        if isEnabled {
            appState.addDebugMessage("Starting DDNS updates for \(domain)", type: .info)
            detectCurrentIP()
            performUpdate()
            // TODO: Start periodic updates
        } else {
            appState.addDebugMessage("Stopping DDNS updates", type: .info)
            lastStatus = "Disabled"
            // TODO: Stop periodic updates
        }
    }
    
    private func detectCurrentIP() {
        // TODO: Implement actual IP detection
        currentIP = "203.0.113.42"
    }
    
    @MainActor
    private func performUpdate() {
        appState.addDebugMessage("Updating DDNS record for \(domain)", type: .info)
        // TODO: Implement actual DDNS update
        lastUpdate = Date().formatted(date: .abbreviated, time: .shortened)
        lastStatus = "Success"
        appState.addDebugMessage("DDNS update successful", type: .success)
    }
}

enum DDNSProvider: String, CaseIterable {
    case duckDNS = "DuckDNS"
    case noIP = "No-IP"
    case dynu = "Dynu"
    case cloudflare = "Cloudflare"
}

#Preview {
    DDNSContentView()
        .environment(AppState())
        .frame(width: 600, height: 700)
}
