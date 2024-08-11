//
//  ContentView.swift
//  StikTools
//
//  Created by Blu on 7/12/24.
//

import SwiftUI
import SafariServices
import AVFoundation
import CoreMotion
import CoreHaptics
import CoreImage.CIFilterBuiltins
import Combine
import UniformTypeIdentifiers

struct HomeView: View {
    @AppStorage("username") private var username = "User"
    @State private var tools: [AppTool] = [
        AppTool(imageName: "number.circle", title: "Random Number Generator", color: Color.red.opacity(0.2), destination: AnyView(RNGView())),
        AppTool(imageName: "qrcode", title: "QRCode", color: Color.orange.opacity(0.2), destination: AnyView(QRCodeGeneratorView())),
        AppTool(imageName: "level", title: "Level Tool", color: Color.yellow.opacity(0.2), destination: AnyView(LevelView())),
        AppTool(imageName: "flashlight.on.fill", title: "Flashlight", color: Color.yellow.opacity(0.2), destination: AnyView(FlashlightView())),
        AppTool(imageName: "plus.square", title: "Counter", color: Color.green.opacity(0.2), destination: AnyView(ContentView())),
        AppTool(imageName: "person.badge.key.fill", title: "Password Generator", color: Color.pink.opacity(0.2), destination: AnyView(PasswordGeneratorView())),
        AppTool(imageName: "pencil.circle.fill", title: "Whiteboard", color: Color.blue.opacity(0.2), destination: AnyView(DrawingView())),
        AppTool(imageName: "calendar", title: "College Planner", color: Color.indigo.opacity(0.2), destination: AnyView(PlannerView())),
        AppTool(imageName: "dollarsign", title: "Expense Tracker", color: Color.purple.opacity(0.2), destination: AnyView(BudgetView())),
        AppTool(imageName: "arrowshape.right.circle.fill", title: "Unit Converter (WIP)", color: Color.teal.opacity(0.2), destination: AnyView(UnitConverterView())),
    ]
    @State private var searchText: String = ""
    @State private var draggedItem: AppTool?
    @State private var draggedItemIndex: Int?

    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]

    var filteredTools: [AppTool] {
        if searchText.isEmpty {
            return tools
        } else {
            return tools.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(searchText: $searchText)
                    .padding(.horizontal)
                    .padding(.top)
                Text("")
                ScrollView {
                    Text("")
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredTools.indices, id: \.self) { index in
                            let tool = filteredTools[index]
                            NavigationLink(destination: tool.destination) {
                                VStack {
                                    Image(systemName: tool.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding()
                                    Text(tool.title)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity)
                                        .padding(.horizontal, 4)
                                        .padding(.bottom, 8)  // Added spacing under the title
                                }
                                .background(tool.color)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                                .padding(8)
                                .onDrag {
                                    self.draggedItem = tool
                                    self.draggedItemIndex = index
                                    return NSItemProvider(object: tool.title as NSString)
                                }
                                .onDrop(of: [.text], delegate: ToolDropDelegate(item: tool, tools: $tools, draggedItem: $draggedItem, draggedItemIndex: $draggedItemIndex, currentIndex: index))
                            }
                            .opacity(draggedItem == tool ? 0.5 : 1.0)
                            .scaleEffect(draggedItem == tool ? 1.1 : 1.0)
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
                .navigationBarTitle("Welcome \(username)!")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Use StackNavigationViewStyle for iPad
        }
    }
}

struct AppTool: Identifiable, Equatable {
    var id = UUID()
    var imageName: String
    var title: String
    var color: Color
    var destination: AnyView

