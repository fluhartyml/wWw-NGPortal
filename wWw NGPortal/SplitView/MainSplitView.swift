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
    }
    
    private func refreshAll() {
        appState.addDebugMessage("Refresh all triggered", type: .info)
        // TODO: Implement refresh logic
    }
}

#Preview {
    MainSplitView()
        .frame(width: 1000, height: 700)
}