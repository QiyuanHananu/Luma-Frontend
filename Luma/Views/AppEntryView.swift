import SwiftUI

struct AppEntryView: View {
    @State private var hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")

    var body: some View {
        if hasLaunchedBefore {
            CompanionView() // 替换成你的主页面
        } else {
            OnboardingView(hasLaunchedBefore: $hasLaunchedBefore)
        }
    }
}