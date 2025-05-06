//
//  CameraScanView.swift
//  CameraScanView
//
//  Created by Shoxrux Khodjaev on 01/05/2025.
//

import SwiftUI
import AVFoundation
import Vision

public struct CameraScanView: View {
    
    /// First is series, second is number
    public let onPlatesDetected: (String, String) -> (Void)
    
    @Environment(\.presentationMode) var presentationMode
  
    @State public var showAlert: Bool = false

    @State public var carPlates: String = ""
    
    public let cutoutSize = CGSize(width: UIScreen.main.bounds.width * 3/4, height: 100)
    
    public init(onPlatesDetected: @escaping (String, String) -> Void) {
        self.onPlatesDetected = onPlatesDetected
    }
    public var body: some View {
        NavigationStack {
            ZStack {
                CarPlatesScannerView { plates in
                    self.carPlates = plates
                    parseCarPlate(plates)
                    cameraAutoOff()
                }
                .edgesIgnoringSafeArea(.all)
                
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .mask(
                        CutoutMask(size: cutoutSize)
                            .fill(style: FillStyle(eoFill: true))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 5)
                            .frame(width: cutoutSize.width, height: cutoutSize.height)
                    )
                    .overlay {
                        HStack(alignment: .center) {
                            if !carPlates.isEmpty {
                                Text("\(carPlates)")
                                    .font(.system(size: 30).bold())
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .animation(.easeInOut, value: carPlates)
                    }
                    .ignoresSafeArea()
                
                
                Text("point-the-camera", bundle: .module)
                    .foregroundColor(Color.white)
                    .frame(maxHeight: 300, alignment: .top)
                
            }
            .onAppear {
                checkCameraPermission()
            }
            .alert(Text("no-access", bundle: .module), isPresented: $showAlert) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("open-settings", bundle: .module)
                }
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("cancel", bundle: .module)
                }
            } message: {
                Text("allow-in-settings", bundle: .module)
            }
            .toolbar {
                toolBarItems()
            }
        }
    }
        
    
// MARK: View components
    @ToolbarContentBuilder
    func toolBarItems() -> some ToolbarContent {
        
        ToolbarItem(placement: .principal) {
            Text("scan-number", bundle: .module)
                .foregroundColor(Color.white)
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Button{
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(Color.white)
                    .padding()
            }
        }
    }
    
    
// MARK: Functions
    private func parseCarPlate(_ plate: String) {
        let cleaned = plate.replacingOccurrences(of: " ", with: "")
        guard cleaned.count >= 8 else {
            return
        }
        
        let carSeries = String(cleaned.prefix(2))
        let rest = String(cleaned.dropFirst(2))
        onPlatesDetected(carSeries, rest)
        return
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showAlert = false

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    showAlert = !granted
                    presentationMode.wrappedValue.dismiss()
                }
            }

        default:
            showAlert = true
        }
    }
    
    private func cameraAutoOff() {
        guard !carPlates.isEmpty else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            carPlates = ""
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    CameraScanView(onPlatesDetected: { ser, num in
        
    })
}

public extension String {
    func isValidNumberPlates() -> Bool {
        
        let patt = #"^[0-9][0-9O](?:[A-Z][0-9]{3}[A-Z]{2}|[0-9]{3}[A-Z]{3}| ?[A-Z] ?[0-9]{5,6})$"#
        
        let regex = try! NSRegularExpression(pattern: patt)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
        
    }
}
