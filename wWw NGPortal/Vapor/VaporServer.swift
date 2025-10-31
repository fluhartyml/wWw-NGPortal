//
//  VaporServer.swift
//  wWw NGPortal
//
//  Vapor web server implementation
//  2025-10-31 14:35 CDT
//

import Foundation
import Vapor

@MainActor
class VaporServer {
    private var app: Application?
    private var serverTask: Task<Void, Error>?
    private(set) var isRunning = false
    private(set) var port: Int = 8080
    
    func start(on port: Int) async throws {
        guard !isRunning else { return }
        
        self.port = port
        
        // Create Vapor application
        var env = try Environment.detect()
        env.arguments = ["serve", "--port", "\(port)"]
        
        let app = try await Application.make(env)
        self.app = app
        
        // Configure routes
        configureRoutes(app)
        
        // Start server in background task
        serverTask = Task {
            try await app.execute()
        }
        
        isRunning = true
    }
    
    func stop() async {
        guard isRunning else { return }
        
        serverTask?.cancel()
        serverTask = nil
        
        if let app = app {
            try? await app.asyncShutdown()
            self.app = nil
        }
        
        isRunning = false
    }
    
    private func configureRoutes(_ app: Application) {
        // Root route
        app.get { req async in
            return """
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
