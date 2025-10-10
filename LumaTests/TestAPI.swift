//
//  TestAPI.swift
//  Luma
//
//  Created by Jiaoyang Liu on 10/10/2025.
//


import SwiftUI

struct TestAPI: View {
    @State private var message = "Waiting for response..."
    
    var body: some View {
        VStack(spacing: 20) {
            Text(message)
                .padding()
            
            Button("Ping API") {
                fetchAPI()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func fetchAPI() {
        guard let url = URL(string: "http://127.0.0.1:8000/test") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = json["message"] as? String {
                DispatchQueue.main.async {
                    message = msg
                }
            } else {
                DispatchQueue.main.async {
                    message = "❌ API unreachable."
                }
            }
        }.resume()
    }
}