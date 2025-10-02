//
//  DigitalTwinView.swift
//  Luma - AI健康伴侣应用
//
//  功能说明：
//  - 3D数字孪生人体模型展示
//  - 支持点击不同身体部位跳转到对应健康页面
//  - 头部点击跳转到大脑健康页面
//  - 胸部点击跳转到心脏健康页面
//  - 支持360度旋转查看模型
//
//  Created by Han on 23/8/2025.
//

import SwiftUI
import SceneKit

struct DigitalTwinView: View {
    @State private var showBrainHealth = false
    @State private var showHeartHealth = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 标题栏
                headerView
                
                // 3D人体模型
                Interactive3DHumanView(
                    onHeadTap: {
                        showBrainHealth = true
                    },
                    onChestTap: {
                        showHeartHealth = true
                    }
                )
                
                // 底部提示
                instructionView
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showBrainHealth) {
            BrainHealthView()
        }
        .sheet(isPresented: $showHeartHealth) {
            HeartHealthView()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Digital Twin")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Tap different body parts to explore your health data")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var instructionView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                InstructionItem(
                    icon: "brain.head.profile",
                    title: "Head",
                    subtitle: "Brain Health",
                    color: .blue
                )
                
                InstructionItem(
                    icon: "heart.fill",
                    title: "Chest",
                    subtitle: "Heart Health",
                    color: .red
                )
            }
            
            Text("Rotate the model with gestures • Double tap to reset view")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

struct InstructionItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30, height: 30)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct Interactive3DHumanView: UIViewRepresentable {
    let onHeadTap: () -> Void
    let onChestTap: () -> Void
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = SCNScene()
        scnView.backgroundColor = UIColor.systemBackground
        scnView.antialiasingMode = .multisampling4X
        scnView.allowsCameraControl = false // 禁用默认相机控制
        
        // 设置相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.position = SCNVector3(0, 0, 8)
        scnView.scene?.rootNode.addChildNode(cameraNode)
        
        // 添加光源
        setupLighting(in: scnView.scene!)
        
        // 加载3D模型
        loadHumanModel(in: scnView.scene!, context: context)
        
