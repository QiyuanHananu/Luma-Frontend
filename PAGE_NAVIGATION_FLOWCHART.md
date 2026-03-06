# Luma 应用页面导航流程图文档

**项目名称**: Luma - AI Health Companion  
**文档创建时间**: 2025年10月17日  
**版本**: 1.0  
**仓库**: Luma-Frontend (Han-fronted branch)

---

## 📱 完整页面列表

### 已集成页面（可访问）

| 编号 | 页面名称 | 文件路径 | 页面类型 | 状态 |
|-----|---------|---------|---------|------|
| 1 | 应用入口 | `AppEntryView.swift` | 入口页面 | ✅ 活跃 |
| 2 | 引导页 | `OnboardingView.swift` | 首次启动 | ✅ 活跃 |
| 3 | 主导航容器 | `ContentView.swift` | TabView容器 | ✅ 活跃 |
| 4 | AI伴侣 | `CompanionView.swift` | 主页面 | ✅ 活跃 |
| 5 | 设置 | `SettingsView.swift` | 设置页面 | ✅ 活跃 |
| 6 | 医疗仪表板 | `SimpleMedicalDashboardView.swift` | 健康数据 | ✅ 活跃 |
| 7 | 大脑健康 | `BrainHealthView.swift` | 健康详情 | ✅ 活跃 |
| 8 | 心脏健康 | `HeartHealthView.swift` | 健康详情 | ✅ 活跃 |

### 独立页面（需添加入口）

| 编号 | 页面名称 | 文件路径 | 页面类型 | 状态 |
|-----|---------|---------|---------|------|
| 9 | 3D数字孪生 | `DigitalTwinPage.swift` | 3D交互页面 | ⚠️ 未集成 |
| 10 | 3D模型视图 | `HumanModelView.swift` | 3D组件 | ⚠️ 被DigitalTwinPage使用 |

### 未集成医疗页面

| 编号 | 页面名称 | 文件路径 | 页面类型 | 状态 |
|-----|---------|---------|---------|------|
| 11 | 医疗概览 | `MedicalOverviewView.swift` | 医疗记录 | ⚠️ 未集成 |
| 12 | 时间线 | `TimelineView.swift` | 健康事件 | ⚠️ 未集成 |
| 13 | 生物识别数据 | `BiometricDataView.swift` | 详细数据 | ⚠️ 未集成 |
| 14 | 行为模式 | `BehavioralPatternsView.swift` | AI分析 | ⚠️ 未集成 |
| 15 | 导出分享 | `ExportSharingView.swift` | 数据导出 | ⚠️ 未集成 |
| 16 | 隐私安全 | `PrivacySecurityView.swift` | 隐私设置 | ⚠️ 未集成 |
| 17 | 完整医疗仪表板 | `MedicalDashboardView.swift` | Charts版本 | ⚠️ 暂未使用 |
| 18 | 用户档案 | `ProfileView.swift` | 个人资料 | ⚠️ 未集成 |

---

## 🔄 页面跳转关系详细说明

### 第一层：应用启动流程

```
┌─────────────────────────────────────────────────────────────┐
│                         启动流程                              │
└─────────────────────────────────────────────────────────────┘

[1] AppEntryView (应用入口)
    │
    ├─ 首次启动? YES ──→ [2] OnboardingView (引导页)
    │                         │
    │                         └──→ 完成引导 ──→ [3] ContentView
    │
    └─ 首次启动? NO ───→ [3] ContentView (主导航容器)
```

**截图需求**:
- **AppEntryView**: 判断逻辑页面（可能无UI）
- **OnboardingView**: 引导页的3-4个屏幕截图
- **箭头**: AppEntryView → OnboardingView → ContentView

---

### 第二层：主导航结构 (TabView)

```
┌─────────────────────────────────────────────────────────────┐
│                    ContentView (TabView)                     │
└─────────────────────────────────────────────────────────────┘

[3] ContentView
    │
    ├─ Tab 1 ──→ [4] CompanionView (AI伴侣) ⭐ 默认显示
    │
    └─ Tab 2 ──→ [5] SettingsView (设置)
```

