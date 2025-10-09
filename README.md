# Luma - AI健康伴侣应用

## 📱 项目简介

Luma 是一个基于 SwiftUI 的 AI 健康伴侣应用，提供智能健康监测、3D数字孪生人体模型交互和个性化健康建议。

## 🏗️ 项目架构

### 技术栈
- **框架**: SwiftUI
- **3D渲染**: SceneKit
- **数据可视化**: Charts (部分页面)
- **最低支持**: iOS 15.0+

### 项目结构
```
Luma/
├── LumaApp.swift              # 应用入口
├── AppEntryView.swift         # 启动判断
├── ContentView.swift          # 主导航容器
├── Views/
│   ├── CompanionView.swift    # AI伴侣主页面
│   ├── SettingsView.swift     # 设置页面
│   ├── DigitalTwinPage.swift  # 3D数字孪生页面
│   ├── HumanModelView.swift   # 3D模型交互
│   ├── BrainHealthView.swift  # 大脑健康页面
│   ├── HeartHealthView.swift  # 心脏健康页面
│   ├── SimpleMedicalDashboardView.swift # 医疗仪表板
│   └── OnboardingView.swift   # 引导页面
└── Models/
    └── UIModels.swift         # 数据模型
```

## 🚀 快速开始

### 安装要求
- Xcode 14.0+
- iOS 15.0+
- macOS 12.0+ (用于开发)

### 运行项目
1. 克隆项目到本地
2. 使用 Xcode 打开 `Luma.xcodeproj`
3. 选择目标设备或模拟器
4. 点击运行按钮 (⌘+R)

## 🧭 应用导航

### 启动流程
```
LumaApp → AppEntryView → ContentView (TabView)
```

### 主导航结构
应用使用 **TabView** 作为主导航，包含两个标签页：

#### Tab 1: AI伴侣 (CompanionView) 💬
- **功能**: AI对话交互，健康数据展示
- **特色**: 左上角菜单访问所有健康功能
- **交互**: 点击 Luma 角色开始对话

#### Tab 2: 设置 (SettingsView) ⚙️
- **功能**: 应用设置，个人资料管理
- **特色**: 隐私设置，通知管理

## 📋 页面跳转逻辑

### 从 AI伴侣页面 (CompanionView) 的跳转

#### 左上角菜单 ☰
点击左上角的三横线图标，显示下拉菜单：

**健康数据 (Health Data)**
- 🩺 **Medical Dashboard** → 医疗仪表板
- 🧠 **Brain Health** → 大脑健康页面
- ❤️ **Heart Health** → 心脏健康页面

**更多 (More)**
- 📈 **Health Snapshot** → 显示健康快照卡片
- ⚙️ **Settings** → 设置页面

### 3D数字孪生页面 (DigitalTwinPage) 🧍

**如何访问**: 目前是独立页面，建议添加到菜单或作为第三个 Tab

**交互功能**:
- **点击头部** 🔵 → 跳转到大脑健康页面
- **点击左胸** 🔴 → 跳转到心脏健康页面  
- **点击右胸** 🔴 → 跳转到心脏健康页面
- **360度旋转** → 拖动查看模型
- **缩放** → 双指手势缩放

## 🎯 核心功能

### 1. AI伴侣交互
- **智能对话**: 基于情绪的 AI 回复
- **情绪识别**: 根据用户输入调整 Luma 表情
- **健康建议**: 个性化健康指导

### 2. 3D数字孪生
- **人体模型**: 高精度3D人体模型展示
- **热点交互**: 点击不同身体部位查看健康数据
- **实时渲染**: 流畅的3D交互体验

### 3. 健康数据管理
- **医疗仪表板**: 综合健康数据概览
- **专项健康**: 大脑、心脏等专项健康监测
- **数据可视化**: 图表展示健康趋势

## 🔧 开发指南

### 添加新页面到导航

1. **创建新页面文件**
```swift
struct NewPageView: View {
    var body: some View {
        // 页面内容
    }
}
```

2. **在 CompanionView 中添加状态**
```swift
@State private var showNewPage = false
```

3. **在菜单中添加按钮**
```swift
Button(action: { showNewPage = true }) {
    Label("New Page", systemImage: "icon.name")
}
```

4. **添加 sheet 修饰符**
```swift
.sheet(isPresented: $showNewPage) {
    NewPageView()
}
```

### 3D模型交互开发

1. **创建热点区域**
```swift
func createHotspot(name: String, position: SCNVector3) -> SCNNode {
    let sphere = SCNSphere(radius: 0.1)
    // 设置透明材质
    let node = SCNNode(geometry: sphere)
    node.name = name
    node.position = position
    return node
}
```

2. **处理点击事件**
```swift
@objc func handleTap(_ gesture: UITapGestureRecognizer) {
    let hitResults = sceneView.hitTest(location, options: [:])
    // 根据节点名称处理跳转
}
```

## 📊 项目统计

- **已集成页面**: 8个
- **独立页面**: 2个
- **未集成页面**: 8个
- **已删除页面**: 4个
- **总文件数**: 22个

## 🚧 待办事项

### 高优先级
- [ ] 集成 DigitalTwinPage 到主导航
- [ ] 优化 3D 模型加载性能
- [ ] 完善医疗数据可视化

### 中优先级
- [ ] 集成其他医疗页面 (TimelineView, BiometricDataView等)
- [ ] 添加数据导出功能
- [ ] 完善隐私设置

### 低优先级
- [ ] 添加更多 3D 模型交互
- [ ] 优化 AI 对话体验
- [ ] 添加用户个性化设置

## 🐛 已知问题

1. **Charts 框架**: 在模拟器中可能崩溃，使用 SimpleMedicalDashboardView 替代
2. **3D模型加载**: 需要确保模型文件存在于 Bundle 中
3. **内存管理**: 长时间使用 3D 视图可能占用较多内存

## 📝 更新日志

### v2.0 (2025-10-09)
- ✅ 重构导航架构，使用 TabView
- ✅ 删除不必要的页面 (CopingSkillsView, DigitalTwinView等)
- ✅ 优化 3D 模型交互体验
- ✅ 完善文档和跳转逻辑

### v1.0 (2025-08-23)
- ✅ 初始版本发布
- ✅ 基础 AI 伴侣功能
- ✅ 3D 数字孪生原型

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- **项目维护者**: Han
- **创建时间**: 2025年8月23日
- **最后更新**: 2025年10月9日

---

**Luma - 让 AI 成为你的健康伙伴** 🤖💙
