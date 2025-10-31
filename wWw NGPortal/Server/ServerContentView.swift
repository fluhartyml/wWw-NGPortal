//
//  ServerContentView.swift
//  wWw NGPortal
//
//  Web server control and status display
//  2025-10-31 13:03 CDT
//

import SwiftUI

struct ServerContentView: View {
    @Environment(AppState.self) private var appState
    @State private var isServerRunning = false
    @State private var serverPort = "8080"
    @State private var currentIP = "Not detected"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Web Server")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Vapor-based web server control")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                
                // Server Status
                GroupBox("Server Status") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Status:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(isServerRunning ? "Running" : "Stopped")
                                .foregroundStyle(isServerRunning ? .green : .secondary)
                        }
                        
                        HStack {
                            Text("Port:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(serverPort)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Local IP:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(currentIP)
                                .foregroundStyle(.secondary)
                        }
                        
                        if isServerRunning {
                            HStack {
                                Text("URL:")
                                    .fontWeight(.medium)
                                Spacer()
                                Text("http://\(currentIP):\(serverPort)")
                                    .foregroundStyle(.blue)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Server Controls
                GroupBox("Server Controls") {
                    VStack(spacing: 16) {
                        HStack {
                            TextField("Port", text: $serverPort)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                                .disabled(isServerRunning)
                            
                            Text("Server Port")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        
                        Button(action: toggleServer) {
                            HStack {
                                Image(systemName: isServerRunning ? "stop.fill" : "play.fill")
                                Text(isServerRunning ? "Stop Server" : "Start Server")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    @MainActor
    private func toggleServer() {
        isServerRunning.toggle()
        
        if isServerRunning {
            appState.addDebugMessage("Starting web server on port \(serverPort)", type: .info)
            detectCurrentIP()
            // TODO: Actually start Vapor server
            appState.addDebugMessage("Web server started successfully", type: .success)
        } else {
            appState.addDebugMessage("Stopping web server", type: .info)
            // TODO: Actually stop Vapor server
            appState.addDebugMessage("Web server stopped", type: .info)
        }
    }
    
    private func detectCurrentIP() {
        // TODO: Implement actual IP detection
        currentIP = "192.168.1.100"
    }
}

#Preview {
    ServerContentView()
        .environment(AppState())
        .frame(width: 600, height: 600)
}
