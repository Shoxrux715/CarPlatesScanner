//
//  CutoutMask.swift
//  CarPlatesScanner
//
//  Created by Shoxrux Khodjaev on 01/05/2025.
//

import SwiftUI
import AVFoundation
import Vision

public struct CutoutMask: Shape {
    public var size: CGSize

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(rect)
        let cutoutOrigin = CGPoint(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2
        )
        let cutout = CGRect(origin: cutoutOrigin, size: size)
        path.addRoundedRect(in: cutout, cornerSize: CGSize(width: 16, height: 16))
        return path
    }
}