    static func == (lhs: AppTool, rhs: AppTool) -> Bool {
        return lhs.id == rhs.id
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(8)
                .padding(.horizontal, 24)
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        if !searchText.isEmpty {
                            Button(action: {
                                self.searchText = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
        }
    }
}

struct ToolDropDelegate: DropDelegate {
    let item: AppTool
    @Binding var tools: [AppTool]
    @Binding var draggedItem: AppTool?
    @Binding var draggedItemIndex: Int?
    let currentIndex: Int

    func performDrop(info: DropInfo) -> Bool {
        withAnimation {
            draggedItem = nil
        }
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItemIndex = draggedItemIndex else { return }
        if draggedItemIndex != currentIndex {
            withAnimation {
                let fromIndex = draggedItemIndex
                let toIndex = currentIndex
                tools.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                self.draggedItemIndex = toIndex
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

struct SettingsView: View {
    @AppStorage("username") private var username = "User"

    var body: some View {
        Form {
            Section(header: Text("General").font(.headline).foregroundColor(.primary)) {
                HStack {
                    Label("Username", systemImage: "person.fill")
                        .foregroundColor(.primary)
                    Spacer()
                    TextField("Username", text: $username)
                        .multilineTextAlignment(.trailing)
                }
            }
            Section(header: Text("About").font(.headline).foregroundColor(.primary)) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                }
                HStack {
                    Text("Developed by")
                    Spacer()
                    Text("Stephen")
                }
                HStack {
                    Text("Icons by")
                    Spacer()
                    Text("Tyler")
                }
            }
        }
        .navigationBarTitle("Settings")
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .font(.body)
        .accentColor(.accentColor)
    }
}


struct FeatureCard: View {
    let tool: Tool

    @State private var isHovered = false

    var body: some View {
        VStack {
            Image(systemName: tool.imageName)
                .foregroundColor(.white)
                .font(.system(size: 50, weight: .bold))
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: tool.gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(Circle())
                .shadow(color: tool.gradientColors[1].opacity(0.5), radius: 10, x: 0, y: 5)
                .scaleEffect(isHovered ? 1.1 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0))

            Text(tool.title)
                .foregroundColor(.primary)
                .font(.headline)
        }
        .padding()
        .background(VisualEffectBlur(blurStyle: .systemThinMaterial))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
        )
        .padding([.leading, .trailing], 10)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct Tool: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let title: String
    let gradientColors: [Color]
    let destination: AnyView

    static func == (lhs: Tool, rhs: Tool) -> Bool {
        return lhs.id == rhs.id
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

struct WebView: View {
    let url: URL

    var body: some View {
        SafariView(url: url)
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        return safariViewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Update the view controller if needed
    }
}

struct FlashlightView: View {
    @State private var isFlashlightOn = false
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: isFlashlightOn ? [Color.white, Color.gray] : [Color.black, Color.gray]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Flashlight")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(isFlashlightOn ? .black : .white)
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

struct LevelView: View {
    @ObservedObject private var motionManager = MotionManager()
    @State private var isCalibrated = false
    @State private var calibrationOffsetX: Double = 0.0
    @State private var calibrationOffsetY: Double = 0.0
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.purple, .orange]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                Text("Leveling Tool")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack {
                    Text("X: \(motionManager.x, specifier: "%.2f")")
                    Text("Y: \(motionManager.y, specifier: "%.2f")")
                    Text("Z: \(motionManager.z, specifier: "%.2f")")
                }
                .foregroundColor(.white)
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
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            motionManager.startUpdates()
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
}

struct LevelIndicator: View {
    var x: Double
    var y: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 4)
                .foregroundColor(.white)
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
struct QRCodeGeneratorView: View {
    @State private var qrCodeText = ""
    @State private var qrCodeImage: UIImage?
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("QR Code Generator")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                TextField("Enter text for QR code", text: $qrCodeText)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                
                Button(action: generateQRCode) {
                    Text("Generate QR Code")
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(FancyButtonStyle())
                
                Button(action: exportQRCode) {
                    Text("Export QR Code")
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: 20)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(FancyButtonStyle())
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("QR Code Saved"),
                        message: Text("QR Code saved to Photos."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding(.horizontal, 20)
            
            if let image = qrCodeImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    .padding()
            } else {
                Text("No QR Code available")
                    .foregroundColor(.gray)
                    .font(.body)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            qrCodeText = ""
            generateQRCode()
        }
    }
    
    func generateQRCode() {
        guard let data = qrCodeText.data(using: .utf8) else {
            qrCodeImage = nil
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(data, forKey: "inputMessage")
        
        // Adjust image size for higher resolution (e.g., 500x500 points)
        let qrCodeSize = CGSize(width: 500, height: 500)
        
        guard let ciImage = filter.outputImage else {
            qrCodeImage = nil
            return
        }
        
        let scaleX = qrCodeSize.width / ciImage.extent.width
        let scaleY = qrCodeSize.height / ciImage.extent.height
        
        let scaledCIImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else {
            qrCodeImage = nil
            return
        }
        
        qrCodeImage = UIImage(cgImage: cgImage)
    }
    
    func exportQRCode() {
        guard let image = qrCodeImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        showingAlert = true
    }
}

struct FancyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.gray.opacity(0.8) : Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1))
    }
}
struct RNGView: View {
    @State private var randomNumber: Int = 0
    @State private var isGenerating: Bool = false
    @State private var minRange: String = "1"
    @State private var maxRange: String = "100"
    @State private var errorMessage: String? = nil

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Random Number Generator")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text("\(randomNumber)")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Set Range:")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack {
                        VStack {
                            Text("Min")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("Min", text: $minRange)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                        }

                        VStack {
                            Text("Max")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            TextField("Max", text: $maxRange)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    generateRandomNumber()
                    animateButton()
                }) {
                    Text("Generate Random Number")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.orange]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                        .opacity(isGenerating ? 0.6 : 1.0)
                        .scaleEffect(isGenerating ? 0.9 : 1.0)
                        .animation(.spring())
                }
                .padding()
                .disabled(isGenerating)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                Spacer()
            }
            .padding()
        }
    }

    private func generateRandomNumber() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let min = Int(minRange), let max = Int(maxRange), min < max {
                self.randomNumber = Int.random(in: min...max)
                self.errorMessage = nil
            } else {
                self.errorMessage = "Invalid range. Please enter valid numbers."
            }
            self.isGenerating = false
        }
    }

    private func animateButton() {
        withAnimation {
            isGenerating.toggle()
        }
    }
}

