//
//  NavigationPanel.swift
//  wWw NGPortal
//
//  Created by Michael Fluharty on 10/31/25.
//


//
//  NavigationPanel.swift
//  wWw NGPortal
//
//  Navigation panel with feature selection buttons
//  2025-10-31 12:56 CDT
//

import SwiftUI

struct NavigationPanel: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        VStack(spacing: 0) {
            // Branded Header
            VStack(spacing: 4) {
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 2)

                Text("wWw NGPortal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text("NightGard Server")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.05),
                        Color.clear
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            Divider()

            // Feature Selection Buttons
            VStack(spacing: 1) {
                NavigationButton(
                    title: "WEB Server",
                    icon: "server.rack",
                    isSelected: appState.selectedFeature == .webServer
                ) {
                    appState.selectedFeature = .webServer
                }

                NavigationButton(
                    title: "DDNS",
                    icon: "network",
                    isSelected: appState.selectedFeature == .ddns
                ) {
                    appState.selectedFeature = .ddns
                }

                NavigationButton(
                    title: "Configuration",
                    icon: "gearshape.2",
                    isSelected: appState.selectedFeature == .configuration
                ) {
                    appState.selectedFeature = .configuration
                }
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Feature-specific controls appear here
            ScrollView {
                switch appState.selectedFeature {
                case .webServer:
                    ServerControlsPanel()
                case .ddns:
                    DDNSControlsPanel()
                case .configuration:
                    ConfigurationControlsPanel()
                }
            }
            
            Spacer()
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct NavigationButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .imageScale(.medium)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 13))
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// Temporary placeholder panels
struct ServerControlsPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Server Controls")
                .font(.headline)
                .padding()
            
            // TODO: Add server-specific controls
        }
    }
}

struct DDNSControlsPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DDNS Controls")
                .font(.headline)
                .padding()

            // TODO: Add DDNS-specific controls
        }
    }
}

struct ConfigurationControlsPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuration")
                .font(.headline)
                .padding()

            // TODO: Add configuration controls
        }
    }
}

#Preview {
    NavigationPanel()
        .frame(width: 250, height: 600)
        .environment(AppState())
}