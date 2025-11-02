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
        ZStack {
            // Subtle watermark background
            GeometryReader { geometry in
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: min(geometry.size.width, geometry.size.height) * 0.4)
                    .opacity(0.03)
                    .position(
                        x: geometry.size.width * 0.85,
                        y: geometry.size.height * 0.85
                    )
            }

            // Content
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