struct ContentView: View {
    @AppStorage("counter") private var storedCounter = 0
    @State private var counter = 0
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                Spacer()
                
                Text("Counter")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(GlassBackground())
                    .cornerRadius(15)
                    .shadow(radius: 10)
                
                Text("\(counter)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.white, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .background(GlassBackground())
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .animation(.spring(), value: counter)
                
                HStack(spacing: 40) {
                    CounterButton(title: "-", colors: [.red, .orange], action: {
                        counter -= 1
                        storedCounter = counter
                        withAnimation(.easeInOut) {
                            buttonScale = 0.9
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut) {
                                buttonScale = 1.0
                            }
                        }
                    })
                    .scaleEffect(buttonScale)
                    
                    CounterButton(title: "+", colors: [.green, .blue], action: {
                        counter += 1
                        storedCounter = counter
                        withAnimation(.easeInOut) {
                            buttonScale = 0.9
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut) {
                                buttonScale = 1.0
                            }
                        }
                    })
                    .scaleEffect(buttonScale)
                }
                
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(
                LinearGradient(gradient: Gradient(colors: [.black, .blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                counter = storedCounter
            }
        }
    }
}


struct GlassBackground: View {
    var body: some View {
        VisualEffectBlur2(blurStyle: .systemUltraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
    }
}

struct CounterButton: View {
    var title: String
    var colors: [Color]
    var action: () -> Void
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        Button(action: {
            impactFeedback()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
                action()
                buttonScale = 1.2
            }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0).delay(0.1)) {
                buttonScale = 1.0
            }
        }) {
            Text(title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing))
                )
                .foregroundColor(.white)
                .shadow(radius: 10)
                .scaleEffect(buttonScale)
        }
    }
    
    private func impactFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

