import SwiftUI
import RealityKit

struct LibraryView: View {
    @State private var selectedCategory: ModelCategory = .educational
    @State private var searchText = ""
    @State private var selectedModel: ModelMetadata?
    @State private var showingARPreview = false
    
    // Mock data - in real app, this would come from ModelLibrary
    let mockModels: [ModelMetadata] = [
        ModelMetadata(
            id: "bjt_transistor",
            name: "BJT Transistor",
            category: .educational,
            subjectArea: .electricalEngineering,
            description: "Interactive 3D model of a Bipolar Junction Transistor showing base, collector, and emitter regions",
            author: "AR Study Guide",
            creationDate: Date(),
            physicalSize: SIMD3<Float>(0.01, 0.02, 0.01),
            tags: ["transistor", "BJT", "semiconductor"],
            difficulty: .intermediate,
            interactiveElements: [
                .init(name: "Base Terminal", type: .hotspot, description: "Control terminal"),
                .init(name: "Collector Terminal", type: .hotspot, description: "Output terminal"),
                .init(name: "Emitter Terminal", type: .hotspot, description: "Reference terminal")
            ]
        ),
        ModelMetadata(
            id: "heart_anatomy",
            name: "Human Heart",
            category: .educational,
            subjectArea: .biology,
            description: "Anatomically accurate 3D model of the human heart with interactive chambers and valves",
            author: "AR Study Guide",
            creationDate: Date(),
            physicalSize: SIMD3<Float>(0.12, 0.10, 0.08),
            tags: ["heart", "cardiovascular", "anatomy"],
            difficulty: .beginner,
            interactiveElements: [
                .init(name: "Right Atrium", type: .hotspot, description: "Receives deoxygenated blood"),
                .init(name: "Left Ventricle", type: .hotspot, description: "Pumps oxygenated blood")
            ]
        ),
        ModelMetadata(
            id: "combustion_engine",
            name: "Combustion Engine",
            category: .interactive,
            subjectArea: .mechanicalEngineering,
            description: "Animated 4-stroke internal combustion engine with step-by-step operation",
            author: "AR Study Guide",
            creationDate: Date(),
            physicalSize: SIMD3<Float>(0.15, 0.12, 0.10),
            tags: ["engine", "combustion", "mechanical"],
            difficulty: .advanced,
            interactiveElements: [
                .init(name: "Piston Animation", type: .animation, description: "4-stroke cycle animation"),
                .init(name: "Valve Operation", type: .animation, description: "Valve timing demonstration")
            ]
        )
    ]
    
    var filteredModels: [ModelMetadata] {
        let categoryFiltered = mockModels.filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter { model in
                model.name.lowercased().contains(searchText.lowercased()) ||
                model.description.lowercased().contains(searchText.lowercased()) ||
                model.tags.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Category Picker
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ModelCategory.allCases, id: \.self) { category in
                        Text(category.rawValue.capitalized).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search models...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                // Model Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                        ForEach(filteredModels) { model in
                            ModelCard(model: model)
                                .onTapGesture {
                                    selectedModel = model
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("AR Library")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedModel) { model in
                ModelDetailView(model: model, isPresented: $selectedModel)
            }
        }
    }
}

struct ModelCard: View {
    let model: ModelMetadata
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Model Preview Placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 120)
                
                Image(systemName: model.category == .educational ? "book" : 
                             model.category == .interactive ? "play.circle" :
                             model.category == .prototype ? "wrench.and.screwdriver" : "cube")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(model.subjectArea.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text(model.difficulty.rawValue.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(difficultyColor(model.difficulty))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    if let elements = model.interactiveElements {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(elements.count)")
                            .font(.caption2)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func difficultyColor(_ difficulty: ModelMetadata.ModelDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct ModelDetailView: View {
    let model: ModelMetadata
    @Binding var isPresented: ModelMetadata?
    @State private var showingARPreview = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(model.name)
                            .font(.title)
                            .bold()
                        
                        HStack {
                            Text(model.category.rawValue.capitalized)
                                .font(.subheadline)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            
                            Text(model.subjectArea.rawValue)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Difficulty: \(model.difficulty.rawValue.capitalized)")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("By \(model.author)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Description
                    Text(model.description)
                        .font(.body)
                        .lineSpacing(4)
                    
                    // Tags
                    if !model.tags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.headline)
                            
                            FlowLayout(spacing: 8) {
                                ForEach(model.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Interactive Elements
                    if let elements = model.interactiveElements, !elements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Interactive Elements")
                                .font(.headline)
                            
                            ForEach(elements, id: \.name) { element in
                                HStack {
                                    Image(systemName: element.type == .hotspot ? "hand.point.up" :
                                                 element.type == .animation ? "play.circle" :
                                                 element.type == .measurement ? "ruler" : "square.split.2x2")
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading) {
                                        Text(element.name)
                                            .font(.subheadline)
                                            .bold()
                                        Text(element.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // Physical Size
                    if let size = model.physicalSize {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Physical Dimensions")
                                .font(.headline)
                            
                            Text(String(format: "%.1f × %.1f × %.1f cm",
                                       size.x * 100, size.y * 100, size.z * 100))
                                .font(.subheadline)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            showingARPreview = true
                        }) {
                            HStack {
                                Image(systemName: "arkit")
                                Text("View in AR")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Share functionality
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Model")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Model Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                isPresented = nil
            })
            .sheet(isPresented: $showingARPreview) {
                ARModelPreview(modelID: model.id, modelName: model.name)
            }
        }
    }
}

// AR Preview for library models
struct ARModelPreview: UIViewRepresentable {
    let modelID: String
    let modelName: String
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        arView.session.run(configuration)
        
        // Add tap gesture to place model
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap)))
        
        context.coordinator.arView = arView
        context.coordinator.modelID = modelID
        context.coordinator.modelName = modelName
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var arView: ARView?
        var modelID: String?
        var modelName: String?
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView, let modelID = modelID else { return }
            
            let location = gesture.location(in: arView)
            
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal).first {
                // Create a placeholder model based on the model ID
                // In real implementation, load from ModelLibrary
                let model = createPlaceholderModel(for: modelID)
                
                let anchor = AnchorEntity(world: result.worldTransform)
                anchor.addChild(model)
                arView.scene.addAnchor(anchor)
            }
        }
        
        private func createPlaceholderModel(for modelID: String) -> ModelEntity {
            switch modelID {
            case "bjt_transistor":
                return ModelEntity(mesh: MeshResource.generateBox(size: 0.05),
                                 materials: [SimpleMaterial(color: .green, isMetallic: true)])
            case "heart_anatomy":
                return ModelEntity(mesh: MeshResource.generateSphere(radius: 0.03),
                                 materials: [SimpleMaterial(color: .red, isMetallic: false)])
            case "combustion_engine":
                return ModelEntity(mesh: MeshResource.generateCylinder(height: 0.06, radius: 0.02),
                                 materials: [SimpleMaterial(color: .gray, isMetallic: true)])
            default:
                return ModelEntity(mesh: MeshResource.generateBox(size: 0.04),
                                 materials: [SimpleMaterial(color: .blue, isMetallic: false)])
            }
        }
    }
}

// Flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(proposal: proposal, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(proposal: proposal, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                    y: bounds.minY + result.positions[index].y),
                         proposal: proposal)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize
        
        init(proposal: ProposedViewSize, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxWidth: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(proposal)
                
                if currentX + size.width > (proposal.width ?? .infinity) && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxWidth = max(maxWidth, currentX)
            }
            
            size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// ModelCategory extension for allCases
extension ModelCategory: CaseIterable {}