//
//  StorageManager.swift
//  Luma
//
//  Created by Jiaoyang Liu on 26/2/2026.
//

import Foundation

final class StorageManager {
    static let shared = StorageManager()

    private let baseURL: URL
    
    func debugPrintBasePath() {
        print("📁 Luma Base Path:", baseURL.path)
    }
    
    func saveMessage(_ message: Conversation) {
        let sessionURL = baseURL
            .appendingPathComponent("sessions")
            .appendingPathComponent("current_session.json")
        
        var existing: [Conversation] = []
        
        if let data = try? Data(contentsOf: sessionURL),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            existing = decoded
        }
        
        existing.append(message)
        
        if let encoded = try? JSONEncoder().encode(existing) {
            try? encoded.write(to: sessionURL)
            print("📂 Session file path:", sessionURL.path)
        }
        print("💾 Saved message:", message.message)
    }

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        baseURL = documents.appendingPathComponent("LumaData")
        createFoldersIfNeeded()
    }

    private func createFoldersIfNeeded() {
        let sessions = baseURL.appendingPathComponent("sessions")
        let summaries = baseURL.appendingPathComponent("summaries")

        try? FileManager.default.createDirectory(at: sessions, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: summaries, withIntermediateDirectories: true)
    }
    
    func loadCurrentSession() -> [Conversation] {
        let sessionURL = baseURL
            .appendingPathComponent("sessions")
            .appendingPathComponent("current_session.json")
        
        guard let data = try? Data(contentsOf: sessionURL),
              let decoded = try? JSONDecoder().decode([Conversation].self, from: data) else {
            return []
        }
        
        return decoded
    }
}
