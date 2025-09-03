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
        sceneView.autoenablesDefaultLighting = false   // 用自定义灯光
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.systemBackground
        
        // load .usdc model
        if let sceneURL = Bundle.main.url(forResource: "human_base", withExtension: "usdc"),
           let scene = try? SCNScene(url: sceneURL, options: nil) {
            
            // ✅ 模型
            let modelNode = SCNNode()
            for child in scene.rootNode.childNodes {
                // 应用科技感材质
                if let material = child.geometry?.firstMaterial {
                    material.diffuse.contents = UIColor(white: 0.95, alpha: 1.0) // 偏白灰
                    material.metalness.contents = 0.6
                    material.roughness.contents = 0.3
                    material.lightingModel = .physicallyBased
                    material.emission.contents = UIColor.black
                }
                modelNode.addChildNode(child)
            }
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
            
            // 创建热点球体函数，方便复用
            func createHotspot(name: String, color: UIColor, position: SCNVector3) -> SCNNode {
                let sphere = SCNSphere(radius: 0.08) // 统一大小，可微调
                sphere.firstMaterial?.diffuse.contents = color.withAlphaComponent(0.6)
                let node = SCNNode(geometry: sphere)
                node.name = name
                node.position = position
                return node
            }

            // 在模型挂载完成后，添加多个热点
            let heartHotspot = createHotspot(
                name: "HeartHotspot",
                color: .red,
                position: SCNVector3(-2.13, -0.12, 1.25)  // 已调好的心脏位置
            )
            modelNode.addChildNode(heartHotspot)

            let headHotspot = createHotspot(
                name: "HeadHotspot",
                color: .blue,
                position: SCNVector3(-2.26, -0.08, 1.6)   // 头部，大概在上方
            )
            modelNode.addChildNode(headHotspot)

            let stomachHotspot = createHotspot(
                name: "StomachHotspot",
                color: .green,
                position: SCNVector3(-2.26, -0.1, 1.15)  // 胃部，心脏下移
            )
            modelNode.addChildNode(stomachHotspot)

            let abdomenHotspot = createHotspot(
                name: "AbdomenHotspot",
                color: .orange,
                position: SCNVector3(-2.26, -0.1, 1) // 腹部，再往下
            )
            modelNode.addChildNode(abdomenHotspot)

            // 四肢热点（四个点）
            let leftArmHotspot = createHotspot(
                name: "LeftArmHotspot",
                color: .purple,
                position: SCNVector3(-2.55, 0.0, 1.08) // 左臂
            )
            modelNode.addChildNode(leftArmHotspot)

            let rightArmHotspot = createHotspot(
                name: "RightArmHotspot",
                color: .purple,
                position: SCNVector3(-1.96, 0.0, 1.08) // 右臂
            )
            modelNode.addChildNode(rightArmHotspot)

//            let leftLegHotspot = createHotspot(
//                name: "LeftLegHotspot",
//                color: .yellow,
//                position: SCNVector3(-2.6, -0.3, -1.5) // 左腿
//            )
//            modelNode.addChildNode(leftLegHotspot)
//
//            let rightLegHotspot = createHotspot(
//                name: "RightLegHotspot",
//                color: .yellow,
//                position: SCNVector3(-1.7, -0.3, -1.5) // 右腿
//            )
//            modelNode.addChildNode(rightLegHotspot)
            
            // ✅ 场景
            let newScene = SCNScene()
            newScene.rootNode.addChildNode(modelNode)
                        
            // ✅ 顶部聚光灯
            let spotlightNode = SCNNode()
            let spotlight = SCNLight()
            spotlight.type = .spot
            spotlight.color = UIColor.white
            spotlight.intensity = 2000
            spotlight.castsShadow = true
            spotlight.spotOuterAngle = 50
            spotlightNode.light = spotlight
            spotlightNode.position = SCNVector3(0, 5, 5)
            spotlightNode.eulerAngles = SCNVector3(-Float.pi/4, 0, 0)
            newScene.rootNode.addChildNode(spotlightNode)
            
            // ✅ 环境光（柔和）
            let ambientLightNode = SCNNode()
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.color = UIColor(white: 0.6, alpha: 1.0)
            ambientLight.intensity = 400
            ambientLightNode.light = ambientLight
            newScene.rootNode.addChildNode(ambientLightNode)
            
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
                
                if nodeName == "HeartHotspot" {
                    parent.navigateToHeartRate = true
                }
            }
        }
    }
}

#Preview {
    HumanModelView(navigateToHeartRate: .constant(false))
}