struct VisualEffectBlur2: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
struct PasswordGeneratorView: View {
    @State private var password: String = ""
    @State private var passwordLength: Double = 12
    @State private var includeUppercase = true
    @State private var includeLowercase = true
    @State private var includeNumbers = true
    @State private var includeSymbols = true
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Password Generator")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 100)
                .foregroundColor(Color.white)
                .shadow(radius: 10)

            Text(password)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = password
                        showAlert = true
                    }) {
                        Text("Copy to Clipboard")
                        Image(systemName: "doc.on.doc")
                    }
                }

            VStack(spacing: 10) {
                HStack {
                    Toggle(isOn: $includeUppercase) {
                        Text("Uppercase")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    Toggle(isOn: $includeLowercase) {
                        Text("Lowercase")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                HStack {
                    Toggle(isOn: $includeNumbers) {
                        Text("Numbers")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                    Toggle(isOn: $includeSymbols) {
                        Text("Symbols")
                            .foregroundColor(.white)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
            }
            .padding(.horizontal)

            Slider(value: $passwordLength, in: 8...32, step: 1)
                .padding(.horizontal)
                .accentColor(.blue)
            Text("Password Length: \(Int(passwordLength))")
                .foregroundColor(.white)

            Button(action: {
                withAnimation {
                    password = generatePassword(length: Int(passwordLength))
                }
            }) {
                Text("Generate Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .shadow(radius: 10)
            }

            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.purple]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Copied"), message: Text("Password copied to clipboard!"), dismissButton: .default(Text("OK")))
        }
    }

    func generatePassword(length: Int) -> String {
        var characterSet = ""
        if includeUppercase {
            characterSet += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        if includeLowercase {
            characterSet += "abcdefghijklmnopqrstuvwxyz"
        }
        if includeNumbers {
            characterSet += "0123456789"
        }
        if includeSymbols {
            characterSet += "!@#$%^&*()_-+=<>?"
        }
        if characterSet.isEmpty {
            return "Select at least one character set"
        }
        return String((0..<length).compactMap { _ in characterSet.randomElement() })
    }
}

struct FilePickerView: View {
    @Binding var selectedFile: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Select a text file to load:")
            
            Button(action: {
                loadTextFromFile()
            }) {
                Text("Choose File")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            .padding()
        }
        .padding()
    }
    
    private func loadTextFromFile() {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.plainText], asCopy: true)
        documentPicker.delegate = Coordinator(parent: self)
        UIApplication.shared.windows.first?.rootViewController?.present(documentPicker, animated: true, completion: nil)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePickerView
        
        init(parent: FilePickerView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let selectedFileURL = urls.first else { return }
            
            do {
                let fileContents = try String(contentsOf: selectedFileURL)
                self.parent.selectedFile = fileContents
            } catch {
                print("Error reading contents of selected file: \(error.localizedDescription)")
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct DrawingView: View {
    @State private var currentPath = Path()
    @State private var paths: [Path] = []
    @State private var color: Color = .black
    @State private var lineWidth: Double = 2
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack {
                Canvas { context, size in
                    for path in paths {
                        context.stroke(path, with: .color(color), lineWidth: lineWidth)
                    }
                    context.stroke(currentPath, with: .color(color), lineWidth: lineWidth)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newPoint = value.location
                            if value.translation == .zero {
                                currentPath.move(to: newPoint)
                            } else {
                                currentPath.addLine(to: newPoint)
                            }
                        }
                        .onEnded { value in
                            paths.append(currentPath)
                            currentPath = Path()
                        }
                )
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray, radius: 10, x: 0, y: 5)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                HStack {
                    ColorPicker("Color", selection: $color)
                        .padding()
                        .background(BlurView(style: .systemThinMaterial))
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                    
                    Slider(value: $lineWidth, in: 1...10, step: 1) {
                        Text("Line Width")
                    }
                    .padding()
                    .background(BlurView(style: .systemThinMaterial))
                    .cornerRadius(10)
                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("Whiteboard", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    paths.removeAll()
                }) {
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// Define the ClassEvent struct
struct ClassEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var startTime: Date
    var endTime: Date
    var location: String
    var description: String
    var dayOfWeek: String
}

// Sample data for testing
let sampleEvents = [
    ClassEvent(name: "Math 101", startTime: Date(), endTime: Date().addingTimeInterval(3600), location: "Room 101", description: "Algebra and Geometry", dayOfWeek: "Monday"),
    ClassEvent(name: "English Literature", startTime: Date().addingTimeInterval(7200), endTime: Date().addingTimeInterval(10800), location: "Room 202", description: "Shakespeare and Poetry", dayOfWeek: "Tuesday"),
    // Add more sample events as needed
]

// DateFormatter extension for short time format
extension DateFormatter {
    static var shortTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

// Main view for the planner app
struct PlannerView: View {
    @AppStorage("eventsData") private var eventsData: Data = Data()
    @State private var events: [ClassEvent] = []
    @State private var showingAddEventSheet = false

    var groupedEvents: [String: [ClassEvent]] {
        Dictionary(grouping: events, by: { $0.dayOfWeek })
    }

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(groupedEvents.keys.sorted(), id: \.self) { day in
                        Section(header: Text(day).font(.title3).fontWeight(.semibold).foregroundColor(.primary)) {
                            ForEach(groupedEvents[day]!, id: \.id) { event in
                                NavigationLink(destination: EventDetailView(event: Binding(get: {
                                    if let index = events.firstIndex(where: { $0.id == event.id }) {
                                        return events[index]
                                    }
                                    return event
                                }, set: { newValue in
                                    if let index = events.firstIndex(where: { $0.id == event.id }) {
                                        events[index] = newValue
                                    }
                                }))) {
                                    EventRowView(event: event)
                                }
                            }
                            .onDelete { indices in
                                if let index = events.firstIndex(where: { $0.id == groupedEvents[day]![indices.first!].id }) {
                                    events.remove(at: index)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("College Planner")
                .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddEventSheet = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                        }
                        .padding()
                        .sheet(isPresented: $showingAddEventSheet) {
                            AddEventView(events: $events)
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadEvents)
        .onChange(of: events, perform: { _ in saveEvents() })
    }

    private func loadEvents() {
        if let decoded = try? JSONDecoder().decode([ClassEvent].self, from: eventsData) {
            events = decoded
        } else {
            events = sampleEvents
        }
    }

    private func saveEvents() {
        if let encoded = try? JSONEncoder().encode(events) {
            eventsData = encoded
        }
    }
}

// Detail view for event
struct EventDetailView: View {
    @Binding var event: ClassEvent

    var body: some View {
        ZStack {
            // Background that adapts to dark and light modes
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(event.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                        .foregroundColor(.primary) // Adapts to dark mode
                    
                    Text(event.dayOfWeek)
                        .font(.title2)
                        .foregroundColor(.secondary) // Adapts to dark mode
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(event.startTime, formatter: DateFormatter.shortTime) - \(event.endTime, formatter: DateFormatter.shortTime)")
                    }
                    .font(.title2)
                    .padding(.bottom, 5)
                    .foregroundColor(.primary) // Adapts to dark mode
                    
                    HStack {
                        Image(systemName: "location")
                        Text(event.location)
                    }
                    .font(.title3)
                    .foregroundColor(.secondary) // Adapts to dark mode
                    .padding(.bottom, 20)
                    
                    Text(event.description)
                        .font(.body)
                        .foregroundColor(.primary) // Adapts to dark mode
                    
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground)) // Adapts to dark mode
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding()
            }
        }
        .navigationTitle("Class Details")
    }
}


// Helper view for displaying each event in the list
struct EventRowView: View {
    var event: ClassEvent

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("\(event.startTime, formatter: DateFormatter.shortTime) - \(event.endTime, formatter: DateFormatter.shortTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5))
        .padding(.vertical, 5)
    }
}

// View for adding a new event
struct AddEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var events: [ClassEvent]
    @State private var name = ""
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    @State private var location = ""
    @State private var description = ""
    @State private var selectedDayOfWeek = "Monday"

    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Class Info").foregroundColor(.primary)) {
                    TextField("Class Name", text: $name)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)

                    Picker("Day of the Week", selection: $selectedDayOfWeek) {
                        ForEach(daysOfWeek, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 10)

                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .foregroundColor(.primary)

                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .foregroundColor(.primary)

                    TextField("Location", text: $location)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)

                    TextField("Description", text: $description)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .foregroundColor(.primary)
                }
            }
            .navigationTitle("Add New Class")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Add") {
                let newEvent = ClassEvent(name: name, startTime: startTime, endTime: endTime, location: location, description: description, dayOfWeek: selectedDayOfWeek)
                events.append(newEvent)
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(name.isEmpty || location.isEmpty || description.isEmpty))
        }
        .accentColor(.blue) // Adjust accent color for better contrast in dark mode
    }
}

