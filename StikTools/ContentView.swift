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

// Extension to convert Color to Hex String and back
extension Color {
    func toHex() -> String? {
        let components = UIColor(self).cgColor.components
        let r = Float(components?[0] ?? 0)
        let g = Float(components?[1] ?? 0)
        let b = Float(components?[2] ?? 0)
        let hex = String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        return "#" + hex
    }
    
    init?(hex: String) {
        let r, g, b: CGFloat
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count == 6, let hexNumber = Int(hexColor, radix: 16) {
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000ff) / 255
            self.init(red: r, green: g, blue: b)
            return
        }

        return nil
    }
}

// Define a theme
extension Color {
    static let primaryBackground = Color.teal
    static let cardBackground = Color.white.opacity(0.2)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.7)
}

extension Font {
    static let titleFont = Font.system(size: 24, weight: .bold)
    static let bodyFont = Font.system(size: 18, weight: .regular)
    static let captionFont = Font.system(size: 14, weight: .medium)
}

// Reusable button style
struct FancyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.primaryText)
            .background(configuration.isPressed ? Color.gray.opacity(0.8) : Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1))
    }
}

// Reusable card style
struct FancyCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }
}

// SettingsView with custom background color selection
struct SettingsView: View {
    @AppStorage("username") private var username = "User"
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080" // default teal color

    @State private var selectedBackgroundColor: Color = Color.primaryBackground

    var body: some View {
        ZStack {
            // Apply the selected background color
            selectedBackgroundColor
                .ignoresSafeArea()

            Form {
                Section(header: Text("General").font(.headline).foregroundColor(.primaryText)) {
                    HStack {
                        Label("", systemImage: "person.fill")
                            .foregroundColor(.primaryText)
                        Spacer()
                        TextField("Username", text: $username)
                            .foregroundColor(.primaryText)
                            .padding(10)
                            .background(Color.cardBackground)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedBackgroundColor, lineWidth: 1)
                            )
                    }
                    .listRowBackground(Color.cardBackground)
                }
                
                Section(header: Text("Appearance").font(.headline).foregroundColor(.primaryText)) {
                    ColorPicker("Background Color", selection: $selectedBackgroundColor)
                        .onChange(of: selectedBackgroundColor) { newColor in
                            saveCustomBackgroundColor(newColor)
                        }
                        .listRowBackground(Color.cardBackground)
                        .foregroundColor(.primaryText)
                }

                Section(header: Text("About").font(.headline).foregroundColor(.primaryText)) {
                    HStack {
                        Text("Version:")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        Text("1.1.0")
                            .foregroundColor(.primaryText)
                    }
                    .listRowBackground(Color.cardBackground)
                    
                    HStack {
                        Text("Creator:")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        Text("Stephen")
                            .foregroundColor(.primaryText)
                    }
                    .listRowBackground(Color.cardBackground)
                    HStack {
                        Text("Collaborators:")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        Text("TechGuy")
                            .foregroundColor(.primaryText)
                    }
                    .listRowBackground(Color.cardBackground)

                    HStack {
                        Text("Icons by:")
                            .foregroundColor(.secondaryText)
                        Spacer()
                        Text("Tyler")
                            .foregroundColor(.primaryText)
                    }
                    .listRowBackground(Color.cardBackground)
                }
            }
            .background(selectedBackgroundColor)
            .scrollContentBackground(.hidden)
            .navigationBarTitle("Settings")
            .font(.bodyFont)
            .accentColor(.accentColor)
        }
        .onAppear {
            loadCustomBackgroundColor()
        }
    }

    // Load custom background color from stored hex string
    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }

    // Save custom background color as hex string
    private func saveCustomBackgroundColor(_ color: Color) {
        customBackgroundColorHex = color.toHex() ?? "#008080"
    }
}

// Example of HomeView integrating the theme and background color setting

struct HomeView: View {
    @AppStorage("username") private var username = "User"
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @AppStorage("hasAcceptedPrivacyPolicy") private var hasAcceptedPrivacyPolicy: Bool = false

