//
//  ContentView.swift
//  Demo
//
//  Created by Shoxrux Khodjaev on 31/07/2025.
//

import SwiftUI
import CarPlatesScanner

struct ContentView: View {
    
    @State private var carNumber: String = ""
    @State private var isScanning: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack {
                Spacer()
                
                HStack {
                    Text(carNumber)
                        .font(.headline.bold())
                }
                .padding(.vertical)
                
                Button {
                    isScanning = true
                } label: {
                    Text("Scan number")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                }
                
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $isScanning) {
            CameraScanView { series, number in
                // Series -> region code (01,10,20, etc.)
                // Number -> body (A123AA, 123AAA, etc.)
                // Combining both of them will create a whole number, however you can interact with each string as you want
                carNumber = series + number
            }
        }
    }
    
}

#Preview {
    ContentView()
}
