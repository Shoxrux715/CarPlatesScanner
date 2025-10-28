//
//  CarPlatesScannerView.swift
//  CarPlatesScanner
//
//  Created by Shoxrux Khodjaev on 01/05/2025.
//

import SwiftUI
@preconcurrency import AVFoundation
import Vision

/// Представление камеры, которое отображает видеопоток и
/// передаёт распознанный номер автомобиля через callback.
///  
/// Используется внутри `CameraScanView`.
///  
/// > Пример:
/// ```swift
/// CarPlatesScannerView { detectedPlate in
///     print("Detected plate: \(detectedPlate)")
/// }
/// ```
public struct CarPlatesScannerView: UIViewControllerRepresentable {
    
    /// Замыкание, вызываемое при обнаружении номера
    public var onCarPlatesDetected: (String) -> Void
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return viewController }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
        if (captureSession.canAddOutput(videoOutput)) {
            captureSession.addOutput(videoOutput)
        } else {
            return viewController
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
