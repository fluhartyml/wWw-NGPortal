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
    @State private var vaporServer = VaporServer()
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
                            Text(vaporServer.isRunning ? "Running" : "Stopped")
                                .foregroundStyle(vaporServer.isRunning ? .green : .secondary)
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
                        
                        if vaporServer.isRunning {
                            HStack {
                                Text("URL:")
                                    .fontWeight(.medium)
                                Spacer()
                                if let url = URL(string: "http://\(currentIP):\(serverPort)") {
                                    Link("http://\(currentIP):\(serverPort)", destination: url)
                                        .foregroundStyle(.blue)
                                }
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
                                .disabled(vaporServer.isRunning)
                            
                            Text("Server Port")
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        
                        Button(action: toggleServer) {
                            HStack {
                                Image(systemName: vaporServer.isRunning ? "stop.fill" : "play.fill")
                                Text(vaporServer.isRunning ? "Stop Server" : "Start Server")
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
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onAppear {
            vaporServer.setAppState(appState)
            detectCurrentIP()
        }
    }

    @MainActor
    private func toggleServer() {
        Task {
            if vaporServer.isRunning {
                // Stop server
                await vaporServer.stop()
            } else {
                // Start server
                guard let port = Int(serverPort) else {
                    appState.addDebugMessage("Invalid port number: \(serverPort)", type: .error)
                    return
                }

                detectCurrentIP()

                do {
                    try await vaporServer.start(on: port)
                    appState.addDebugMessage("Server accessible at http://\(currentIP):\(port)", type: .info)
                } catch {
                    // Error already logged by VaporServer
                }
            }
        }
    }
    
    private func detectCurrentIP() {
        // Detect local IP address
        var address: String = "Not detected"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family

                if addrFamily == UInt8(AF_INET) {
                    let name = String(cString: (interface?.ifa_name)!)

                    // Check for en0 (Ethernet) or en1 (Wi-Fi)
                    if name == "en0" || name == "en1" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!),
                                  &hostname, socklen_t(hostname.count),
                                  nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                        break
                    }
                }
            }
            freeifaddrs(ifaddr)
        }

        currentIP = address
    }
}

#Preview {
    ServerContentView()
        .environment(AppState())
        .frame(width: 600, height: 600)
}
