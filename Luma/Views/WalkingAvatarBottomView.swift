//
//  WalkingAvatarBottomView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 27/8/2025.
//


import SwiftUI

struct WalkingAvatarBottomView: View {
    @State private var positionX: CGFloat = 0
    @State private var direction: CGFloat = 1

    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let avatarSize: CGFloat = 80

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            // Avatar 走动位置
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: avatarSize, height: avatarSize)
                .foregroundColor(.blue)
                .offset(x: positionX, y: screenHeight / 2 - avatarSize) // ➜ 固定在底部
                .animation(.linear(duration: 0.02), value: positionX)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                withAnimation {
                    positionX += direction * 1.5

                    // 到达屏幕边缘时反向
                    if positionX > (screenWidth / 2 - avatarSize / 2) {
                        direction = -1
                    } else if positionX < -(screenWidth / 2 - avatarSize / 2) {
                        direction = 1
                    }
                }
            }
        }
    }
}

struct WalkingAvatarBottomView_Previews: PreviewProvider {
    static var previews: some View {
        WalkingAvatarBottomView()
    }
}