        // 添加手势识别
        setupGestures(for: scnView, context: context)
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // 更新视图时的逻辑
    }
    
    private func setupLighting(in scene: SCNScene) {
        // 环境光
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        scene.rootNode.addChildNode(ambientLight)
        
        // 主光源
        let directionalLight = SCNNode()
        directionalLight.light = SCNLight()
        directionalLight.light?.type = .directional
        directionalLight.light?.intensity = 800
        directionalLight.position = SCNVector3(2, 4, 6)
        directionalLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(directionalLight)
        
        // 补光
        let fillLight = SCNNode()
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.intensity = 400
        fillLight.position = SCNVector3(-2, 2, 4)
        fillLight.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(fillLight)
    }
    
    private func loadHumanModel(in scene: SCNScene, context: Context) {
        // 创建模型容器
        let modelContainer = SCNNode()
        context.coordinator.modelContainer = modelContainer
        scene.rootNode.addChildNode(modelContainer)
        
        // 尝试加载不同格式的3D模型
        let modelNames = ["humanmodel2.usdz", "humanmodel2.usdc", "humanmodel2.scn", "human_base.usdc"]
        var modelLoaded = false
        
        for modelName in modelNames {
            if let modelURL = Bundle.main.url(forResource: modelName.components(separatedBy: ".").first, withExtension: modelName.components(separatedBy: ".").last) {
                do {
                    let modelScene = try SCNScene(url: modelURL)
                    
                    // 将模型添加到容器中
                    for child in modelScene.rootNode.childNodes {
                        modelContainer.addChildNode(child)
                    }
                    
                    // 调整模型
                    setupModelTransform(modelContainer)
                    
                    // 设置点击区域
                    setupClickableAreas(modelContainer, context: context)
                    
                    modelLoaded = true
                    print("✅ 成功加载3D模型: \(modelName)")
                    break
                } catch {
                    print("❌ 加载模型失败 \(modelName): \(error)")
                    continue
                }
            }
        }
        
        if !modelLoaded {
            // 如果没有找到模型，创建简化的人体形状
            createFallbackHumanShape(in: modelContainer, context: context)
        }
    }
    
    private func setupModelTransform(_ modelContainer: SCNNode) {
        // 计算模型边界
        let (minVec, maxVec) = modelContainer.boundingBox
        let modelSize = SCNVector3(
            maxVec.x - minVec.x,
            maxVec.y - minVec.y,
            maxVec.z - minVec.z
        )
        
        // 计算缩放比例，目标高度为4个单位
        let targetHeight: Float = 4.0
        let currentHeight = modelSize.y
        let scale = targetHeight / currentHeight
        
        // 应用缩放
        modelContainer.scale = SCNVector3(scale, scale, scale)
        
        // 居中模型
        let center = SCNVector3(
            (minVec.x + maxVec.x) / 2,
            (minVec.y + maxVec.y) / 2,
            (minVec.z + maxVec.z) / 2
        )
        modelContainer.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        
        // 设置初始旋转（正面朝向用户）
        modelContainer.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
    }
    
    private func createFallbackHumanShape(in container: SCNNode, context: Context) {
        // 创建简化的人体形状
        
        // 头部 (球体) - 扩大点击范围
        let headGeometry = SCNSphere(radius: 0.35)
        headGeometry.firstMaterial?.diffuse.contents = UIColor.systemBlue
        let headNode = SCNNode(geometry: headGeometry)
        headNode.position = SCNVector3(0, 1.5, 0)
        headNode.name = "head"
        container.addChildNode(headNode)
        print("✅ 创建头部节点: head")
        
        // 身体 (圆柱体) - 扩大点击范围
        let bodyGeometry = SCNCylinder(radius: 0.5, height: 1.4)
        bodyGeometry.firstMaterial?.diffuse.contents = UIColor.systemGreen
        let bodyNode = SCNNode(geometry: bodyGeometry)
        bodyNode.position = SCNVector3(0, 0.4, 0)
        bodyNode.name = "chest"
        container.addChildNode(bodyNode)
        print("✅ 创建胸部节点: chest")
        
        // 手臂 (圆柱体)
        let armGeometry = SCNCylinder(radius: 0.1, height: 0.8)
        armGeometry.firstMaterial?.diffuse.contents = UIColor.systemOrange
        
        let leftArmNode = SCNNode(geometry: armGeometry)
        leftArmNode.position = SCNVector3(-0.6, 0.6, 0)
        leftArmNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        leftArmNode.name = "leftArm"
        container.addChildNode(leftArmNode)
        
        let rightArmNode = SCNNode(geometry: armGeometry)
        rightArmNode.position = SCNVector3(0.6, 0.6, 0)
        rightArmNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        rightArmNode.name = "rightArm"
        container.addChildNode(rightArmNode)
        
        // 腿部 (圆柱体)
        let legGeometry = SCNCylinder(radius: 0.15, height: 1.0)
        legGeometry.firstMaterial?.diffuse.contents = UIColor.systemPurple
        
        let leftLegNode = SCNNode(geometry: legGeometry)
        leftLegNode.position = SCNVector3(-0.2, -0.7, 0)
        leftLegNode.name = "leftLeg"
        container.addChildNode(leftLegNode)
        
        let rightLegNode = SCNNode(geometry: legGeometry)
        rightLegNode.position = SCNVector3(0.2, -0.7, 0)
        rightLegNode.name = "rightLeg"
        container.addChildNode(rightLegNode)
        
        // 设置点击区域
        setupClickableAreas(container, context: context)
        
        print("✅ 创建了简化人体模型，头部和胸部点击区域已扩大")
    }
    
    private func setupClickableAreas(_ modelContainer: SCNNode, context: Context) {
        // 为头部和胸部区域创建更大的不可见点击区域
        
        // 头部点击区域 (扩大范围) - 临时可见用于调试
        let headClickGeometry = SCNSphere(radius: 0.6) // 比实际头部大很多
        headClickGeometry.firstMaterial?.diffuse.contents = UIColor.blue // 蓝色半透明
        headClickGeometry.firstMaterial?.transparency = 0.3 // 半透明，可以看到点击区域
        let headClickNode = SCNNode(geometry: headClickGeometry)
        headClickNode.position = SCNVector3(0, 1.5, 0)
        headClickNode.name = "headClickArea"
        modelContainer.addChildNode(headClickNode)
        print("✅ 创建头部点击区域: headClickArea")
        
        // 胸部点击区域 (扩大范围) - 临时可见用于调试
        let chestClickGeometry = SCNCylinder(radius: 0.8, height: 1.8) // 比实际胸部大很多
        chestClickGeometry.firstMaterial?.diffuse.contents = UIColor.red // 红色半透明
        chestClickGeometry.firstMaterial?.transparency = 0.3 // 半透明，可以看到点击区域
        let chestClickNode = SCNNode(geometry: chestClickGeometry)
        chestClickNode.position = SCNVector3(0, 0.4, 0)
        chestClickNode.name = "chestClickArea"
        modelContainer.addChildNode(chestClickNode)
        print("✅ 创建胸部点击区域: chestClickArea")
        
        print("✅ 设置了扩大的点击区域 - 头部半径0.6，胸部半径0.8，透明度0.01")
    }
    
    private func setupGestures(for scnView: SCNView, context: Context) {
        // 点击手势
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // 旋转手势
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.delegate = context.coordinator
        scnView.addGestureRecognizer(panGesture)
        
        // 双击重置手势
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = context.coordinator
        scnView.addGestureRecognizer(doubleTapGesture)
        
        // 确保单击和双击不冲突
        tapGesture.require(toFail: doubleTapGesture)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: Interactive3DHumanView
        var modelContainer: SCNNode?
        var lastPanLocation: CGPoint?
        var initialRotationY: Float = 0
        var initialRotationX: Float = 0
        
        init(_ parent: Interactive3DHumanView) {
            self.parent = parent
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false // 避免手势冲突
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let scnView = gestureRecognizer.view as? SCNView else { 
                print("❌ 无法获取SCNView")
                return 
            }
            
            let location = gestureRecognizer.location(in: scnView)
            print("👆 点击位置: \(location)")
            
            let hitResults = scnView.hitTest(location, options: [:])
            print("🎯 hitTest结果数量: \(hitResults.count)")
            
            if hitResults.isEmpty {
                print("⚠️ 没有检测到任何节点")
                return
            }
            
            for (index, result) in hitResults.enumerated() {
                let nodeName = result.node.name ?? "unnamed"
                print("📍 节点\(index): \(nodeName), 位置: \(result.node.position)")
                
                // 检查是否点击了头部区域 (扩大匹配范围)
                if nodeName.contains("head") || nodeName == "headClickArea" {
                    print("🧠 触发头部点击 - 跳转到BrainHealthView")
                    DispatchQueue.main.async {
                        self.parent.onHeadTap()
                    }
                    return
                }
                
                // 检查是否点击了胸部区域 (扩大匹配范围)
                if nodeName.contains("chest") || nodeName.contains("body") || nodeName == "chestClickArea" {
                    print("❤️ 触发胸部点击 - 跳转到HeartHealthView")
                    DispatchQueue.main.async {
                        self.parent.onChestTap()
                    }
                    return
                }
            }
            
            print("⚠️ 点击的区域不是头部或胸部")
        }
        
        @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
            guard let scnView = gestureRecognizer.view as? SCNView,
                  let modelContainer = modelContainer else { return }
            
            let translation = gestureRecognizer.translation(in: scnView)
            
            if gestureRecognizer.state == .began {
                lastPanLocation = translation
                initialRotationY = modelContainer.eulerAngles.y
                initialRotationX = modelContainer.eulerAngles.x
            } else if gestureRecognizer.state == .changed {
                guard let lastLocation = lastPanLocation else { return }
                let deltaX = Float(translation.x - lastLocation.x)
                let deltaY = Float(translation.y - lastLocation.y)
                
                // 旋转速度
                let rotationSpeed: Float = 0.005
                let newRotationY = initialRotationY - deltaX * rotationSpeed // 水平旋转
                let newRotationX = initialRotationX - deltaY * rotationSpeed // 垂直旋转
                
                // 限制垂直旋转范围
                let clampedRotationX = max(-Float.pi/2 - 0.5, min(-Float.pi/2 + 0.5, newRotationX))
                
                modelContainer.eulerAngles = SCNVector3(clampedRotationX, newRotationY, modelContainer.eulerAngles.z)
            }
        }
        
        @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            guard let modelContainer = modelContainer else { return }
            
            // 重置到初始正面视角
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            modelContainer.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            SCNTransaction.commit()
            
            print("🔄 重置视角到正面")
        }
    }
}

// MARK: - 枚举定义
enum DigitalTwinTimeRange: CaseIterable {
    case day, week, month, threeMonths
}

#Preview {
    DigitalTwinView()
}
