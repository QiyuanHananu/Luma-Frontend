# Luma 应用页面跳转逻辑文档

## 📱 应用导航架构总览

### 启动流程
```
LumaApp (入口)
    ↓
AppEntryView (判断是否首次启动)
    ↓
    ├── 首次启动 → OnboardingView (引导页)
    │                    ↓
    │              ContentView (完成引导后)
    │
    └── 已启动过 → ContentView (主导航)
                        ↓
                   TabView (底部标签栏)
                        ├─ Tab 1: CompanionView (AI伴侣)
                        └─ Tab 2: SettingsView (设置)
```

---

## 🏠 主页面：CompanionView (AI伴侣页面)

**页面位置**：`Luma/Views/CompanionView.swift`

**功能**：
- AI伴侣交互界面
- 应用的主要入口页面
- 提供左上角菜单访问所有其他功能

### 从 CompanionView 的跳转方式

#### 1️⃣ 左上角菜单（主要导航方式）

点击左上角的 ☰ 菜单按钮，会显示下拉菜单，包含以下选项：

**主要功能 (Main Features)**
- **Digital Twin** 🧍 → 跳转到 `DigitalTwinPage`

**健康数据 (Health Data)**
- **Medical Dashboard** 🩺 → 跳转到 `SimpleMedicalDashboardView`
- **Brain Health** 🧠 → 跳转到 `BrainHealthView`
- **Heart Health** ❤️ → 跳转到 `HeartHealthView`

**更多 (More)**
- **Health Snapshot** 📈 → 显示当前页面底部的健康快照卡片
- **Settings** ⚙️ → 跳转到 `SettingsView`

#### 实现方式
- 使用 SwiftUI 的 `.sheet()` 修饰符
- 每个菜单项控制一个 `@State` 布尔变量
- 点击菜单项时设置对应的状态为 `true`，触发 sheet 弹出

---

## 🧍 DigitalTwinPage (3D数字孪生页面)

**页面位置**：`Luma/Views/DigitalTwinPage.swift`

**功能**：
- 显示3D人体模型 (使用 `HumanModelView`)
- 支持点击不同身体部位查看健康数据
- 支持360度旋转查看模型

### 如何访问此页面
从 **CompanionView** → 左上角菜单 → **Digital Twin**

### 从 DigitalTwinPage 的跳转方式

#### 1️⃣ 点击3D人体模型 (HumanModelView)

**头部区域**
- **点击头部热点 (HeadHotspot)** 🔵 → 跳转到 `BrainHealthView`
  - 热点半径：0.1
  - 位置：头部中心

**胸部区域**
- **点击左胸热点 (LeftChestHotspot)** 🔴 → 跳转到 `HeartHealthView`
  - 热点半径：0.15（扩大 50%，更容易点击）
  - 位置：左胸位置
  
- **点击右胸热点 (RightChestHotspot)** 🔴 → 跳转到 `HeartHealthView`
  - 热点半径：0.15（扩大 50%，更容易点击）
  - 位置：右胸位置

**其他热点（暂未实现跳转）**
- HeartHotspot (心脏中心) - 保留用于心率相关功能
- StomachHotspot (胃部)
- AbdomenHotspot (腹部)
- LeftArmHotspot / RightArmHotspot (手臂)
- LeftLegHotspot / RightLegHotspot (腿部)

#### 2️⃣ 交互提示
- 底部显示 "Tap a body area to see insights"
- 支持拖动旋转模型 (SceneKit allowsCameraControl)

#### 实现方式
- 使用 SceneKit 的 `hitTest` 检测点击的3D热点节点
- 热点使用透明球体 (SCNSphere) 覆盖在模型上
- 使用 `.sheet()` 修饰符弹出对应的健康页面

---

## 🩺 SimpleMedicalDashboardView (医疗仪表板)

**页面位置**：`Luma/Views/SimpleMedicalDashboardView.swift`

**功能**：
- 显示综合医疗数据概览
- 简化版医疗仪表板（不依赖Charts框架）

### 从 SimpleMedicalDashboardView 的跳转方式

#### 1️⃣ 页面内导航
- 可以查看各项健康指标
- 右上角有关闭按钮返回上一页

---

## 🧠 BrainHealthView (大脑健康页面)

**页面位置**：`Luma/Views/BrainHealthView.swift`

**功能**：
- 显示大脑健康相关数据
- 包括认知功能、睡眠质量等指标

### 访问路径
1. **CompanionView** → 左上角菜单 → Brain Health
2. **DigitalTwinView** → 点击3D模型头部

---

## ❤️ HeartHealthView (心脏健康页面)

**页面位置**：`Luma/Views/HeartHealthView.swift`

