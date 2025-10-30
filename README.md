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

- User-generated 3D models from photos
- Integrates with Apple's Object Capture API
- Best with LiDAR-equipped devices

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
   - NSCameraUsageDescription
   - ARKit required device capabilities
5. Build and run on a device with AR capabilities

## Technologies

- SwiftUI
- ARKit
- RealityKit
- Object Capture API