struct PlannerView_Previews: PreviewProvider {
    static var previews: some View {
        PlannerView()
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: .constant(sampleEvents[0]))
    }
}

struct EventRowView_Previews: PreviewProvider {
    static var previews: some View {
        EventRowView(event: sampleEvents[0])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

// Model
struct BudgetEntry: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var category: String
    var amount: Double
    var isIncome: Bool
}

// ViewModel
class BudgetViewModel: ObservableObject {
    @AppStorage("budgetEntries") private var budgetEntriesData: Data = Data()
    @Published var entries: [BudgetEntry] = []

    init() {
        loadEntries()
    }

    var totalIncome: Double {
        entries.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    var totalExpenses: Double {
        entries.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }

    var balance: Double {
        totalIncome - totalExpenses
    }

    func addEntry(_ entry: BudgetEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveEntries()
    }

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            budgetEntriesData = encoded
        }
    }

    private func loadEntries() {
        if let decoded = try? JSONDecoder().decode([BudgetEntry].self, from: budgetEntriesData) {
            entries = decoded
        }
    }
}

// Budget Overview View
struct BudgetOverviewView: View {
    @ObservedObject var viewModel: BudgetViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Income")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("$\(viewModel.totalIncome, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Expenses")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("$\(viewModel.totalExpenses, specifier: "%.2f")")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("$\(viewModel.balance, specifier: "%.2f")")
                        .font(.title)
                        .bold()
                        .foregroundColor(viewModel.balance >= 0 ? .white : .red)
                }
                Spacer()
                Image(systemName: viewModel.balance >= 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(viewModel.balance >= 0 ? .blue : .red)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// Add Entry View
struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: BudgetViewModel

    @State private var date = Date()
    @State private var category = ""
    @State private var amount = ""
    @State private var isIncome = false

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Category", text: $category)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                Toggle(isOn: $isIncome) {
                    Text("Income")
                }
            }
            .navigationTitle("Add Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = Double(amount) {
                            let entry = BudgetEntry(date: date, category: category, amount: amount, isIncome: isIncome)
                            viewModel.addEntry(entry)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .accentColor(.purple)
    }
}

