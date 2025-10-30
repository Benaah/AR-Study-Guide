import SwiftUI
import AVFoundation
import Photos

struct CameraCaptureView: UIViewControllerRepresentable {
    @Binding var capturedPhotos: [URL]
    @Binding var isCapturing: Bool
    let onCaptureComplete: () -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(capturedPhotos: $capturedPhotos, isCapturing: $isCapturing, onCaptureComplete: onCaptureComplete)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        @Binding var capturedPhotos: [URL]
        @Binding var isCapturing: Bool
        let onCaptureComplete: () -> Void
        
        init(capturedPhotos: Binding<[URL]>, isCapturing: Binding<Bool>, onCaptureComplete: @escaping () -> Void) {
            _capturedPhotos = capturedPhotos
            _isCapturing = isCapturing
            self.onCaptureComplete = onCaptureComplete
        }
        
        func didCapturePhoto(_ imageData: Data) {
            // Save photo to temporary file
            let tempDir = FileManager.default.temporaryDirectory
            let filename = "capture_\(capturedPhotos.count + 1).jpg"
            let fileURL = tempDir.appendingPathComponent(filename)
            
            do {
                try imageData.write(to: fileURL)
                capturedPhotos.append(fileURL)
            } catch {
                print("Failed to save photo: \(error)")
            }
        }
        
        func didFinishCapturing() {
            isCapturing = false
            onCaptureComplete()
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCapturePhoto(_ imageData: Data)
    func didFinishCapturing()
}

class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var captureCount = 0
    private let targetCaptures = 20 // Minimum recommended for Object Capture
    
    private let captureButton = UIButton(type: .system)
    private let countLabel = UILabel()
    private let instructionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
        requestPermissions()
    }
    
    private func requestPermissions() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                DispatchQueue.main.async {
                    self.startSession()
                }
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            }
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Object Capture needs camera access to take photos for 3D reconstruction.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.delegate?.didFinishCapturing()
        })
        present(alert, animated: true)
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
        } catch {
            print("Camera setup failed: \(error)")
        }
    }
    
    private func setupUI() {
        // Instruction label
        instructionLabel.text = "Move around the object\ntaking \(targetCaptures) photos"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.numberOfLines = 0
        instructionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        instructionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        instructionLabel.layer.cornerRadius = 8
        instructionLabel.clipsToBounds = true
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionLabel)
        
        // Count label
        countLabel.text = "0 / \(targetCaptures)"
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.font = .systemFont(ofSize: 24, weight: .bold)
        countLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        countLabel.layer.cornerRadius = 8
        countLabel.clipsToBounds = true
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(countLabel)
        
        // Capture button
        captureButton.setTitle("Capture", for: .normal)
        captureButton.backgroundColor = .systemBlue
        captureButton.setTitleColor(.white, for: .normal)
        captureButton.layer.cornerRadius = 25
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
        
        // Layout
        NSLayoutConstraint.activate([
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            instructionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            countLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 120),
            captureButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("No image data")
            return
        }
        
        captureCount += 1
        countLabel.text = "\(captureCount) / \(targetCaptures)"
        
        delegate?.didCapturePhoto(imageData)
        
        if captureCount >= targetCaptures {
            // Finished capturing
            captureSession.stopRunning()
            delegate?.didFinishCapturing()
        }
    }
}