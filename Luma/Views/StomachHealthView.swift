//
//  StomachHealthView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 11/9/2025.
//

import SwiftUI

struct StomachHealthView: View {
    @State private var trendSelection = "Digestion"
    @State private var healthTip: String = "Your digestion index is stable. Keep a balanced diet!"
    
    var body: some View {
        VStack(spacing: 20) {
            
            // 顶部胃部图标
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 200)
                    .blur(radius: 5)
                
                Image(systemName: "cross.case.fill") // 暂用医疗图标
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .green.opacity(0.5), radius: 20)
            }
            
            // 中间卡片
            HStack(spacing: 16) {
                StatCard(title: "Digestion", value: "Normal", color: .green)
                    .onTapGesture { trendSelection = "Digestion" }
                
                StatCard(title: "Nutrient Absorption", value: "Good", color: .green)
                    .onTapGesture { trendSelection = "Nutrient Absorption" }
            }
            .padding(.horizontal)
            
            // 趋势图
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("\(trendSelection)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        Text("📈 \(trendSelection) Trend")
                            .foregroundColor(.gray)
                    )
            }
            .padding()
            
            // 健康提示卡片
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
            
            Spacer()
            
            // 语音交互入口
            Button(action: {
                print("🎙️ Start voice recognition (Stomach)")
            }) {
                Image(systemName: "waveform.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.linearGradient(colors: [.white, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
            }
            .padding(.bottom, 20)
        }
    }
}

#Preview{
    StomachHealthView()
}
