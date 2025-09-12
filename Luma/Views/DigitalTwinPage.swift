//
//  DigitalTwinPage.swift
//  Luma
//
//  Created by Jiaoyang Liu on 3/9/2025.
//


import SwiftUI

struct DigitalTwinPage: View {
    @State private var navigateToHeartRate = false
    
    var body: some View {
        ZStack {
            // background
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // title
                Text("Luma Digital Twin")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.8))
                
                Divider().padding(.horizontal, 40)
                
                // human base
                HumanModelView(navigateToHeartRate: $navigateToHeartRate)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // hint
                Text("Tap a body area to see insights ✨")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    DigitalTwinPage()
}
