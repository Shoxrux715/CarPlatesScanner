//
//  SwiftUIView.swift
//  CarPlatesScanner
//
//  Created by Shoxrux Khodjaev on 01/05/2025.
//

import SwiftUI
import AVFoundation
import Vision

public class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    public var parent: CarPlatesScannerView
    public var visionRequest = [VNRequest]()
    
    public init(_ parent: CarPlatesScannerView) {
        self.parent = parent
        super.init()
        setupVision()
    }
    
    public func setupVision() {
        let textRequest = VNRecognizeTextRequest(completionHandler: self.handleDetectedText)
        self.visionRequest = [textRequest]
    }
    
    public func handleDetectedText(request: VNRequest?, error: Error?) {
        guard let observations = request?.results as? [VNRecognizedTextObservation] else { return }
        var carPlates: String?
        
        for observation in observations {
            guard let candidate = observation.topCandidates(1).first else { continue }
            let text = correctPlate(candidate.string)
            if text.isValidNumberPlates() {
                carPlates = text
                break
            }
        }
        
        if let detectedCarPlates = carPlates {
            let parent = self.parent
            DispatchQueue.main.async {
                parent.onCarPlatesDetected(detectedCarPlates)
            }
        }
    }
    
    // To recognize plates with letter "O"
    public func correctPlate(_ rawText: String) -> String {
        let cleaned = rawText.uppercased().replacingOccurrences(of: " ", with: "")
        guard cleaned.count >= 5 else { return cleaned }

        let region = String(cleaned.prefix(2))
        let body = Array(cleaned.dropFirst(2))
        let unknown = Array(cleaned)
        var corrected = body

        func isDigit(_ char: Character) -> Bool {
            return char.isNumber
        }

        func isLetterOrO(_ char: Character) -> Bool {
            return char.isLetter || char == "0"
        }
        
        if unknown.count == 6,
           isLetterOrO(unknown[0]), isLetterOrO(unknown[1]),
           (1..<5).allSatisfy({ isDigit(unknown[$0]) }) {
            
            if unknown[0] == "0" { corrected[0] = "O" }
            if unknown[1] == "0" { corrected[1] = "O" }
            
        }
        else if unknown.count == 6,
                isLetterOrO(unknown[0]), isLetterOrO(unknown[1]), isLetterOrO(unknown[2]),
                (1..<4).allSatisfy({ isDigit(unknown[$0]) }) {
            
            if unknown[0] == "0" { corrected[0] = "O" }
            if unknown[1] == "0" { corrected[1] = "O" }
            if unknown[2] == "0" { corrected[2] = "O" }
            
        }
        else if body.count == 6,
           isLetterOrO(body[0]), // 1 Letter
           isDigit(body[1]), isDigit(body[2]), isDigit(body[3]), // 3 Numbers
           isLetterOrO(body[4]), isLetterOrO(body[5]) { // 2 Letters

            if body[0] == "0" { corrected[0] = "O" }
            if body[4] == "0" { corrected[4] = "O" }
            if body[5] == "0" { corrected[5] = "O" }

        }
        else if body.count == 6,
                isDigit(body[0]), isDigit(body[1]), isDigit(body[2]), // 3 Numbers
                isLetterOrO(body[3]), isLetterOrO(body[4]), isLetterOrO(body[5]) { // 3 Letters

            if body[3] == "0" { corrected[3] = "O" }
            if body[4] == "0" { corrected[4] = "O" }
            if body[5] == "0" { corrected[5] = "O" }

        }
        else if body.count == 7,
                isLetterOrO(body[0]), // 1 Letter
                (1..<7).allSatisfy({ isDigit(body[$0]) }) { // 6 Numbers

            if body[0] == "0" { corrected[0] = "O" }

        }

        return region + String(corrected)
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        var requestOptions:[VNImageOption: Any] = [:]
        
        if let cameraData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraData]
        }
        
        guard let pixelBuffer = pixelBuffer else { return }
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.visionRequest)
        } catch {
            print(error)
        }
    }
}

