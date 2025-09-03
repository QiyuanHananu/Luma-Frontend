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

        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = UIColor.systemBackground

        // load .usdc model
        if let sceneURL = Bundle.main.url(forResource: "human_base", withExtension: "usdc"),
           let scene = try? SCNScene(url: sceneURL, options: nil) {

            // 把模型作为子节点挂到 rootNode 上
            let modelNode = SCNNode()
            for child in scene.rootNode.childNodes {
                modelNode.addChildNode(child)
            }
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
            
            // 创建一个小球当心脏热点区域
            let heartSphere = SCNSphere(radius: 0.08)  // 半径可以调整
            heartSphere.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.8)
            
            let heartHotspot = SCNNode(geometry: heartSphere)
            heartHotspot.name = "HeartHotspot"
            // 放在相对模型的局部坐标（先随便放，调试再改）
            heartHotspot.position = SCNVector3(-2.15, -0.12, 1.25)

            // 把小球挂到模型节点
            modelNode.addChildNode(heartHotspot)
            
            // 添加到新场景里
            let newScene = SCNScene()
            newScene.rootNode.addChildNode(modelNode)

            // 设置相机
            let cameraNode = SCNNode()
            // 获取模型中心点
            let (min, max) = modelNode.boundingBox
            let center = SCNVector3(
                (min.x + max.x) / 2,
                (min.y + max.y) / 2,
                (min.z + max.z) / 2
            )

            // 设置相机指向这个点
            let constraint = SCNLookAtConstraint(target: modelNode)
            constraint.isGimbalLockEnabled = true
            cameraNode.constraints = [constraint]

            sceneView.scene = newScene
        }

        // Add click gestures
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
