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
        VStack(spacing: 0) {
            Text("This is your Digital Twin")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            Divider()
                .padding(.horizontal, 16)
            
            // Human model with binding
            HumanModelView(navigateToHeartRate: $navigateToHeartRate)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            
            // Navigation example
            NavigationLink(
                destination:HealthOverviewCard(
                    icon: "heart.fill",
                    title: "Heart Rate",
                    value: "72",
                    unit: "bpm",
                    color: .red,
                    trend: .stable
                ),
                isActive: $navigateToHeartRate
            ) {
                EmptyView()
            }
        }
    }
}

#Preview {
    DigitalTwinPage()
}