**功能**：
- 显示心脏健康相关数据
- 包括心率、血压等指标

### 访问路径
1. **CompanionView** → 左上角菜单 → Heart Health
2. **DigitalTwinView** → 点击3D模型胸部

---


## ⚙️ SettingsView (设置页面)

**页面位置**：`Luma/Views/SettingsView.swift`

**功能**：
- 应用设置和个人资料
- 隐私设置、通知设置等

### 访问路径
1. **CompanionView** → 左上角菜单 → Settings

---

## 📊 其他医疗相关页面

这些页面目前存在于项目中，可以通过后续扩展菜单访问：

### MedicalOverviewView (医疗概览)
**文件**：`Luma/Views/MedicalOverviewView.swift`
**功能**：患者医疗历史概览
**状态**：未集成到导航

### TimelineView (时间线)
**文件**：`Luma/Views/TimelineView.swift`
**功能**：按时间顺序显示健康事件
**状态**：未集成到导航

### BiometricDataView (生物识别数据)
**文件**：`Luma/Views/BiometricDataView.swift`
**功能**：详细的生物识别数据记录
**状态**：未集成到导航

### BehavioralPatternsView (行为模式)
**文件**：`Luma/Views/BehavioralPatternsView.swift`
**功能**：AI分析的行为模式
**状态**：未集成到导航

### ExportSharingView (导出与分享)
**文件**：`Luma/Views/ExportSharingView.swift`
**功能**：数据导出和安全分享
**状态**：未集成到导航

### PrivacySecurityView (隐私与安全)
**文件**：`Luma/Views/PrivacySecurityView.swift`
**功能**：隐私和安全设置
**状态**：未集成到导航

### MedicalDashboardView (完整医疗仪表板)
**文件**：`Luma/Views/MedicalDashboardView.swift`
**功能**：使用 Charts 框架的完整医疗仪表板
**状态**：由于 Charts 在模拟器中可能崩溃，暂时使用 SimpleMedicalDashboardView 替代

### ProfileView (用户档案)
**文件**：`Luma/Views/ProfileView.swift`
**功能**：用户个人资料
**状态**：未集成到导航

### LinkProvider (链接提供者)
**文件**：`Luma/Views/LinkProvider.swift`
**功能**：辅助工具文件
**状态**：工具类，不是页面

---

## 🔄 完整的页面跳转关系图

```
LumaApp
    ↓
AppEntryView
    ↓
    ├─ 首次启动 → OnboardingView
    │                   ↓
    │             ContentView
    │
    └─ 已启动 → ContentView ⭐ (主导航)
                    ↓
               TabView (底部标签栏)
                    │
                    ├─ Tab 1: CompanionView (AI伴侣) 💬
                    │         │
                    │         ├─ 左上角菜单 ☰
                    │         │   ├─→ SimpleMedicalDashboardView 🩺
                    │         │   ├─→ BrainHealthView 🧠
                    │         │   ├─→ HeartHealthView ❤️
                    │         │   └─→ SettingsView ⚙️
                    │         │
                    │         └─ 底部健康快照 📈 (切换显示)
                    │
                    └─ Tab 2: SettingsView (设置) ⚙️


独立页面（未集成到主导航）:
    
    DigitalTwinPage 🧍 (3D数字孪生)
         │
         ├─ 点击头部热点 → BrainHealthView 🧠
         ├─ 点击左胸热点 → HeartHealthView ❤️
         └─ 点击右胸热点 → HeartHealthView ❤️
```

---

## 💡 技术实现说明

### 导航方式
1. **Sheet模态**：大部分页面使用 `.sheet(isPresented:)` 实现，从底部弹出
2. **状态管理**：每个目标页面有一个对应的 `@State` 布尔变量控制显示
3. **菜单组件**：使用 SwiftUI 的 `Menu` 和 `Section` 组织菜单结构

### 代码示例

```swift
// 在 CompanionView 中
@State private var showDigitalTwin = false
@State private var showBrainHealth = false

// 菜单按钮
Menu {
    Button(action: { showDigitalTwin = true }) {
        Label("Digital Twin", systemImage: "figure.stand")
    }
} label: {
    Image(systemName: "line.3.horizontal")
}

// Sheet修饰符
.sheet(isPresented: $showDigitalTwin) {
    DigitalTwinView()
}
```

---

## 📝 页面列表快速索引

### 已集成到导航的页面

