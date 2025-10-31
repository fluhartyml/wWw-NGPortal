//
//  DDNSService.swift
//  wWw NGPortal
//
//  DDNS update service supporting DuckDNS
//  2025-10-31 18:05 CDT
//

import Foundation

@MainActor
class DDNSService {
    private var updateTimer: Timer?
    private(set) var isRunning = false
    private(set) var lastUpdateTime: Date?
    private(set) var lastStatus: String = "Idle"
    private(set) var currentIP: String?
    
    var domain: String = ""
    var token: String = ""
    var updateInterval: TimeInterval = 300 // 5 minutes default
    
    func start() {
        guard !isRunning else { return }
        guard !domain.isEmpty && !token.isEmpty else { return }
        
        isRunning = true
        
        // Perform immediate update
        Task {
            await performUpdate()
        }
        
        // Schedule periodic updates
        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.performUpdate()
            }
        }
    }
    
    func stop() {
        updateTimer?.invalidate()
        updateTimer = nil
        isRunning = false
        lastStatus = "Stopped"
    }
    
    func performUpdate() async {
        // Detect current IP
        guard let ip = await detectCurrentIP() else {
            lastStatus = "Failed: Could not detect IP"
            return
        }
        
        currentIP = ip
        
        // Only update if IP changed
        if let lastIP = currentIP, lastIP == ip {
            lastStatus = "No change"
            return
        }
        
        // Perform DDNS update based on provider
        let success = await updateDDNS(ip: ip)
        
        if success {
            lastStatus = "Success"
            lastUpdateTime = Date()
        } else {
            lastStatus = "Failed: Update error"
        }
    }
    
    private func detectCurrentIP() async -> String? {
        // Use multiple IP detection services for reliability
        let services = [
            "https://api.ipify.org",
            "https://icanhazip.com",
            "https://ifconfig.me/ip"
        ]
        
        for serviceURL in services {
            guard let url = URL(string: serviceURL) else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    return ip
                }
            } catch {
                continue
            }
        }
        
        return nil
    }
    
    private func updateDDNS(ip: String) async -> Bool {
        return await updateDuckDNS(ip: ip)
    }
    
    private func updateDuckDNS(ip: String) async -> Bool {
        // DuckDNS API: https://www.duckdns.org/update?domains={DOMAIN}&token={TOKEN}&ip={IP}
        let urlString = "https://www.duckdns.org/update?domains=\(domain)&token=\(token)&ip=\(ip)"
        guard let url = URL(string: urlString) else { return false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let response = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                return response == "OK"
            }
        } catch {
            return false
        }
        
        return false
    }
}