**截图需求**:
- **ContentView**: 底部TabView的截图，显示两个标签
- **箭头**: 
  - ContentView → CompanionView (Tab 1)
  - ContentView → SettingsView (Tab 2)

---

### 第三层：CompanionView 的跳转关系

```
┌─────────────────────────────────────────────────────────────┐
│              [4] CompanionView (AI伴侣主页)                   │
│              - 左上角: 菜单按钮 (☰)                           │
│              - 中间: Luma AI 角色 + 对话气泡                  │
│              - 底部: 输入框 + 健康快照卡片                    │
└─────────────────────────────────────────────────────────────┘

从 CompanionView 可跳转到:

1. 左上角菜单 → 健康数据分组:
   ├─ [6] SimpleMedicalDashboardView (医疗仪表板)
   ├─ [7] BrainHealthView (大脑健康)
   └─ [8] HeartHealthView (心脏健康)

2. 左上角菜单 → 更多分组:
   ├─ Health Snapshot (切换底部健康快照显示/隐藏)
   └─ [5] SettingsView (设置)
```

**截图需求**:
- **CompanionView**: 主界面截图，显示左上角菜单按钮
- **菜单展开状态**: 显示所有菜单项的截图
- **箭头**:
  - CompanionView → SimpleMedicalDashboardView
  - CompanionView → BrainHealthView
  - CompanionView → HeartHealthView
  - CompanionView → SettingsView

---

### 第四层：独立页面 - DigitalTwinPage (3D数字孪生)

```
┌─────────────────────────────────────────────────────────────┐
│           [9] DigitalTwinPage (3D数字孪生页面)                │
│           - 显示: 3D人体模型 (使用 HumanModelView)            │
│           - 功能: 可旋转、点击身体部位                        │
│           - 底部提示: "Tap a body area to see insights"      │
└─────────────────────────────────────────────────────────────┘

从 DigitalTwinPage 可跳转到:

1. 点击 3D 模型头部 (HeadHotspot)
   └─→ [7] BrainHealthView (大脑健康)

2. 点击 3D 模型左胸 (LeftChestHotspot)
   └─→ [8] HeartHealthView (心脏健康)

3. 点击 3D 模型右胸 (RightChestHotspot)
   └─→ [8] HeartHealthView (心脏健康)
```

**截图需求**:
- **DigitalTwinPage**: 显示3D人体模型的截图
- **3D模型特写**: 标注头部、左胸、右胸的可点击区域
- **箭头**:
  - DigitalTwinPage (头部) → BrainHealthView
  - DigitalTwinPage (左胸/右胸) → HeartHealthView

**⚠️ 注意**: 此页面目前是独立页面，建议添加入口到 CompanionView 菜单

---

### 第五层：健康详情页面

#### [6] SimpleMedicalDashboardView (医疗仪表板)

```
┌─────────────────────────────────────────────────────────────┐
│          SimpleMedicalDashboardView (医疗仪表板)              │
│          - 显示: 简化版医疗数据概览                           │
│          - 功能: 基本数据可视化（无Charts框架）               │
└─────────────────────────────────────────────────────────────┘

当前状态: 终点页面，无跳转到其他页面
```

**截图需求**:
- **SimpleMedicalDashboardView**: 完整页面截图

---

#### [7] BrainHealthView (大脑健康)

```
┌─────────────────────────────────────────────────────────────┐
│              BrainHealthView (大脑健康页面)                   │
│              - 显示: 大脑相关健康数据和洞察                   │
└─────────────────────────────────────────────────────────────┘

可以从以下位置访问:
← [4] CompanionView (菜单)
← [9] DigitalTwinPage (点击头部)

当前状态: 终点页面，无跳转到其他页面
```

**截图需求**:
- **BrainHealthView**: 完整页面截图

---

#### [8] HeartHealthView (心脏健康)

```
┌─────────────────────────────────────────────────────────────┐
│              HeartHealthView (心脏健康页面)                   │
│              - 显示: 心脏相关健康数据和洞察                   │
└─────────────────────────────────────────────────────────────┘

可以从以下位置访问:
← [4] CompanionView (菜单)
← [9] DigitalTwinPage (点击胸部)

当前状态: 终点页面，无跳转到其他页面
```

