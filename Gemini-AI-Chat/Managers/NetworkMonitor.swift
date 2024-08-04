//
//  NetworkMonitor.swift
//  swift-login-system
//
//  Created by eren on 26.07.2024.
//

import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private var isConnected = false

    private init() {
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func isReachable() -> Bool {
        return isConnected
    }
}
