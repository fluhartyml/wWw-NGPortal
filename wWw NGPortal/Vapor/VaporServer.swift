//
//  VaporServer.swift
//  wWw NGPortal
//
//  Vapor web server implementation
//  2025-10-31 17:43 CDT
//

import Foundation
import Vapor

@MainActor
@Observable
class VaporServer {
    private var app: Application?
    private var serverTask: Task<Void, Error>?
    var isRunning = false
    var port: Int = 8080
    private weak var appState: AppState?

    func setAppState(_ appState: AppState) {
        self.appState = appState
    }

    func start(on port: Int) async throws {
        guard !isRunning else { return }

        self.port = port

        appState?.addDebugMessage("Initializing Vapor application...", type: .info)

        // Create Vapor application
        let env = try Environment.detect()
        let app = try await Application.make(env)

        // Configure server to listen on all network interfaces
        app.http.server.configuration.hostname = "0.0.0.0"
        app.http.server.configuration.port = port

        appState?.addDebugMessage("Configured server: 0.0.0.0:\(port)", type: .info)

        self.app = app

        // Configure routes
        configureRoutes(app)
        appState?.addDebugMessage("Routes configured", type: .success)

        // Start the server
        do {
            appState?.addDebugMessage("Starting HTTP server...", type: .info)
            try await app.startup()
            appState?.addDebugMessage("HTTP server listening on http://0.0.0.0:\(port)", type: .success)

            isRunning = true

            // Keep server running in background task
            serverTask = Task {
                do {
                    try await app.running?.onStop.get()
                } catch {
                    await MainActor.run {
                        appState?.addDebugMessage("Server stopped with error: \(error.localizedDescription)", type: .error)
                        isRunning = false
                    }
                }
            }
        } catch {
            appState?.addDebugMessage("Failed to start server: \(error.localizedDescription)", type: .error)
            try? await app.asyncShutdown()
            self.app = nil
            throw error
        }
    }
    
    func stop() async {
        guard isRunning else { return }

        appState?.addDebugMessage("Stopping HTTP server...", type: .info)

        serverTask?.cancel()
        serverTask = nil

        if let app = app {
            try? await app.asyncShutdown()
            self.app = nil
            appState?.addDebugMessage("HTTP server stopped", type: .success)
        }

        isRunning = false
    }
    
    private func configureRoutes(_ app: Application) {
        // Root route
        app.get { req async -> Response in
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
                <title>wWw NGPortal</title>
                <style>
                    body {
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
                        max-width: 800px;
                        margin: 50px auto;
                        padding: 20px;
                        background: #f5f5f7;
                    }
                    h1 { color: #1d1d1f; }
                    .info { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
                    a { color: #0071e3; text-decoration: none; }
                    a:hover { text-decoration: underline; }
                </style>
            </head>
            <body>
                <h1>🚀 wWw NGPortal Server</h1>
                <div class="info">
                    <p>Server is running successfully!</p>
                    <p>Powered by <a href="https://vapor.codes" target="_blank">Vapor</a></p>
                    <p><strong>Available Routes:</strong></p>
                    <ul>
                        <li><a href="/">/ (Home)</a></li>
                        <li><a href="/api/status">/api/status (API Status)</a></li>
                        <li><a href="/api/info">/api/info (Server Info)</a></li>
                    </ul>
                </div>
            </body>
            </html>
            """
            
            return Response(
                status: .ok,
                headers: ["Content-Type": "text/html; charset=utf-8"],
                body: .init(string: html)
            )
        }
        
        // API Status route
        app.get("api", "status") { req async in
            return [
                "status": "online",
                "server": "wWw NGPortal",
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
        }
        
        // API Info route
        app.get("api", "info") { req async in
            return [
                "name": "wWw NGPortal",
                "version": "1.0.0",
                "framework": "Vapor",
                "platform": "macOS"
            ]
        }
    }
}
