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
}
