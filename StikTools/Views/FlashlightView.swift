//
//  FlashlightView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI
import AVFoundation

struct FlashlightView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @State private var isFlashlightOn = false
    @State private var buttonScale: CGFloat = 1.0
    @State private var selectedBackgroundColor: Color = Color.primaryBackground

    var body: some View {
        ZStack {
            selectedBackgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Flashlight")
                    .font(.titleFont)
                    .foregroundColor(.primaryText)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    .shadow(color: isFlashlightOn ? Color.black.opacity(0.2) : Color.white.opacity(0.2), radius: 10, x: 0, y: 5)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.5)) {
                        toggleFlashlight()
                        buttonScale = isFlashlightOn ? 1.2 : 1.0
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(isFlashlightOn ? Color.black.opacity(0.8) : Color.white.opacity(0.8))
                            .frame(width: 150, height: 150)
                            .shadow(color: isFlashlightOn ? Color.black : Color.white, radius: 10, x: 0, y: 5)
                        
                        Circle()
                            .stroke(isFlashlightOn ? Color.white : Color.black, lineWidth: 5)
                            .frame(width: 130, height: 130)
                        
                        Image(systemName: isFlashlightOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 60))
                            .foregroundColor(isFlashlightOn ? .white : .black)
                            .scaleEffect(isFlashlightOn ? 1.2 : 1.0)
                    }
                    .scaleEffect(buttonScale)
                }
                .padding(.bottom, 100)
                
                Spacer()
            }
        }
        .onAppear {
            loadCustomBackgroundColor()
        }
    }

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }

    private func toggleFlashlight() {
        isFlashlightOn.toggle()
        giveHapticFeedback()
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = isFlashlightOn ? .on : .off
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }

    private func giveHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

