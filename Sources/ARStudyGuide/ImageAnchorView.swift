import SwiftUI
import RealityKit
import ARKit

struct ImageAnchorView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Configure for image tracking
        // Note: Add reference images to an asset catalog named "AR Resources" in Xcode
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            // Fallback to world tracking if no images
            let configuration = ARWorldTrackingConfiguration()
            arView.session.run(configuration)
            return arView
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 4
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
                if let imageAnchor = anchor as? ARImageAnchor {
                    // Add 3D content on detected image
                    let anchorEntity = AnchorEntity(anchor: imageAnchor)
                    
                    // Example: Add a 3D model representing circuit diagram overlay
                    let box = ModelEntity(mesh: MeshResource.generateBox(size: 0.05), materials: [SimpleMaterial(color: .green, isMetallic: true)])
                    anchorEntity.addChild(box)
                    
                    // Add text label
                    let textMesh = MeshResource.generateText("Circuit Diagram", extrusionDepth: 0.01, font: .systemFont(ofSize: 0.1))
                    let textEntity = ModelEntity(mesh: textMesh, materials: [SimpleMaterial(color: .white, isMetallic: false)])
                    textEntity.position = [0, 0.1, 0]
                    anchorEntity.addChild(textEntity)
                    
                    if let arView = session.delegate as? ARView {
                        arView.scene.addAnchor(anchorEntity)
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            // Handle anchor updates if needed
        }
        
        func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
            // Handle anchor removal
        }
    }
}