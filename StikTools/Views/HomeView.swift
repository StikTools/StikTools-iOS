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
        AppTool(imageName: "plus.square", title: "Counter", color: Color.green.opacity(0.2), destination: AnyView(CountView())),
        AppTool(imageName: "ruler", title: "Unit Converter (Beta)", color: Color.green.opacity(0.2), destination: AnyView(UnitConverterView())),
        AppTool(imageName: "flashlight.off.circle", title: "Flashlight", color: Color.green.opacity(0.2), destination: AnyView(FlashlightView())),
    ]
    @State private var searchText: String = ""
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
        .onReceive(timer) { _ in
            refreshBackground()
        }
    }

    // Function to open Discord link
    func joinDiscord() {
        if let url = URL(string: "https://discord.gg/a6qxs97Gun") {
            UIApplication.shared.open(url)
        }
    }

    private func refreshBackground() {
        // This function can be customized to change the background color based on time or other criteria
        selectedBackgroundColor = Color(hex: customBackgroundColorHex) ?? Color.primaryBackground
    }
}