    @State private var selectedBackgroundColor: Color = Color.primaryBackground
    @State private var tools: [AppTool] = [
        AppTool(imageName: "number.circle", title: "Random Number Generator", color: Color.red.opacity(0.2), destination: AnyView(RNGView())),
        AppTool(imageName: "qrcode", title: "QRCode", color: Color.orange.opacity(0.2), destination: AnyView(QRCodeGeneratorView())),
        AppTool(imageName: "level", title: "Level Tool", color: Color.yellow.opacity(0.2), destination: AnyView(LevelView())),
        AppTool(imageName: "plus.square", title: "Counter", color: Color.green.opacity(0.2), destination: AnyView(ContentView())),
        AppTool(imageName: "pencil.circle.fill", title: "Whiteboard", color: Color.blue.opacity(0.2), destination: AnyView(DrawingView()))
    ]
    @State private var searchText: String = ""
    @State private var newsItems: [NewsItem] = [] // News items will be loaded here
    @State private var showPrivacyPolicyAlert: Bool = false // State for showing the privacy policy alert
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    selectedBackgroundColor
                        .ignoresSafeArea(.all)

                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hello, \(username)!")
                                    .font(.system(size: geometry.size.width > 600 ? 40 : 30, weight: .bold))
                                    .foregroundColor(.primaryText)
                                Text("What would you like to do today?")
                                    .font(.system(size: geometry.size.width > 600 ? 24 : 18))
                                    .foregroundColor(.secondaryText)
                            }
                            Spacer()
                            NavigationLink(destination: SettingsView()) {
                                Image(systemName: "gearshape.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.white)
                                    .padding(.trailing, geometry.size.width > 600 ? 20 : 0)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, geometry.safeAreaInsets.top + 10)
                        
                        // News Section
                        if !newsItems.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Latest News")
                                    .font(.headline)
                                    .foregroundColor(.primaryText)
                                    .padding(.horizontal)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(newsItems) { item in
                                            NewsCard(newsItem: item)
                                                .frame(width: geometry.size.width * (geometry.size.width > 600 ? 0.4 : 0.8))
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 10)
                        }
                        
                        // Join Discord Button Styled as an App Tool
                        FancyCard {
                            Button(action: {
                                joinDiscord()
                            }) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Join the Discord")
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
                                }
                                .padding()
                                .frame(width: geometry.size.width * 0.855, height: geometry.size.height * 0.05)
                            }
                        }
                        .padding(.vertical)
                        
                        // Tool Grid
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.adaptive(minimum: geometry.size.width * 0.25), spacing: 20)
                            ], spacing: 30) {
                                ForEach(tools) { tool in
                                    NavigationLink(destination: tool.destination) {
                                        FancyCard {
                                            VStack {
                                                Image(systemName: tool.imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                                                    .foregroundColor(.white)
                                                    .padding()
                                                Text(tool.title)
                                                    .font(.captionFont)
                                                    .foregroundColor(.primaryText)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.bottom, 10) // Added spacing below the AppTool name
                                            }
                                            .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .background(Color.clear)
                    }
                    .padding(.bottom)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            loadCustomBackgroundColor()
            #if targetEnvironment(simulator)
            loadLocalNews() // Load local news for simulator
            #else
            loadNews() // Load news from the server on a real device
            #endif
            
            // Show privacy policy alert if not accepted
            if !hasAcceptedPrivacyPolicy {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showPrivacyPolicyAlert = true
                }
            }
        }
        .onReceive(timer) { _ in
            loadCustomBackgroundColor()
        }
        .alert(isPresented: $showPrivacyPolicyAlert) {
            Alert(
                title: Text("Privacy Policy"),
                message: Text("By using this app, you agree to our privacy policy. Please review it carefully."),
                primaryButton: .default(Text("Read Policy"), action: {
                    if let url = URL(string: "https://stiktools.xyz/privacy.html") {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .default(Text("Accept"), action: {
                    hasAcceptedPrivacyPolicy = true
                })
            )
        }
    }

    
    // Function to open Discord link
    func joinDiscord() {
        if let url = URL(string: "https://discord.gg/qwcxgjg7rc") {
            UIApplication.shared.open(url)
        }
    }
    
    // Function to load news from JSON
    func loadNews() {
        guard let url = URL(string: "https://stiktools.xyz/news.json") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedNews = try JSONDecoder().decode([NewsItem].self, from: data)
                    DispatchQueue.main.async {
                        newsItems = decodedNews
                    }
                } catch {
                    print("Failed to decode news JSON: \(error)")
                }
            }
        }.resume()
    }

    // Function to load local news (for simulator)
    func loadLocalNews() {
        // Attempt to find the path of the local JSON file
        if let path = Bundle.main.path(forResource: "localNews", ofType: "json") {
            do {
                // Attempt to load the contents of the file into a Data object
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                
                // Optional: Print the raw JSON data as a string for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("JSON Data: \(jsonString)")
                }
                
                // Attempt to decode the JSON data into an array of NewsItem objects
                let decodedNews = try JSONDecoder().decode([NewsItem].self, from: data)
                
                // Update the newsItems array with the decoded data
                newsItems = decodedNews
            } catch let DecodingError.dataCorrupted(context) {
                print("Data corrupted: \(context.debugDescription)")
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type '\(type)' mismatch: \(context.debugDescription), codingPath: \(context.codingPath)")
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found: \(context.debugDescription), codingPath: \(context.codingPath)")
            } catch {
                print("Failed to load local news JSON: \(error.localizedDescription)")
            }
        } else {
            print("Failed to find the JSON file.")
        }
    }

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
}




