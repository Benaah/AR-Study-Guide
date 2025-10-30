import SwiftUI
import RealityKit
import RealityFoundation
import AVFoundation
import Photos

struct ObjectCaptureView: View {
    @State private var captureMode = true
    @State private var isCapturing = false
    @State private var capturedPhotos: [URL] = []
    @State private var reconstructionProgress: Float = 0.0
    @State private var isReconstructing = false
    @State private var reconstructedModelURL: URL?
    @State private var showARPreview = false
    
    var body: some View {
        VStack {
            if captureMode {
                captureInterface
            } else if showARPreview, let modelURL = reconstructedModelURL {
                ARModelPreview(modelURL: modelURL, onBack: {
                    showARPreview = false
                    captureMode = true
                })
            } else {
                reconstructionInterface
            }
        }
        .padding()
    }
    
    private var captureInterface: some View {
        VStack(spacing: 20) {
            Text("Object Capture Engine")
                .font(.title)
                .bold()
            
            Text("Create 3D models from photos using photogrammetry")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("📸 Capture Guidelines:")
                    .font(.headline)
                
                Text("• Take 20-200 photos from different angles")
                Text("• Ensure good lighting and avoid shiny surfaces")
                Text("• Move steadily around the object")
                Text("• Maintain overlap between consecutive photos")
                Text("• LiDAR-equipped devices work best")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            if capturedPhotos.isEmpty {
                Button(isCapturing ? "Capturing..." : "Start Photo Capture") {
                    showCamera = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(isCapturing)
            } else {
                VStack {
                    Text("Captured \(capturedPhotos.count) photos")
                    
                    HStack {
                        Button("Add More Photos") {
                            showCamera = true
                        }
                        
                        Button("Process Model") {
                            startReconstruction()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            
            Button("Reset") {
                resetCapture()
            }
            .foregroundColor(.red)
        }
    }
    
    private var reconstructionInterface: some View {
        VStack(spacing: 20) {
            Text("Processing 3D Model")
                .font(.title)
            
            ProgressView(value: reconstructionProgress, total: 1.0)
                .progressViewStyle(.linear)
                .padding(.horizontal)
            
            Text("\(Int(reconstructionProgress * 100))% complete")
                .foregroundColor(.secondary)
            
            if reconstructionProgress >= 1.0, let modelURL = reconstructedModelURL {
                VStack {
                    Text("Model created successfully!")
                        .foregroundColor(.green)
                    
                    Button("Preview in AR") {
                        showARPreview = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            Button("Back to Capture") {
                captureMode = true
                resetCapture()
            }
        }
    }
    
    private func startPhotoCapture() {
        isCapturing = true
        
        // Simulate capturing multiple photos
        // In real implementation, this would use camera access
        DispatchQueue.global().async {
            for i in 1...25 {  // Simulate 25 photos
                Thread.sleep(forTimeInterval: 0.2)  // Simulate capture time
                
                // Create temporary file URL for simulated photo
                let tempDir = FileManager.default.temporaryDirectory
                let photoURL = tempDir.appendingPathComponent("capture_\(i).jpg")
                
                DispatchQueue.main.async {
                    self.capturedPhotos.append(photoURL)
                }
            }
            
            DispatchQueue.main.async {
                self.isCapturing = false
            }
        }
    }
    
    private func captureAdditionalPhoto() {
        // Simulate adding one more photo
        let tempDir = FileManager.default.temporaryDirectory
        let photoURL = tempDir.appendingPathComponent("capture_\(capturedPhotos.count + 1).jpg")
        capturedPhotos.append(photoURL)
    }
    
    private func startReconstruction() {
        guard !capturedPhotos.isEmpty else { return }
        
        captureMode = false
        isReconstructing = true
        reconstructionProgress = 0.0
        
        // Create output URL for the USDZ model
        let tempDir = FileManager.default.temporaryDirectory
        let outputURL = tempDir.appendingPathComponent("reconstructed_model.usdz")
        
        // Remove existing file if any
        try? FileManager.default.removeItem(at: outputURL)
        
        Task {
            do {
                // Create photogrammetry session with captured photos
                let input = PhotogrammetrySession.Input(urls: capturedPhotos)
                let session = try PhotogrammetrySession(input: input)
                
                // Configure session with sample interval for detail level
                let requests: [PhotogrammetrySession.Request] = [
                    .modelFile(url: outputURL, detail: .reduced)  // Use .preview for faster processing
                ]
                
                // Process the session asynchronously
                try session.process(requests: requests)
                
                // Monitor progress
                for try await output in session.outputs {
                    switch output {
                    case .processingComplete:
                        // Processing finished
                        DispatchQueue.main.async {
                            self.reconstructionProgress = 1.0
                            self.reconstructedModelURL = outputURL
                            self.isReconstructing = false
                        }
                        
                    case .requestProgress(let request, let fractionComplete):
                        // Update progress
                        DispatchQueue.main.async {
                            self.reconstructionProgress = Float(fractionComplete)
                        }
                        
                    case .requestComplete(let request, let result):
                        // Handle individual request completion
                        switch result {
                        case .modelFile(let url):
                            print("Model file created at: \(url)")
                        case .modelEntity:
                            print("Model entity created")
                        @unknown default:
                            print("Unknown result type")
                        }
                        
                    case .requestError(let request, let error):
                        // Handle request errors
                        print("Request error: \(error)")
                        DispatchQueue.main.async {
                            self.isReconstructing = false
                            // Could show error alert here
                        }
                        
                    case .processingCancelled:
                        // Processing was cancelled
                        DispatchQueue.main.async {
                            self.isReconstructing = false
                        }
                        
                    @unknown default:
                        print("Unknown output type")
                    }
                }
                
            } catch {
                print("Photogrammetry failed: \(error)")
                DispatchQueue.main.async {
                    self.isReconstructing = false
                    // Handle error - could show alert
                }
            }
        }
    }
    
    private func resetCapture() {
        capturedPhotos.removeAll()
        reconstructionProgress = 0.0
        isReconstructing = false
        reconstructedModelURL = nil
        showARPreview = false
        captureMode = true
    }
}

// AR Preview for reconstructed models
struct ARModelPreview: UIViewRepresentable {
    let modelURL: URL
    let onBack: () -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        // Add tap gesture to place model
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        context.coordinator.arView = arView
        context.coordinator.modelURL = modelURL
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onBack: onBack)
    }
    
    class Coordinator: NSObject {
        var arView: ARView?
        var modelURL: URL?
        let onBack: () -> Void
        
        init(onBack: @escaping () -> Void) {
            self.onBack = onBack
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView, let modelURL = modelURL else { return }
            
            let location = gesture.location(in: arView)
            
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                // Load and place the reconstructed model
                do {
                    let model = try ModelEntity.load(contentsOf: modelURL)
                    let anchor = AnchorEntity(world: result.worldTransform)
                    anchor.addChild(model)
                    arView.scene.addAnchor(anchor)
                } catch {
                    print("Failed to load model: \(error)")
                }
            }
        }
    }
}