// Main Budget View
struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingAddEntry = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                BudgetOverviewView(viewModel: viewModel)
                    .padding(.horizontal)

                List {
                    ForEach(viewModel.entries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.category)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(entry.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("$\(entry.amount, specifier: "%.2f")")
                                .font(.headline)
                                .foregroundColor(entry.isIncome ? .green : .red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(entry.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                    }
                    .onDelete(perform: viewModel.deleteEntry)
                    .listRowBackground(Color.clear)
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Expense Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddEntry = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.purple)
                        }
                    }
                }
                .sheet(isPresented: $showingAddEntry) {
                    AddEntryView(viewModel: viewModel)
                }
            }
            .background(Color(UIColor.systemGray5).edgesIgnoringSafeArea(.all))
        }
        .accentColor(.purple)
    }
}
//
//  UnitConverterView.swift
//  StikTools
//
//  Created by Tech Guy on 10/8/24.
//

import SwiftUI

struct UnitConverterView: View {
    @State private var inputValue = ""
    @State private var selectedCategory = "Length"
    @State private var selectedInputUnit = "Meters"
    @State private var selectedOutputUnit = "Kilometers"
    
    let categories = ["Length", "Weight", "Temperature"]
    let units = [
        "Length": ["Meters", "Kilometers", "Feet", "Miles"],
        "Weight": ["Grams", "Kilograms", "Pounds", "Ounces"],
        "Temperature": ["Celsius", "Fahrenheit", "Kelvin"]
    ]
    
