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
        sceneView.autoenablesDefaultLighting = true       // default lighting
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = .clear

        // load 3D model
        if let url = Bundle.main.url(forResource: "human_base", withExtension: "usdc"),
           let srcScene = try? SCNScene(url: url, options: nil) {

            // Mount the model to a container node
            let modelNode = SCNNode()
            for child in srcScene.rootNode.childNodes {
                modelNode.addChildNode(child)
            }
            
            modelNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)

            // hot spot fact
            func createHotspot(name: String, color: UIColor, position: SCNVector3) -> SCNNode {
                let sphere = SCNSphere(radius: 0.1)
                let mat = sphere.firstMaterial!
                mat.diffuse.contents   = UIColor.clear
                mat.emission.contents  = color.withAlphaComponent(0.9)
                mat.lightingModel      = .constant

                let node = SCNNode(geometry: sphere)
                node.name = name
                node.position = position
                return node
            }

            // hot spots for each part
            let heartHotspot   = createHotspot(name: "HeartHotspot",   color: .red,    position: SCNVector3(-2.18, -0.12, 1.25))
            let headHotspot    = createHotspot(name: "HeadHotspot",    color: .blue,   position: SCNVector3(-2.26, -0.08, 1.6))
            let stomachHotspot = createHotspot(name: "StomachHotspot", color: .green,  position: SCNVector3(-2.26, -0.10, 1.15))
            let abdomenHotspot = createHotspot(name: "AbdomenHotspot", color: .orange, position: SCNVector3(-2.26, -0.10, 1.00))
            let leftArmHotspot = createHotspot(name: "LeftArmHotspot", color: .purple, position: SCNVector3(-2.55,  0.00, 1.08))
            let rightArmHotspot = createHotspot(name: "RightArmHotspot",color: .purple, position: SCNVector3(-1.98,  0.00, 1.08))
            let leftLegHotspot = createHotspot(name: "LeftLegHotspot", color: .yellow, position: SCNVector3(-2.40, -0.10, 0.45))
            let rightLegHotspot = createHotspot(name: "RightLegHotspot",color: .yellow, position: SCNVector3(-2.12, -0.10, 0.45))

            [heartHotspot, headHotspot, stomachHotspot, abdomenHotspot,
             leftArmHotspot, rightArmHotspot, leftLegHotspot, rightLegHotspot]
                .forEach { modelNode.addChildNode($0) }

            // new scene
            let scene = SCNScene()
            scene.rootNode.addChildNode(modelNode)
            sceneView.scene = scene
        }

        // click
        let tap = UITapGestureRecognizer(target: context.coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tap)

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    // MARK: - Coordinator
    class Coordinator: NSObject {
        let parent: HumanModelView
        init(parent: HumanModelView) { self.parent = parent }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView else { return }
            let location   = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])

            guard let result = hitResults.first else { return }
            let nodeName = result.node.name ?? "unknown"
            print("👉 Tap on: \(nodeName)")

            // only respond to the hot spots
            let hotspots: Set<String> = [
                "HeartHotspot", "HeadHotspot", "StomachHotspot",
                "AbdomenHotspot", "LeftArmHotspot", "RightArmHotspot",
                "LeftLegHotspot", "RightLegHotspot"
            ]
            guard hotspots.contains(nodeName) else { return }

            // redirection
            switch nodeName {
            case "HeartHotspot":
                parent.navigateToHeartRate = true
            case "HeadHotspot":
                print("➡️ Go to Head page")
            case "StomachHotspot":
                print("➡️ Go to Stomach page")
            case "AbdomenHotspot":
                print("➡️ Go to Abdomen page")
            case "LeftArmHotspot", "RightArmHotspot":
                print("➡️ Go to Arm page")
            case "LeftLegHotspot", "RightLegHotspot":
                print("➡️ Go to Leg page")
            default:
                break
            }
        }
    }
}

#Preview {
    HumanModelView(navigateToHeartRate: .constant(false))
}
