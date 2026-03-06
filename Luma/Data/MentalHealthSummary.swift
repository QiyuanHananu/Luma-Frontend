//
//  MentalHealthSummary.swift
//  Luma
//
//  Created by Jiaoyang Liu on 5/3/2026.
//


import Foundation

struct MentalHealthSummary: Identifiable, Codable {
    
    let id: UUID
    let createdAt: Date
    
    let periodStart: Date
    let periodEnd: Date
    
    let moodScore: Int            // 0–10
    let dominantEmotions: [String]
    let riskLevel: String         // low / moderate / high
    
    let notes: String
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        periodStart: Date,
        periodEnd: Date,
        moodScore: Int,
        dominantEmotions: [String],
        riskLevel: String,
        notes: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.periodStart = periodStart
        self.periodEnd = periodEnd
        self.moodScore = moodScore
        self.dominantEmotions = dominantEmotions
        self.riskLevel = riskLevel
        self.notes = notes
    }
}