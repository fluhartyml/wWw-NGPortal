//
//  AppState.swift
//  wWw NGPortal
//
//  Manages application-wide state for feature selection and debug mode
//  2025-10-31 12:35 CDT
//

import Foundation
import Observation

@Observable
@MainActor
class AppState {
    var selectedFeature: AppFeature = .webServer
    var isDebugEnabled: Bool = false
    var debugMessages: [DebugMessage] = []
    
    func addDebugMessage(_ message: String, type: DebugMessageType = .info) {
        let debugMessage = DebugMessage(text: message, type: type)
        debugMessages.append(debugMessage)
        
        // Keep only last 100 messages
        if debugMessages.count > 100 {
            debugMessages.removeFirst()
        }
    }
    
    func clearDebugMessages() {
        debugMessages.removeAll()
    }
}

enum AppFeature {
    case ddns
    case webServer
}

struct DebugMessage: Identifiable {
    let id = UUID()
    let text: String
    let type: DebugMessageType
    let timestamp = Date()
}

enum DebugMessageType {
    case info
    case warning
    case error
    case success
}
