# AR Study Guide - Info.plist Configuration

This document explains the permissions and configurations in `Info.plist.template`.

## Required Permissions

### Camera Access
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for AR tracking, textbook scanning, and 3D object capture photogrammetry.</string>
```
- **Purpose**: Enables ARKit world tracking, image anchor detection, and Object Capture photogrammetry
- **Usage**: All AR engines require camera feed for tracking and image processing

### Photo Library Access
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access is needed to save captured images and reconstructed 3D models.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Allows the app to save captured photos and 3D models to your photo library.</string>
```
- **Purpose**: Save Object Capture photos and export reconstructed USDZ models
- **Usage**: Object Capture engine saves photo sequences and final 3D models

## Optional Permissions

### Microphone Access
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access may be used for audio-guided lessons and voice commands.</string>
```
- **Purpose**: Future audio-guided AR lessons and voice interaction
- **Current Usage**: Not implemented, but prepared for future features

### Location Services
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location access helps provide location-aware AR content and experiences.</string>
```
- **Purpose**: Location-based AR content or campus-specific learning materials
- **Current Usage**: Not implemented, but prepared for educational contexts

### Face ID
```xml
<key>NSFaceIDUsageDescription</key>
<string>Face ID access enables advanced AR facial tracking features.</string>
```
- **Purpose**: Future facial expression recognition for interactive learning
- **Current Usage**: Not implemented

## Device Capabilities

### ARKit Requirement
```xml
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
</array>
```
- **Purpose**: Ensures the app only runs on ARKit-compatible devices
- **Supported Devices**: iPhone 6s+, iPad (5th gen)+, iPad Pro all models

### Additional Capabilities
- `armv7`: 32-bit support (legacy)
- `camera-flash`: Camera flash for better image capture
- `front-facing-camera`: Selfie camera for potential face tracking
- `gyroscope`: Device orientation sensing
- `magnetometer`: Compass functionality
- `microphone`: Audio input
- `opengles-3`: OpenGL ES 3.0 for graphics rendering
- `still-camera`: Photo capture
- `video-camera`: Video recording
- `wifi`: Network connectivity

## App Transport Security

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSAllowsLocalNetworking</key>
    <true/>
</dict>
```
- **Purpose**: Allows local network access while maintaining HTTPS requirements
- **Usage**: Potential local device communication or development server access

## Privacy API Declarations

The template includes required privacy declarations for iOS 15+:

- **File Timestamp Access**: For managing temporary photo/model files
- **System Boot Time**: For performance timing (ARKit optimization)
- **Disk Space**: For checking available storage before large operations

## Setup Instructions

1. Copy `Info.plist.template` to `Info.plist` in your Xcode project
2. Customize the bundle identifier and app information
3. Add your app icons to the asset catalog
4. Test on device to ensure all permissions work correctly

## Troubleshooting

- **Camera Permission Denied**: Check NSCameraUsageDescription string
- **AR Not Working**: Verify arkit capability and iOS version
- **Build Errors**: Ensure all required capabilities are enabled in Xcode

## Future Permissions

As the app evolves, consider adding:
- Bluetooth for connected device interaction
- HealthKit for biology/health-related AR experiences
- Siri for voice-activated learning commands