| 页面名称 | 文件路径 | 主要入口 | 状态 |
|---------|---------|---------|------|
| AI伴侣 | `CompanionView.swift` | ContentView Tab 1 | ✅ 主页面 |
| 设置 | `SettingsView.swift` | ContentView Tab 2 / CompanionView 菜单 | ✅ 已集成 |
| 3D数字孪生 | `DigitalTwinPage.swift` | CompanionView 菜单 | ✅ 已集成 |
| 3D模型视图 | `HumanModelView.swift` | 被 DigitalTwinPage 使用 | ✅ 已集成 |
| 医疗仪表板 | `SimpleMedicalDashboardView.swift` | CompanionView 菜单 | ✅ 已集成 |
| 大脑健康 | `BrainHealthView.swift` | CompanionView 菜单 / DigitalTwinPage | ✅ 已集成 |
| 心脏健康 | `HeartHealthView.swift` | CompanionView 菜单 / DigitalTwinPage | ✅ 已集成 |
| 引导页 | `OnboardingView.swift` | 首次启动 | ✅ 已集成 |
| 主导航容器 | `ContentView.swift` | AppEntryView | ✅ TabView |
| 应用入口 | `AppEntryView.swift` | LumaApp | ✅ 入口 |

### 医疗相关页面（未集成）

| 页面名称 | 文件路径 | 功能 | 状态 |
|---------|---------|------|------|
| 医疗概览 | `MedicalOverviewView.swift` | 医疗历史概览 | ⚠️ 未集成 |
| 时间线 | `TimelineView.swift` | 健康事件时间线 | ⚠️ 未集成 |
| 生物识别数据 | `BiometricDataView.swift` | 详细数据记录 | ⚠️ 未集成 |
| 行为模式 | `BehavioralPatternsView.swift` | AI行为分析 | ⚠️ 未集成 |
| 导出分享 | `ExportSharingView.swift` | 数据导出 | ⚠️ 未集成 |
| 隐私安全 | `PrivacySecurityView.swift` | 隐私设置 | ⚠️ 未集成 |
| 完整医疗仪表板 | `MedicalDashboardView.swift` | Charts版本 | ⚠️ 暂未使用 |
| 用户档案 | `ProfileView.swift` | 个人资料 | ⚠️ 未集成 |

### 已删除的页面

| 页面名称 | 原文件路径 | 删除原因 |
|---------|-----------|---------|
| 应对技能 | `CopingSkillsView.swift` | 不需要 |
| 数字孪生视图 | `DigitalTwinView.swift` | 已被 DigitalTwinPage 替代 |
| 主标签视图 | `MainTabView.swift` | 与 ContentView 重复 |
| 行走头像底部视图 | `WalkingAvatarBottomView.swift` | 不需要 |

---

## 🎯 重要说明

1. **ContentView 是主导航容器**：使用 TabView 提供底部标签栏导航
2. **CompanionView 是主要页面（Tab 1）**：AI伴侣交互，包含左上角菜单访问所有健康功能
3. **SettingsView 是第二个标签（Tab 2）**：设置和个人资料
4. **左上角菜单是主要导航方式**：用户可以通过菜单快速访问健康相关功能
5. **DigitalTwinPage 提供交互式3D访问**：通过点击3D模型的不同部位跳转到对应健康页面
6. **所有健康页面都是模态弹出**：使用 sheet 方式，用户可以向下滑动或点击关闭按钮返回
7. **DigitalTwinPage 尚未集成**：建议添加到 CompanionView 菜单或作为第三个 Tab

---

## 🔧 如何添加新页面到导航

如果需要添加新页面到导航系统：

1. 在 `CompanionView` 中添加状态变量：
   ```swift
   @State private var showNewPage = false
   ```

2. 在左上角菜单中添加按钮：
   ```swift
   Button(action: { showNewPage = true }) {
       Label("New Page", systemImage: "icon.name")
   }
   ```

3. 添加 sheet 修饰符：
   ```swift
   .sheet(isPresented: $showNewPage) {
       NewPageView()
   }
   ```

---

---

## 📊 统计信息

- **已集成页面数量**：10个
- **未集成页面数量**：8个
- **已删除页面数量**：4个
- **总计页面数量**：22个文件

---

**文档创建时间**：2025年10月9日  
**最后更新**：2025年10月9日  
**版本**：2.0（完整重写）

---

## 🚀 建议的下一步

1. **✅ 已完成：集成 DigitalTwinPage**
   - 已添加到 CompanionView 左上角菜单
   - 用户可以通过 "Main Features" → "Digital Twin" 访问

2. **集成其他医疗页面**
   - 可以创建一个"Medical Records"子菜单
   - 包含：TimelineView, BiometricDataView, BehavioralPatternsView等

3. **优化 SimpleMedicalDashboardView**
   - 添加更多数据可视化
   - 链接到详细页面（如 TimelineView）

4. **完善 SettingsView**
   - 添加隐私设置入口（链接到 PrivacySecurityView）
   - 添加数据导出入口（链接到 ExportSharingView）

