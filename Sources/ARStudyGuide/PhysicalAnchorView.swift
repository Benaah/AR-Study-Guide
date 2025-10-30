import SwiftUI
import RealityKit
import ARKit

struct PhysicalAnchorView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure for object tracking
        // Note: Add reference objects to an asset catalog in Xcode
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Resources", bundle: nil) else {
            // Fallback to world tracking
            let configuration = ARWorldTrackingConfiguration()
            arView.session.run(configuration)
            return arView
        }
        
        let configuration = ARObjectTrackingConfiguration()
        configuration.trackingObjects = referenceObjects
        arView.session.run(configuration)
        
        arView.session.delegate = context.coordinator
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let objectAnchor = anchor as? ARObjectAnchor {
                    // Add 3D content on detected object
                    let anchorEntity = AnchorEntity(anchor: objectAnchor)
                    
                    // Example: Add interactive content
                    let sphere = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.05), materials: [SimpleMaterial(color: .blue, isMetallic: true)])
                    anchorEntity.addChild(sphere)
                    
                    if let arView = session.delegate as? ARView {
                        arView.scene.addAnchor(anchorEntity)
                    }
                }
            }
        }
    }
}