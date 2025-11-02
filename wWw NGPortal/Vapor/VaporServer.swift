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
    weak var appState: AppState?

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

        // Configure static file serving from Nightgard public folder
        if let publicPath = NightgardFileStructure.shared.nightgardRoot?.appendingPathComponent("public").path {
            app.middleware.use(FileMiddleware(publicDirectory: publicPath))
            appState?.addDebugMessage("Serving static files from: \(publicPath)", type: .info)
        } else {
            appState?.addDebugMessage("Warning: Nightgard public folder not found, using default routes", type: .warning)
        }

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
        // Serve index.html for root path
        app.get { req async throws -> Response in
            guard let publicPath = await NightgardFileStructure.shared.nightgardRoot?.appendingPathComponent("public/index.html").path else {
                throw Abort(.notFound)
            }
            return try await req.fileio.asyncStreamFile(at: publicPath)
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
