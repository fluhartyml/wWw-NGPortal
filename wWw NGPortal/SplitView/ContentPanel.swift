//
//  ContentPanel.swift
//  wWw NGPortal
//
//  Main content panel that displays feature-specific views
//  2025-10-31 13:01 CDT
//

import SwiftUI

struct ContentPanel: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            switch appState.selectedFeature {
            case .webServer:
                ServerContentView()
            case .ddns:
                DDNSContentView()
            case .configuration:
                ConfigurationContentView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .textBackgroundColor))
    }
}

#Preview {
    ContentPanel()
        .environment(AppState())
        .frame(width: 600, height: 500)
}
