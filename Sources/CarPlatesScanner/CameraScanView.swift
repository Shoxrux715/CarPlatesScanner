//
//  CameraScanView.swift
//  CameraScanView
//
//  Created by Shoxrux Khodjaev on 01/05/2025.
//

import SwiftUI
import AVFoundation
import Vision

@MainActor
public struct CameraScanView: View {

    /// First is series, second is number
    public let onPlatesDetected: @MainActor (String, String) -> Void
    public let onClose: @MainActor () -> Void

    @State private var showAlert: Bool = false
    @State private var carPlates: String = ""

    private let cutoutSize = CGSize(width: UIScreen.main.bounds.width * 3/4, height: 100)

    public init(
        onPlatesDetected: @escaping @MainActor (String, String) -> Void,
        onClose: @escaping @MainActor () -> Void
    ) {
        self.onPlatesDetected = onPlatesDetected
        self.onClose = onClose
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                CarPlatesScannerView { plates in
                    Task { @MainActor in
                        self.carPlates = plates
                        parseCarPlate(plates)
                        cameraAutoOff()
                    }
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
                                Text(carPlates)
                                    .font(.system(size: 30).bold())
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .animation(.easeInOut, value: carPlates)
                    }
                    .ignoresSafeArea()

                Text("camera")
                    .foregroundColor(.white)
                    .frame(maxHeight: 300, alignment: .top)
            }
            .onAppear { checkCameraPermission() }
            .alert(Text("alert"), isPresented: $showAlert) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("open-settings")
                }
                Button { onClose() } label: {
                    Text("cancel")
                }
            } message: {
                Text("alert")
            }
            .toolbar { toolBarItems() }
        }
    }


    // MARK: View components
    @ToolbarContentBuilder
    func toolBarItems() -> some ToolbarContent {

        ToolbarItem(placement: .principal) {
            Text("scan")
                .foregroundColor(Color.white)
        }

        ToolbarItem(placement: .topBarLeading) {
            Button{
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(Color.white)
                    .frame(width: 40, height: 40)
            }
        }
    }


    // MARK: Functions
    private func parseCarPlate(_ plate: String) {
        let cleaned = plate.replacingOccurrences(of: " ", with: "")
        guard cleaned.count >= 8 else {
            onPlatesDetected("", cleaned)
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
            onClose()
        }
    }
}

#Preview {
    CameraScanView(
        onPlatesDetected: { ser, num in

        },
        onClose: { }
    )
}

