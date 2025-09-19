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
        sceneView.autoenablesDefaultLighting = true   // default lighting
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .clear            // background
        
        // load model
        if let sceneURL = Bundle.main.url(forResource: "human_base", withExtension: "usdc"),
           let scene = try? SCNScene(url: sceneURL, options: nil) {
            
            // ✅ model node
            let modelNode = SCNNode()
            for child in scene.rootNode.childNodes {
                modelNode.addChildNode(child)
            }
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
            
            let spin = SCNAction.repeatForever(
                SCNAction.rotateBy(x: 0, y: 0, z: 0, duration: 20)
            )
            modelNode.runAction(spin)
            
            // ✅ hot spot factory
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
            
            // ✅ add some hotspots
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
            
            // ✅ scene
            let newScene = SCNScene()
            newScene.rootNode.addChildNode(modelNode)
            sceneView.scene = newScene
        }
        
        // ✅ click
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
                
                // if not a hotspot -> return
                        let hotspotNames: Set<String> = [
                            "HeartHotspot", "HeadHotspot", "StomachHotspot",
                            "AbdomenHotspot", "LeftArmHotspot", "RightArmHotspot",
                            "LeftLegHotspot", "RightLegHotspot",
                        ]
                        guard hotspotNames.contains(nodeName) else { return }
                
                // ✅ Universal aperture animation
                let pulse = SCNPlane(width: 0.1, height: 0.1)
                pulse.cornerRadius = 0.1
                pulse.firstMaterial?.diffuse.contents = UIColor.cyan.withAlphaComponent(0.6)
                pulse.firstMaterial?.isDoubleSided = true
                pulse.firstMaterial?.lightingModel = .constant
                
                let pulseNode = SCNNode(geometry: pulse)
                var pulsePosition = result.node.worldPosition
                pulsePosition.z += 0.15  // Fix it slightly outward
                pulseNode.position = pulsePosition
                pulseNode.constraints = [SCNBillboardConstraint()]
                
                let expand = SCNAction.scale(to: 2.0, duration: 0.6)
                let fadeOut = SCNAction.fadeOut(duration: 0.6)
                let remove = SCNAction.removeFromParentNode()
                let sequence = SCNAction.sequence([SCNAction.group([expand, fadeOut]), remove])
                
                sceneView.scene?.rootNode.addChildNode(pulseNode)
                pulseNode.runAction(sequence)
                
                // ✅ redirection
                switch nodeName {
                case "HeartHotspot":
                    parent.navigateToHeartRate = true
                case "HeadHotspot":
                    print("👉 jump to head page")
                case "StomachHotspot":
                    print("👉 jump to stomach page")
                case "AbdomenHotspot":
                    print("👉 jump to abdomen page")
                case "LeftArmHotspot", "RightArmHotspot":
                    print("👉 jump to arm page")
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
