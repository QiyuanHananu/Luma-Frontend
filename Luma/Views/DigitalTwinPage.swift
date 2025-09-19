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
            Color(.systemBackground).ignoresSafeArea()
            
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
                    .background(Color.clear)
                
                // hint
                Text("Tap a body area to see insights")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    DigitalTwinPage()
}
