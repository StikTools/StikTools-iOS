//
//  ContentView.swift
//  StikTools
//
//  Created by Blu on 7/12/24.
//

import SwiftUI
import Combine

struct HomeView: View {
    @AppStorage("username") private var username = "User"
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080"
    @AppStorage("hasAcceptedPrivacyPolicy") private var hasAcceptedPrivacyPolicy: Bool = false

    @State private var selectedBackgroundColor: Color = Color(hex: UserDefaults.standard.string(forKey: "customBackgroundColor") ?? "#008080") ?? Color.primaryBackground

    @State private var tools: [AppTool] = [
        AppTool(imageName: "number.circle", title: "RNG", color: Color.red.opacity(0.2), destination: AnyView(RNGView())),
        AppTool(imageName: "qrcode", title: "QRCode", color: Color.orange.opacity(0.2), destination: AnyView(QRCodeGeneratorView())),
        AppTool(imageName: "level", title: "Level Tool", color: Color.yellow.opacity(0.2), destination: AnyView(LevelView())),
        AppTool(imageName: "pencil.circle.fill", title: "Whiteboard", color: Color.blue.opacity(0.2), destination: AnyView(DrawingView())),
        AppTool(imageName: "plus.square", title: "Counter", color: Color.green.opacity(0.2), destination: AnyView(CountView()))
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
                                    HStack(spacing: 10) { // Reduced spacing from 15 to 10
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
            #if targetEnvironment(simulator)
            loadLocalNews() // Load local news for simulator
            #else
            loadNews() // Load news from the server on a real device
            #endif
            
            // Show privacy policy alert if not accepted
            if (!hasAcceptedPrivacyPolicy) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showPrivacyPolicyAlert = true
                }
            }
        }
        .onReceive(timer) { _ in
            refreshBackground()
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
        guard let url = URL(string: "https://stiktools.xyz/news-2.json") else { return }
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

    private func refreshBackground() {
        // This function can be customized to change the background color based on time or other criteria
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
}