**截图需求**:
- **HeartHealthView**: 完整页面截图

---

#### [5] SettingsView (设置)

```
┌─────────────────────────────────────────────────────────────┐
│                 SettingsView (设置页面)                       │
│                 - 显示: 应用设置和个人资料                    │
└─────────────────────────────────────────────────────────────┘

可以从以下位置访问:
← [3] ContentView (Tab 2)
← [4] CompanionView (菜单)

当前状态: 终点页面，无跳转到其他页面
```

**截图需求**:
- **SettingsView**: 完整页面截图

---

## 📊 完整导航流程图（文字版）

```
应用启动
    ↓
AppEntryView (入口判断)
    ↓
    ├─ 首次启动 → OnboardingView (引导) → ContentView
    └─ 已启动过 → ContentView
                     ↓
        ┌────────────┴────────────┐
        │                         │
    Tab 1                      Tab 2
CompanionView               SettingsView
(AI伴侣主页) ⭐                (设置)
    ↓
左上角菜单 (☰)
    ↓
    ├─ 健康数据
    │   ├─→ SimpleMedicalDashboardView (医疗仪表板)
    │   ├─→ BrainHealthView (大脑健康) ←┐
    │   └─→ HeartHealthView (心脏健康) ←┤
    │                                   │
    └─ 更多                              │
        ├─→ Health Snapshot (切换显示)    │
        └─→ SettingsView (设置)          │
                                        │
独立页面 (未集成):                        │
DigitalTwinPage (3D数字孪生)              │
    ↓                                   │
点击3D模型                               │
    ├─ 点击头部 ─────────────────────────┘
    └─ 点击胸部 (左/右) ─────────────────┘
```

---

## 🎯 截图清单 (按拍摄顺序)

### 启动流程 (3张)

1. **OnboardingView - 第1屏**
   - 文件: `OnboardingView.swift`
   - 说明: 引导页第一屏

2. **OnboardingView - 第2屏**
   - 文件: `OnboardingView.swift`
   - 说明: 引导页第二屏

3. **OnboardingView - 第3屏**
   - 文件: `OnboardingView.swift`
   - 说明: 引导页第三屏（完成按钮）

---

### 主导航 (2张)

4. **ContentView - TabView 显示 Tab 1**
   - 文件: `ContentView.swift`
   - 说明: 底部显示两个标签，当前选中 "Luma" 标签

5. **ContentView - TabView 显示 Tab 2**
   - 文件: `ContentView.swift`
   - 说明: 底部显示两个标签，当前选中 "Settings" 标签

---

### CompanionView (3张)

6. **CompanionView - 主界面**
   - 文件: `CompanionView.swift`
   - 说明: 显示Luma AI角色、对话气泡、底部输入框
   - 重点: 左上角菜单按钮 (☰)

7. **CompanionView - 菜单展开**
   - 文件: `CompanionView.swift`
   - 说明: 点击左上角菜单后的下拉菜单
   - 显示内容:
     - Health Data 分组
     - Medical Dashboard
     - Brain Health
     - Heart Health
     - More 分组
     - Health Snapshot
     - Settings

8. **CompanionView - 健康快照显示**
   - 文件: `CompanionView.swift`
   - 说明: 底部显示健康快照卡片

---

### DigitalTwinPage (2张)

9. **DigitalTwinPage - 正面视图**
   - 文件: `DigitalTwinPage.swift`
   - 说明: 3D人体模型正面视图
   - 标注: 头部、左胸、右胸的可点击区域

10. **DigitalTwinPage - 旋转后视图**
    - 文件: `DigitalTwinPage.swift`
    - 说明: 展示3D模型可旋转功能

---

### 健康详情页面 (4张)

11. **SimpleMedicalDashboardView**
    - 文件: `SimpleMedicalDashboardView.swift`
    - 说明: 医疗仪表板完整截图

12. **BrainHealthView**
    - 文件: `BrainHealthView.swift`
    - 说明: 大脑健康页面完整截图

13. **HeartHealthView**
    - 文件: `HeartHealthView.swift`
    - 说明: 心脏健康页面完整截图

