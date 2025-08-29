//
//  LumaApp.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 应用程序的入口文件
//  - 纯UI版本，不包含复杂业务逻辑
//
//  Created by Han on 23/8/2025.
//

import SwiftUI

@main
struct LumaApp: App {
    init() {
            // ⚠️ Remove for production: this line resets launch state for debugging
            UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore")
        }
    var body: some Scene {
        WindowGroup {
            AppEntryView()
        }
    }
}