// Example NewsItem model
struct NewsItem: Identifiable, Decodable {
    let id: String
    let title: String
    let subtitle: String
}

// Example NewsCard view
struct NewsCard: View {
    let newsItem: NewsItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(newsItem.title)
                .font(.headline)
                .foregroundColor(.primaryText)
            Text(newsItem.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 2)
        .frame(width: 250) // Adjust width as needed
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

// SearchBar View
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

// RNGView with uniform styling
struct RNGView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @State private var randomNumber: Int = 0
    @State private var isGenerating: Bool = false
    @State private var minRange: String = "1"
    @State private var maxRange: String = "100"
    @State private var errorMessage: String? = nil
    @State private var selectedBackgroundColor: Color = Color.primaryBackground

    var body: some View {
        ZStack {
            selectedBackgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Random Number Generator")
                    .font(.titleFont)
                    .foregroundColor(.primaryText)
                    .padding(.top, 40)

                Text("\(randomNumber)")
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .foregroundColor(.primaryText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Set Range:")
                        .font(.headline)
                        .foregroundColor(.primaryText)

                    HStack {
                        VStack {
                            Text("Min")
                                .font(.captionFont)
                                .foregroundColor(.primaryText)
                            TextField("Min", text: $minRange)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                        }

                        VStack {
                            Text("Max")
                                .font(.captionFont)
                                .foregroundColor(.primaryText)
                            TextField("Max", text: $maxRange)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.cardBackground)
                                .cornerRadius(15)
                                .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                        }
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    generateRandomNumber()
                }) {
                    Text("Generate Random Number")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryText)
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
        .preferredColorScheme(.light)
        .onAppear {
            loadCustomBackgroundColor()
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

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
}



// QRCodeGeneratorView with uniform styling
struct QRCodeGeneratorView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @State private var qrCodeText = ""
    @State private var qrCodeImage: UIImage?
    @State private var showingAlert = false
    @State private var selectedBackgroundColor: Color = Color.primaryBackground

    var body: some View {
        VStack(spacing: 20) {
            Text("QR Code Generator")
                .font(.titleFont)
                .foregroundColor(.primaryText)
                .padding(.top, 40)
            
            VStack(spacing: 20) {
                TextField("Enter text for QR code", text: $qrCodeText)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.cardBackground)
                    .cornerRadius(10)
                
                Button(action: generateQRCode) {
                    Text("Generate QR Code")
                        .font(.bodyFont)
                        .foregroundColor(.primaryText)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(FancyButtonStyle())
                
                Button(action: exportQRCode) {
                    Text("Export QR Code")
                        .font(.bodyFont)
                        .foregroundColor(.primaryText)
                        .padding()
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
                    .foregroundColor(.secondaryText)
                    .font(.body)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .background(selectedBackgroundColor.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.light)
        .onAppear {
            loadCustomBackgroundColor()
        }
    }
    
    private func generateQRCode() {
        guard let data = qrCodeText.data(using: .utf8) else {
            qrCodeImage = nil
            return
        }
        
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(data, forKey: "inputMessage")
        
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
    
    private func exportQRCode() {
        guard let image = qrCodeImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        showingAlert = true
    }

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
}


// ContentView with uniform styling
struct ContentView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @AppStorage("counter") private var storedCounter = 0
    @State private var counter = 0
    @State private var buttonScale: CGFloat = 1.0
    @State private var selectedBackgroundColor: Color = Color.primaryBackground

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                Spacer()
                
                Text("Counter")
                    .font(.titleFont)
                    .foregroundColor(.primaryText)
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
                selectedBackgroundColor
                    .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                counter = storedCounter
                loadCustomBackgroundColor()
            }
        }
        .preferredColorScheme(.light)
    }

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
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

struct GlassBackground: View {
    var body: some View {
        VisualEffectBlur(blurStyle: .systemUltraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 10)
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}


// FlashlightView with uniform styling
struct FlashlightView: View {
    @State private var isFlashlightOn = false
    @State private var buttonScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.primaryBackground
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

// LevelView with uniform styling
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
                        .background(Color.blue)
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

// DrawingView with uniform styling
struct DrawingView: View {
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @State private var currentPath = Path()
    @State private var paths: [Path] = []
    @State private var color: Color = .black
    @State private var lineWidth: Double = 2
    @State private var selectedBackgroundColor: Color = Color.primaryBackground
    
    var body: some View {
        ZStack {
            selectedBackgroundColor
                .edgesIgnoringSafeArea(.all)
            
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
        .preferredColorScheme(.light)
        .onAppear {
            loadCustomBackgroundColor()
        }
    }

    private func loadCustomBackgroundColor() {
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
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

struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    @State private var showingAddEntry = false

    var body: some View {
        NavigationView {
            ZStack {
                // Set the custom background and ensure it covers the whole screen
                Color.primaryBackground
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 20) {
                    BudgetOverviewView(viewModel: viewModel)
                        .padding(.horizontal)

                    List {
                        ForEach(viewModel.entries) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.category)
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
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
                    .background(Color.clear) // Set the background to clear for custom background visibility
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
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .sheet(isPresented: $showingAddEntry) {
                        AddEntryView(viewModel: viewModel)
                    }
                }
                .padding(.bottom, 0) // Ensure the VStack covers the entire height
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.accentColor)
    }
}


// BudgetEntry Model and ViewModel
struct BudgetEntry: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var category: String
    var amount: Double
    var isIncome: Bool
}

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

// BudgetOverviewView
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

// AddEntryView
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

// UnitConverterView with uniform styling
struct UnitConverterView: View {
    @State private var inputValue = ""
    @State private var selectedCategoryIndex = 0
    @State private var selectedInputUnitIndex = 0
    @State private var selectedOutputUnitIndex = 1
    
    let categories = ["Length", "Weight", "Temperature"]
    let units = [
        ["Meters", "Kilometers", "Feet", "Miles"],
        ["Grams", "Kilograms", "Pounds", "Ounces"],
        ["Celsius", "Fahrenheit", "Kelvin"]
    ]
    
    var selectedCategory: String {
        categories[selectedCategoryIndex]
    }
    
    var selectedInputUnit: String {
        units[selectedCategoryIndex][selectedInputUnitIndex]
    }
    
    var selectedOutputUnit: String {
        units[selectedCategoryIndex][selectedOutputUnitIndex]
    }
    
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
            HStack {
                Button(action: {
                    selectedCategoryIndex = (selectedCategoryIndex - 1 + categories.count) % categories.count
                    resetUnitIndexes()
                }) {
                    Image(systemName: "arrow.left.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                
                Spacer()
                
                Text(selectedCategory)
                    .font(.title)
                    .bold()
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedCategoryIndex = (selectedCategoryIndex + 1) % categories.count
                    resetUnitIndexes()
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
            }
            .padding()

            TextField("Enter value", text: $inputValue)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(8)
            
            HStack {
                Button(action: {
                    selectedInputUnitIndex = (selectedInputUnitIndex - 1 + units[selectedCategoryIndex].count) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.left.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                
                Text("From: \(selectedInputUnit)")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedInputUnitIndex = (selectedInputUnitIndex + 1) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .padding()
            
            HStack {
                Button(action: {
                    selectedOutputUnitIndex = (selectedOutputUnitIndex - 1 + units[selectedCategoryIndex].count) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.left.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
                
                Text("To: \(selectedOutputUnit)")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                Button(action: {
                    selectedOutputUnitIndex = (selectedOutputUnitIndex + 1) % units[selectedCategoryIndex].count
                }) {
                    Image(systemName: "arrow.right.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .padding()
            
            Text("Converted Value: \(convertedValue, specifier: "%.2f")")
                .font(.title)
                .padding()
                .foregroundColor(.primaryText)
            
            Spacer()
        }
        .padding()
        .background(Color.primaryBackground.edgesIgnoringSafeArea(.all))
    }
    
    func resetUnitIndexes() {
        selectedInputUnitIndex = 0
        selectedOutputUnitIndex = 1
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

#Preview {
    HomeView()
}