14. **SettingsView**
    - 文件: `SettingsView.swift`
    - 说明: 设置页面完整截图

---

## 📐 制作导航流程图的步骤

### 使用 Figma (推荐)

1. **创建画布**
   - 创建一个大画布 (例如: 5000 x 3000 px)
   - 背景色设置为浅灰色 (#F5F5F5)

2. **导入截图**
   - 将所有14张截图导入到 Figma
   - 调整截图大小，保持一致（建议: 宽度 300-400px）

3. **布局页面**
   - **第一行**: OnboardingView (3张) → ContentView (1张)
   - **第二行**: CompanionView (3张) + DigitalTwinPage (2张)
   - **第三行**: 健康详情页面 (4张)

4. **添加箭头**
   - 使用 Figma 的箭头工具
   - 颜色: #007AFF (蓝色) 或 #FF3B30 (红色) 区分不同类型
   - 粗细: 3-4px
   - 样式: 实线箭头

5. **添加标注**
   - 页面名称: 字体 SF Pro Display, 粗体, 16-18pt
   - 跳转说明: 字体 SF Pro Text, 常规, 12-14pt
   - 颜色: 深灰色 (#333333)

6. **添加图例**
   - 右上角添加图例说明
   - 标注不同箭头的含义
   - 标注不同状态的页面（活跃/未集成）

7. **导出**
   - 导出为 PNG (2x 分辨率)
   - 或导出为 PDF (矢量格式，可缩放)

---

### 使用 PowerPoint/Keynote

1. **创建幻灯片**
   - 选择横向布局
   - 页面大小: 自定义 (例如: 16:9 宽屏)

2. **插入截图**
   - 将截图拖入幻灯片
   - 调整大小和位置

3. **添加连接线**
   - 使用 "形状" → "箭头连接器"
   - 连接各个截图

4. **添加文本框**
   - 标注页面名称和跳转说明

5. **导出**
   - 导出为 PDF 或 PNG

---

## 🔗 箭头连接关系表

| 起点页面 | 终点页面 | 触发方式 | 箭头颜色建议 |
|---------|---------|---------|------------|
| AppEntryView | OnboardingView | 首次启动 | 蓝色 |
| OnboardingView | ContentView | 完成引导 | 蓝色 |
| AppEntryView | ContentView | 已启动过 | 蓝色 |
| ContentView | CompanionView | Tab 1 | 绿色 |
| ContentView | SettingsView | Tab 2 | 绿色 |
| CompanionView | SimpleMedicalDashboardView | 菜单 → Medical Dashboard | 紫色 |
| CompanionView | BrainHealthView | 菜单 → Brain Health | 紫色 |
| CompanionView | HeartHealthView | 菜单 → Heart Health | 紫色 |
| CompanionView | SettingsView | 菜单 → Settings | 紫色 |
| DigitalTwinPage | BrainHealthView | 点击头部 | 橙色 |
| DigitalTwinPage | HeartHealthView | 点击左胸 | 橙色 |
| DigitalTwinPage | HeartHealthView | 点击右胸 | 橙色 |

---

## 📝 注意事项

### ⚠️ 未集成页面提示

以下页面在流程图中应标注为 **"未集成"** 或使用虚线框表示:
- DigitalTwinPage (建议添加到 CompanionView 菜单)
- MedicalOverviewView
- TimelineView
- BiometricDataView
- BehavioralPatternsView
- ExportSharingView
- PrivacySecurityView
- MedicalDashboardView (Charts版本)
- ProfileView

### 💡 建议标注

1. **主要路径**: 使用粗实线箭头（蓝色/绿色）
2. **次要路径**: 使用细实线箭头（紫色）
3. **3D交互**: 使用特殊箭头（橙色，带点击图标）
4. **未集成**: 使用虚线框和灰色文字

---

## 📧 文档用途

此文档可用于:
- ✅ 向客户展示应用导航结构
- ✅ 作为制作流程图的参考指南
- ✅ 开发团队内部沟通
- ✅ 新成员快速了解应用架构

---

**文档结束**

如有疑问，请参考 `NAVIGATION_LOGIC.md` 或 `README.md` 获取更多技术细节。

