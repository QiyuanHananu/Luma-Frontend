//
//  HumanModelView.swift
//  Luma
//
//  Created by Jiaoyang Liu on 3/9/2025.
//

import SwiftUI
import SceneKit

struct HumanModelView: UIViewRepresentable {
    @Binding var navigateToHeartRate: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.autoenablesDefaultLighting = true   // 保留默认光照，避免全黑
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .clear            // 去掉背景色，透明背景
        
        // 加载模型
        if let sceneURL = Bundle.main.url(forResource: "human_base", withExtension: "usdc"),
           let scene = try? SCNScene(url: sceneURL, options: nil) {
            
            // ✅ 模型节点
            let modelNode = SCNNode()
            for child in scene.rootNode.childNodes {
                modelNode.addChildNode(child)
            }
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
            
            let spin = SCNAction.repeatForever(
                SCNAction.rotateBy(x: 0, y: 0, z: 0, duration: 20)
            )
            modelNode.runAction(spin)
            
            // ✅ 热点工厂
            func createHotspot(name: String, color: UIColor, position: SCNVector3) -> SCNNode {
                let sphere = SCNSphere(radius: 0.1)
                sphere.firstMaterial?.diffuse.contents = UIColor.clear
                sphere.firstMaterial?.emission.contents = color.withAlphaComponent(0.9)
                sphere.firstMaterial?.lightingModel = .constant
                let node = SCNNode(geometry: sphere)
                node.name = name
                node.position = position
                return node
            }
            
            // ✅ 添加热点（位置保持不变）
            let heartHotspot = createHotspot(name: "HeartHotspot", color: .red, position: SCNVector3(-2.26, -0.12, 1.2))
            let headHotspot = createHotspot(name: "HeadHotspot", color: .blue, position: SCNVector3(-2.26, -0.08, 1.6))
            let stomachHotspot = createHotspot(name: "StomachHotspot", color: .green, position: SCNVector3(-2.26, -0.1, 1.15))
            let abdomenHotspot = createHotspot(name: "AbdomenHotspot", color: .orange, position: SCNVector3(-2.26, -0.1, 1))
            let leftArmHotspot = createHotspot(name: "LeftArmHotspot", color: .purple, position: SCNVector3(-2.55, 0.0, 1.08))
            let rightArmHotspot = createHotspot(name: "RightArmHotspot", color: .purple, position: SCNVector3(-1.98, 0.0, 1.08))
            let leftLegHotspot = createHotspot(name: "LeftLegHotspot",color: .yellow, position: SCNVector3(-2.4, -0.1, 0.45))
            let rightLegHotspot = createHotspot(name: "RightLegHotspot",color: .yellow, position: SCNVector3(-2.12, -0.1, 0.45))
            
            [heartHotspot, headHotspot, stomachHotspot, abdomenHotspot, leftArmHotspot, rightArmHotspot, leftLegHotspot, rightLegHotspot].forEach {
                modelNode.addChildNode($0)
            }
            
            // ✅ 场景
            let newScene = SCNScene()
            newScene.rootNode.addChildNode(modelNode)
            sceneView.scene = newScene
        }
        
        // ✅ 点击事件
        let tapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: HumanModelView
        
        init(parent: HumanModelView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let sceneView = gesture.view as! SCNView
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])
            
            if let result = hitResults.first {
                let nodeName = result.node.name ?? "unknown"
                print("👉 You clicked on: \(nodeName)")
                
                // 🚨 如果不是热点，直接返回，不做任何处理
                        let hotspotNames: Set<String> = [
                            "HeartHotspot", "HeadHotspot", "StomachHotspot",
                            "AbdomenHotspot", "LeftArmHotspot", "RightArmHotspot",
                            "LeftLegHotspot", "RightLegHotspot",
                        ]
                        guard hotspotNames.contains(nodeName) else { return }
                
                // ✅ 通用光圈动画
                let pulse = SCNPlane(width: 0.1, height: 0.1)
                pulse.cornerRadius = 0.1
                pulse.firstMaterial?.diffuse.contents = UIColor.cyan.withAlphaComponent(0.6)
                pulse.firstMaterial?.isDoubleSided = true
                pulse.firstMaterial?.lightingModel = .constant
                
                let pulseNode = SCNNode(geometry: pulse)
                var pulsePosition = result.node.worldPosition
                pulsePosition.z += 0.15  // 固定往外偏移一点，保证不会卡进身体
                pulseNode.position = pulsePosition
                pulseNode.constraints = [SCNBillboardConstraint()]
                
                let expand = SCNAction.scale(to: 2.0, duration: 0.6)
                let fadeOut = SCNAction.fadeOut(duration: 0.6)
                let remove = SCNAction.removeFromParentNode()
                let sequence = SCNAction.sequence([SCNAction.group([expand, fadeOut]), remove])
                
                sceneView.scene?.rootNode.addChildNode(pulseNode)
                pulseNode.runAction(sequence)
                
                // ✅ 跳转逻辑
                switch nodeName {
                case "HeartHotspot":
                    parent.navigateToHeartRate = true
                case "HeadHotspot":
                    print("👉 跳转到头部页面")
                case "StomachHotspot":
                    print("👉 跳转到胃部页面")
                case "AbdomenHotspot":
                    print("👉 跳转到腹部页面")
                case "LeftArmHotspot", "RightArmHotspot":
                    print("👉 跳转到手臂页面")
                default:
                    break
                }
            }
        }
    }
}

#Preview {
    HumanModelView(navigateToHeartRate: .constant(false))
}
