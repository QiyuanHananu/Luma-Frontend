//
//  HeartHealthView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 12/9/2025.
//

import SwiftUI

struct HeartHealthView: View {
    @State private var isBeating = false
    @State private var trendSelection = "Heart Rate"
    @State private var healthTip: String = "Your blood pressure is stable today. Keep it up!"
    
    var body: some View {
        VStack(spacing: 20) {
            
            // ✅ popping heart
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.4))
                    .scaleEffect(isBeating ? 1.1 : 1.0)
                    .blur(radius: 20)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: isBeating)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.pink)
                    .frame(width: 120, height: 120)
                    .shadow(color: .pink.opacity(0.6), radius: 10)
            }
            .onAppear { isBeating = true }
            
            // ✅ cards
            HStack(spacing: 16) {
                StatCard(title: "Heart Rate", value: "72 bpm", color: .red.opacity(0.4))
                    .onTapGesture { trendSelection = "Heart Rate" }
                
                StatCard(title: "Blood Pressure", value: "118/76", color: .blue.opacity(0.4))
                    .onTapGesture { trendSelection = "Blood Pressure" }
            }
            .padding(.horizontal)
            
            // ✅ trends
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(trendSelection)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                    
                    Picker("Range", selection: $trendSelection) {
                        Text("Heart Rate").tag("Heart Rate")
                        Text("Blood Pressure").tag("Blood Pressure")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Text("📈 \(trendSelection) Chart")
                            .foregroundColor(.gray)
                    )
            }
            .padding()
            
            
            // ✅ hint card
            VStack(alignment: .leading, spacing: 8) {
                Text("Health Tip")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(healthTip)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(radius: 4)
            .padding(.horizontal)
            
            // voice
            Button(action: {
                print("🎙️ Start voice recognition (Brain)")
            }) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.linearGradient(colors: [.pink.opacity(0.3), .red], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .padding(.bottom, 20)
        }
        .padding(.top)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(.systemGray6)) // 平面浅灰背景
        .cornerRadius(12)                // 圆角
        .overlay(                        // 细线边框
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    HeartHealthView()
}
