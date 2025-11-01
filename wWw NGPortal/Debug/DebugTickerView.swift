//
//  DebugTickerView.swift
//  wWw NGPortal
//
//  Debug message ticker panel display with auto-scroll animation
//  2025-10-31 17:54 CDT
//

import SwiftUI

struct DebugTickerView: View {
    @Environment(AppState.self) private var appState
    @State private var scrollOffset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Debug icon
                Image(systemName: "ladybug.fill")
                    .foregroundStyle(.orange)
                    .imageScale(.medium)
                
                // Auto-scrolling messages
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(appState.debugMessages.suffix(20)) { message in
                                DebugMessageView(message: message)
                            }
                        }
                        .padding(.horizontal, 8)
                        .background(
                            GeometryReader { contentGeometry in
                                Color.clear
                                    .onAppear {
                                        contentWidth = contentGeometry.size.width
                                    }
                                    .onChange(of: appState.debugMessages.count) {
                                        contentWidth = contentGeometry.size.width
                                    }
                            }
                        )
                        .offset(x: scrollOffset)
                    }
                    .scrollDisabled(true)
                    .onAppear {
                        startScrolling(viewWidth: geometry.size.width)
                    }
                }
                
                // Clear button
                Button(action: clearMessages) {
                    Image(systemName: "trash")
                        .imageScale(.medium)
                }
                .buttonStyle(.borderless)
                .help("Clear debug messages")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(nsColor: .controlBackgroundColor))
        }
    }
    
    private func startScrolling(viewWidth: CGFloat) {
        guard contentWidth > 0 else { return }

        withAnimation(.linear(duration: Double(contentWidth / 150)).repeatForever(autoreverses: false)) {
            scrollOffset = -contentWidth - viewWidth
        }
    }
    
    @MainActor
    private func clearMessages() {
        appState.clearDebugMessages()
        scrollOffset = 0
    }
}

struct DebugMessageView: View {
    let message: DebugMessage
    
    var body: some View {
        HStack(spacing: 8) {
            // Message type icon
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
                .imageScale(.small)
            
            // Timestamp
            Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
            
            // Message text
            Text(message.text)
                .font(.caption)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .cornerRadius(4)
    }
    
    private var iconName: String {
        switch message.type {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch message.type {
        case .info: return .blue
        case .warning: return .orange
        case .error: return .red
        case .success: return .green
        }
    }
    
    private var backgroundColor: Color {
        switch message.type {
        case .info: return Color.blue.opacity(0.1)
        case .warning: return Color.orange.opacity(0.1)
        case .error: return Color.red.opacity(0.1)
        case .success: return Color.green.opacity(0.1)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        DebugTickerView()
            .frame(height: 100)
    }
    .environment({
        let state = AppState()
        state.addDebugMessage("Server started on port 8080", type: .success)
        state.addDebugMessage("DDNS update in progress", type: .info)
        state.addDebugMessage("Failed to connect to DDNS provider", type: .error)
        state.addDebugMessage("IP address changed detected", type: .warning)
        return state
    }())
    .frame(width: 800, height: 200)
}
