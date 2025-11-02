//
//  MainSplitView.swift
//  wWw NGPortal
//
//  Created by Michael Fluharty on 10/31/25.
//


//
//  MainSplitView.swift
//  wWw NGPortal
//
//  Main split view layout with toolbar and debug ticker
//  2025-10-31 12:37 CDT
//

import SwiftUI

struct MainSplitView: View {
    @State private var appState = AppState()
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Toolbar
            HStack {
                // App Icon Menu Button
                Button(action: showAbout) {
                    Image("AppIconImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.borderless)
                .help("About wWw NGPortal")

                Spacer()

                Button(action: refreshAll) {
                    Image(systemName: "arrow.clockwise")
                        .imageScale(.large)
                }
                .buttonStyle(.borderless)
                .help("Refresh All")
                
                Toggle(isOn: $appState.isDebugEnabled) {
                    Image(systemName: "ladybug")
                        .imageScale(.large)
                }
                .toggleStyle(.button)
                .help("Debug Mode")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            // Main Split View
            HSplitView {
                // Panel B - Navigation/Controls (Left)
                NavigationPanel()
                    .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
                
                // Panel A - Content/IO (Right)
                ContentPanel()
                    .frame(minWidth: 400)
            }
            
            // Debug Ticker (Bottom)
            if appState.isDebugEnabled {
                DebugTickerView()
                    .frame(height: 100)
            }
        }
        .environment(appState)
        .preferredColorScheme(colorScheme(for: appState.appearanceMode))
    }

    private func colorScheme(for mode: AppearanceMode) -> ColorScheme {
        switch mode {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    private func refreshAll() {
        appState.addDebugMessage("Refresh all triggered", type: .info)
        // TODO: Implement refresh logic
    }

    private func showAbout() {
        appState.addDebugMessage("About wWw NGPortal - NightGard Server v1.0", type: .info)
        // TODO: Show about panel or app info
    }
}

#Preview {
    MainSplitView()
        .frame(width: 1000, height: 700)
}