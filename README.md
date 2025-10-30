# AR Study Guide

An iOS AR application that brings textbooks to life with interactive 3D models.

## Features

- **Image Anchor Engine**: Recognize 2D images in textbooks and overlay 3D content
- **Object Capture Engine**: Create 3D models from photos using Object Capture API
- **Guided Presentation Engine**: Step-by-step AR lessons with animations
- **Physical Anchor Engine**: Use physical objects as anchors for AR content

## Engines

### Image Anchor Engine

The core "living textbook" technology - a real-time 6-DoF key-value lookup system.

**Technical Details:**
- **Detection**: ARKit analyzes image features (corners, textures, contrast)
- **Matching**: Compares against pre-defined reference image library
- **Anchoring**: Creates ARImageAnchor with precise 6-DoF transform (position, rotation, scale)
- **Tracking**: Continuous 60fps updates for stable AR content placement

**Implementation:**
- Uses `ARWorldTrackingConfiguration` for image detection + world understanding
- Reference images stored in Xcode asset catalog with physical dimensions
- `ARSessionDelegate` handles detection events
- `AnchorEntity` locks 3D content to detected images

**Best Practices:**
- High-contrast images with rich features work best
- Define accurate physical sizes in Xcode for proper scaling
- Avoid glossy, repetitive, or low-contrast images
- Supports multiple simultaneous image tracking

**Subject-Specific Content:**
- **EEE**: Circuit diagrams → 3D component models
- **Biology**: Anatomy diagrams → Interactive 3D organs
- **Chemistry**: Molecular structures → Space-filling models
- **Engineering**: System diagrams → Exploded assemblies

### Object Capture Engine

User-generated 3D models through photogrammetry - transform photos into AR-ready assets.

**Technical Details:**
- **Photogrammetry Process**: Feature detection → matching → sparse point cloud → dense reconstruction → texture mapping
- **API**: Uses `PhotogrammetrySession` from RealityFoundation (iOS 15+)
- **Output**: Optimized USDZ files with geometry, materials, and textures
- **Best Results**: 20-200 photos with LiDAR-equipped devices

**Implementation:**
- Camera guidance with real-time quality feedback
- Asynchronous reconstruction with progress tracking
- AR preview for placing reconstructed models
- Temporary storage for photo sequences

**EEE Use Cases:**
- **Prototype Scanning**: Breadboard circuits → inspectable 3D models
- **Component Libraries**: IC packages → multi-angle identification
- **Project Documentation**: Robotics/embedded systems → AR presentations
- **Reverse Engineering**: PCB analysis → virtual inspection

**Limitations:**
- Struggles with shiny/transparent/reflective surfaces
- Computationally intensive (battery drain)
- Quality depends on photo capture technique
- Not precision CAD-level accuracy

### Guided Presentation Engine

- Step-by-step AR lessons
- Animated sequences (e.g., engine operation, physics simulations)
- Interactive controls for lesson progression

### Physical Anchor Engine

- Uses physical objects (like a foam cube) as universal anchors
- Precise tracking for educational models
- Supports complex 3D visualizations

## Requirements

- iOS 16.0+
- Xcode 14.0+
- ARKit 7.0+
- RealityKit 4.0+
- LiDAR sensor recommended for advanced features

## Building

1. Open the project in Xcode (on macOS)
2. Add an asset catalog named "AR Resources"
3. Add reference images and objects for tracking
4. Add camera permissions to Info.plist:
   - NSCameraUsageDescription: "Camera access is required for AR tracking and 3D object capture"
   - NSPhotoLibraryUsageDescription: "Photo library access is needed to save captured images"
   - ARKit required device capabilities
5. Build and run on a device with AR capabilities

## CI/CD

The project includes GitHub Actions workflows for automated testing and releases:

- **CI Workflow**: Runs on every push/PR to main/develop branches
  - Builds with SwiftPM and Xcode
  - Runs unit tests
  - Tests iOS Simulator builds
  
- **Release Workflow**: Triggers on version tags (v*)
  - Creates release archives
  - Publishes GitHub releases with assets

## Development

- Uses Swift Package Manager for dependency management
- Compatible with Xcode 14+ and Swift 5.9+
- Includes comprehensive .gitignore for iOS/Swift development

## Permissions Required

The app requires the following permissions for full functionality:

- **Camera Access**: Required for AR tracking and Object Capture photogrammetry
- **Photo Library**: Optional, for saving captured photos and reconstructed models
- **ARKit**: Device capability for AR features

## 3D Model Organization

The app uses a structured approach to 3D model management:

### Model Categories

- **Educational**: Textbook diagrams, anatomical models
- **Prototype**: User-created circuit boards, components  
- **Interactive**: Animated mechanisms, simulations
- **Reference**: Standard components, measurement tools

### USDZ Structure

```text
Root Scene
├── Geometry (Meshes & Materials)
├── Animations (Transform, Morph, Skeletal)
├── Metadata (Custom Properties)
└── Lighting (Environment Maps)
```

### Subject Areas

- Electrical Engineering (BJT transistors, circuits)
- Mechanical Engineering (engines, assemblies)
- Biology (anatomy, cellular structures)
- Chemistry (molecular models)
- Physics (simulations, measurements)
- Computer Science (data structures, algorithms)

### Interactive Elements

- **Hotspots**: Information points on models
- **Animations**: Movement demonstrations
- **Measurements**: Dimension visualization
- **Disassembly**: Part separation for study
