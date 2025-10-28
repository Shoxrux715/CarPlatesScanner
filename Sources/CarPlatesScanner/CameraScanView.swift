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
    public var scannedPlatesTextColor: Color
    public var toolBarItemsColor: Color
    public var cameraViewBgColor: Color
    public var cameraViewBgColorOpacity: Double
    public var cutoutWidth: CGFloat
    public var cutoutHeight: CGFloat
    public var cutoutStrokeColor: Color
    public var cutoutStrokeLineWidth: CGFloat
    public var font: Font
  
    @State public var showAlert: Bool = false
    @State public var accessGranted: Bool = false

    @State public var carPlates: String = ""
    
    public var cutoutSize = CGSize(width: UIScreen.main.bounds.width * 3/4, height: 100)
    
    /// Инициализация с возможностью настройки внешнего вида
    public init(
        scannedPlatesTextColor: Color? = nil,
        toolBarItemsColor: Color? = nil,
        cameraViewBackgroundColor: Color? = nil,
        cameraViewBackgroundColorOpacity: Double? = nil,
        cutoutWidth: CGFloat? = nil,
        cutoutHeight: CGFloat? = nil,
        cutoutStrokeColor: Color? = nil,
        cutoutStrokeLineWidth: CGFloat? = nil,
        font: Font? = nil,
        onPlatesDetected: @escaping @MainActor (String, String) -> Void,
        onClose: @escaping @MainActor () -> Void
    ) {
        self.scannedPlatesTextColor = scannedPlatesTextColor ?? .white
        self.toolBarItemsColor = toolBarItemsColor ?? .white
        self.cameraViewBgColor = cameraViewBackgroundColor ?? .black
        self.cameraViewBgColorOpacity = cameraViewBackgroundColorOpacity ?? 0.3
        self.cutoutWidth = cutoutWidth ?? cutoutSize.width
        self.cutoutHeight = cutoutHeight ?? cutoutSize.height
        self.cutoutSize = CGSize(width: cutoutWidth ?? cutoutSize.width, height: cutoutHeight ?? cutoutSize.height)
        self.cutoutStrokeColor = cutoutStrokeColor ?? .white
        self.cutoutStrokeLineWidth = cutoutStrokeLineWidth ?? 5
        self.font = font ?? .system(size: 20)
        self.onPlatesDetected = onPlatesDetected
        self.onClose = onClose
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                /// Основной компонент, который обрабатывает видеопоток и распознает номера
                CarPlatesScannerView { plates in
                    Task { @MainActor in
                        self.carPlates = plates
                        parseCarPlate(plates)
                        cameraAutoOff()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                /// Затемненная маска с вырезом (cutout) посередине
                Rectangle()
                    .fill(cameraViewBgColor.opacity(cameraViewBgColorOpacity))
                    .mask(
                        CutoutMask(size: cutoutSize)
                            .fill(style: FillStyle(eoFill: true))
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(cutoutStrokeColor, lineWidth: cutoutStrokeLineWidth)
                            .frame(
                                width: cutoutWidth,
                                height: cutoutHeight)
                    )
                    .overlay {
                        /// Отображение распознанного номера поверх камеры
                        HStack(alignment: .center) {
                            if !carPlates.isEmpty {
                                Text(carPlates)
                                    .font(font)
                                    .foregroundStyle(scannedPlatesTextColor)
                            }
                        }
                        .animation(.easeInOut, value: carPlates)
                    }
                    .ignoresSafeArea()
                
                /// Подсказка пользователю
                Text("point-the-camera", bundle: .module)
                    .font(font)
                    .foregroundColor(Color.white)
                    .frame(maxHeight: 300, alignment: .top)
            }
            .onAppear { checkCameraPermission() }
            /// Алерт, если не предоставлен доступ к камере
            .alert(Text("no-access", bundle: .module), isPresented: $showAlert) {
                Button {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("open-settings", bundle: .module)
                }
                Button { onClose() } label: {
                    Text("cancel", bundle: .module)
                }
            } message: {
                Text("allow-in-settings", bundle: .module)
            }
            /// Верхняя панель с кнопками и заголовком
            .toolbar { toolBarItems() }
        }
    }
        
    
    // MARK: View components
    @ToolbarContentBuilder
    func toolBarItems() -> some ToolbarContent {
        
        ToolbarItem(placement: .principal) {
            Text("scan-number", bundle: .module)
                .font(font)
                .foregroundColor(toolBarItemsColor)
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Button{
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .foregroundColor(toolBarItemsColor)
                    .frame(width: 40, height: 40)
                    .padding()
            }
        }
    }
    
    
    // MARK: Functions
    /// Разделяет строку номера на серию и основную часть
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
    /// Проверяет доступ к камере, при необходимости запрашивает разрешение
    private func checkCameraPermission() {
        DispatchQueue.init(label: "carPlatesScanner.sessionQueue").async {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                DispatchQueue.main.async {
                    showAlert = false
                }
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        showAlert = !granted
                    }
                }
                
            default:
                DispatchQueue.main.async {
                    showAlert = true
                }
            }
        }
    }
    /// Автоматически закрывает камеру через 1 секунду после успешного распознавания
    private func cameraAutoOff() {
        guard !carPlates.isEmpty else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            carPlates = ""
            onClose()
        }
    }
}

#Preview {
    CameraScanView(onPlatesDetected: { ser, num in
        
    }, onClose: {
        
    })
}

