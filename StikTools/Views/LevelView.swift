//
//  LevelView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI
import CoreMotion
import CoreHaptics
import AVFoundation

struct LevelView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @ObservedObject private var motionManager = MotionManager()
    @State private var isCalibrated = false
    @State private var calibrationOffsetX: Double = 0.0
    @State private var calibrationOffsetY: Double = 0.0
    @State private var selectedBackgroundColor: Color = Color.primaryBackground
    
    var body: some View {
        ZStack {
            selectedBackgroundColor
                .ignoresSafeArea()
            
            VStack {
                Text("Leveling Tool")
                    .font(.titleFont)
                    .foregroundColor(.primaryText)
                    .padding()
                
                Spacer()
                
                HStack {
                    Text("X: \(motionManager.x, specifier: "%.2f")")
                    Text("Y: \(motionManager.y, specifier: "%.2f")")
                    Text("Z: \(motionManager.z, specifier: "%.2f")")
                }
                .foregroundColor(.primaryText)
                .padding()
                
                LevelIndicator(x: motionManager.x - calibrationOffsetX, y: motionManager.y - calibrationOffsetY)
                    .frame(width: 300, height: 300)
                    .padding()
                
                Spacer()
                
                Button(action: {
                    calibrate()
                }) {
                    Text("Calibrate")
                        .padding()
                        .background(.white.opacity(0.2))
                        .foregroundColor(.primaryText)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            motionManager.startUpdates()
            loadCustomBackgroundColor()
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
    }
    
    private func calibrate() {
        calibrationOffsetX = motionManager.x
        calibrationOffsetY = motionManager.y
        isCalibrated = true
    }

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
}


struct LevelIndicator: View {
    var x: Double
    var y: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.primaryText)
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(levelColor)
                .shadow(radius: 10)
                .offset(x: CGFloat(x * 150), y: CGFloat(y * 150))
                .animation(.easeInOut(duration: 0.2))
        }
    }
    
    private var levelColor: Color {
        if abs(x) < 0.05 && abs(y) < 0.05 {
            return .green
        } else {
            return .red
        }
    }
}

class MotionManager: ObservableObject {
    private var motionManager: CMMotionManager
    private var queue: OperationQueue
    private var hapticEngine: CHHapticEngine?
    
    @Published var x: Double = 0.0
    @Published var y: Double = 0.0
    @Published var z: Double = 0.0
    
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        motionManager = CMMotionManager()
        queue = OperationQueue()
        setupAudio()
        setupHaptics()
    }
    
    func startUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async {
                    self?.x = data.acceleration.x
                    self?.y = data.acceleration.y
                    self?.z = data.acceleration.z
                    
                    self?.provideFeedback()
                }
            }
        }
    }
    
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        stopHapticEngine()
    }
    
    private func setupAudio() {
        if let soundURL = Bundle.main.url(forResource: "level", withExtension: "wav") {
            audioPlayer = try? AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        }
    }
    
    private func setupHaptics() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    private func stopHapticEngine() {
        hapticEngine?.stop()
    }
    
    private func provideFeedback() {
        if abs(x) < 0.05 && abs(y) < 0.05 {
            audioPlayer?.play()
            playHaptic()
        }
    }
    
    private func playHaptic() {
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}