    var convertedValue: Double {
        guard let value = Double(inputValue) else { return 0 }
        
        switch selectedCategory {
        case "Length":
            return convertLength(value: value, from: selectedInputUnit, to: selectedOutputUnit)
        case "Weight":
            return convertWeight(value: value, from: selectedInputUnit, to: selectedOutputUnit)
        case "Temperature":
            return convertTemperature(value: value, from: selectedInputUnit, to: selectedOutputUnit)
        default:
            return 0
        }
    }
    
    var body: some View {
        VStack {
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedCategory) { _ in
                selectedInputUnit = units[selectedCategory]?.first ?? ""
                selectedOutputUnit = units[selectedCategory]?.last ?? ""
            }
            
            TextField("Enter value", text: $inputValue)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Picker("From Unit", selection: $selectedInputUnit) {
                ForEach(units[selectedCategory] ?? [], id: \.self) { unit in
                    Text(unit)
                }
            }
            .padding()
            
            Picker("To Unit", selection: $selectedOutputUnit) {
                ForEach(units[selectedCategory] ?? [], id: \.self) { unit in
                    Text(unit)
                }
            }
            .padding()
            
            Text("Converted Value: \(convertedValue, specifier: "%.2f")")
                .font(.title)
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func convertLength(value: Double, from: String, to: String) -> Double {
        let conversionTable: [String: Double] = [
            "Meters": 1.0,
            "Kilometers": 1000.0,
            "Feet": 0.3048,
            "Miles": 1609.34
        ]
        
        if let fromValue = conversionTable[from], let toValue = conversionTable[to] {
            return value * fromValue / toValue
        }
        
        return value
    }
    
    func convertWeight(value: Double, from: String, to: String) -> Double {
        let conversionTable: [String: Double] = [
            "Grams": 1.0,
            "Kilograms": 1000.0,
            "Pounds": 453.592,
            "Ounces": 28.3495
        ]
        
        if let fromValue = conversionTable[from], let toValue = conversionTable[to] {
            return value * fromValue / toValue
        }
        
        return value
    }
    
    func convertTemperature(value: Double, from: String, to: String) -> Double {
        switch (from, to) {
        case ("Celsius", "Fahrenheit"):
            return (value * 9/5) + 32
        case ("Fahrenheit", "Celsius"):
            return (value - 32) * 5/9
        case ("Celsius", "Kelvin"):
            return value + 273.15
        case ("Kelvin", "Celsius"):
            return value - 273.15
        case ("Fahrenheit", "Kelvin"):
            return (value - 32) * 5/9 + 273.15
        case ("Kelvin", "Fahrenheit"):
            return (value - 273.15) * 9/5 + 32
        default:
            return value
        }
    }
}

struct UnitConverterView_Previews: PreviewProvider {
    static var previews: some View {
        UnitConverterView()
    }
}

#Preview {
    HomeView()
}
