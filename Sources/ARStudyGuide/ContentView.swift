import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        TabView {
            ImageAnchorView()
                .tabItem {
                    Label("Image Anchor", systemImage: "book")
                }
            ObjectCaptureView()
                .tabItem {
                    Label("Object Capture", systemImage: "camera")
                }
            GuidedPresentationContainer()
                .tabItem {
                    Label("Guided", systemImage: "list.bullet")
                }
            PhysicalAnchorView()
                .tabItem {
                    Label("Physical", systemImage: "cube")
                }
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
        }
    }
}