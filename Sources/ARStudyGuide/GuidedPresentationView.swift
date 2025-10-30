import SwiftUI
import RealityKit
import ARKit

struct GuidedPresentationView: UIViewRepresentable {
    @Binding var currentStep: Int
    
    init(currentStep: Binding<Int>) {
        _currentStep = currentStep
    }
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        
        // Add initial anchor
        let anchor = AnchorEntity(plane: .horizontal)
        arView.scene.addAnchor(anchor)
        
        context.coordinator.arView = arView
        context.coordinator.anchor = anchor
        
        updatePresentation(for: currentStep, in: arView, anchor: anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        updatePresentation(for: currentStep, in: uiView, anchor: context.coordinator.anchor)
    }
    
    private func updatePresentation(for step: Int, in arView: ARView, anchor: AnchorEntity) {
        // Clear previous content
        anchor.children.removeAll()
        
        switch step {
        case 0:
            // Step 1: Basic engine
            let engine = ModelEntity(mesh: MeshResource.generateBox(size: 0.1), materials: [SimpleMaterial(color: .gray, isMetallic: true)])
            anchor.addChild(engine)
        case 1:
            // Step 2: Add pistons
            let engine = ModelEntity(mesh: MeshResource.generateBox(size: 0.1), materials: [SimpleMaterial(color: .gray, isMetallic: true)])
            let piston = ModelEntity(mesh: MeshResource.generateCylinder(height: 0.05, radius: 0.02), materials: [SimpleMaterial(color: .red, isMetallic: true)])
            piston.position = [0, 0.05, 0]
            engine.addChild(piston)
            anchor.addChild(engine)
        case 2:
            // Step 3: Add animation
            let engine = ModelEntity(mesh: MeshResource.generateBox(size: 0.1), materials: [SimpleMaterial(color: .gray, isMetallic: true)])
            let piston = ModelEntity(mesh: MeshResource.generateCylinder(height: 0.05, radius: 0.02), materials: [SimpleMaterial(color: .red, isMetallic: true)])
            piston.position = [0, 0.05, 0]
            
            // Simple animation
            let animation = piston.move(to: [0, 0.08, 0], relativeTo: engine, duration: 1.0, timingFunction: .easeInOut)
            animation.repeat(count: .max)
            
            engine.addChild(piston)
            anchor.addChild(engine)
        default:
            break
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var arView: ARView?
        var anchor: AnchorEntity?
    }
}

struct GuidedPresentationContainer: View {
    @State private var currentStep = 0
    let maxSteps = 3
    
    var body: some View {
        VStack {
            GuidedPresentationView(currentStep: $currentStep)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button("Previous") {
                    if currentStep > 0 {
                        currentStep -= 1
                    }
                }
                .disabled(currentStep == 0)
                
                Spacer()
                
                Text("Step \(currentStep + 1) of \(maxSteps)")
                
                Spacer()
                
                Button("Next") {
                    if currentStep < maxSteps - 1 {
                        currentStep += 1
                    }
                }
                .disabled(currentStep == maxSteps - 1)
            }
            .padding()
        }
    }
}