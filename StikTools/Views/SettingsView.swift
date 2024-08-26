//
//  SettingsView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("username") private var username = "User"
    @AppStorage("customBackgroundColor") private var customBackgroundColorHex: String = Color.primaryBackground.toHex() ?? "#008080" // default teal color
    @AppStorage("selectedAppIcon") private var selectedAppIcon: String = "AppIcon" // default app icon

    @State private var selectedBackgroundColor: Color = Color.primaryBackground
    @State private var showIconPopover = false

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
                    
                    Button(action: {
                        showIconPopover.toggle()
                    }) {
                        HStack {
                            Text("App Icon")
                                .foregroundColor(.primaryText)
                            Spacer()
                            Text(selectedAppIcon == "AppIcon" ? "Default" : selectedAppIcon)
                                .foregroundColor(.secondaryText)
                        }
                    }
                    .popover(isPresented: $showIconPopover) {
                        VStack(spacing: 15) {
                            Text("Select App Icon")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.top)
                                .shadow(radius: 1)

                            Divider()
                                .padding(.horizontal)

                            iconButton("Default", icon: "AppIcon")
                            iconButton("Yellow", icon: "YellowIcon")
                            iconButton("Green", icon: "GreenIcon")
                            iconButton("Blue", icon: "BlueIcon")
                            iconButton("Teal", icon: "TealIcon")
                            iconButton("Black", icon: "BlackIcon")
                            iconButton("White", icon: "WhiteIcon")

                            Spacer()

                            Button(action: {
                                showIconPopover = false
                            }) {
                                Text("Close")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(selectedBackgroundColor)
                        .cornerRadius(20)
                        .shadow(radius: 5)
                    }
                    .listRowBackground(Color.cardBackground)
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

    // Change the app icon
    private func changeAppIcon(to iconName: String) {
        selectedAppIcon = iconName
        UIApplication.shared.setAlternateIconName(iconName == "AppIcon" ? nil : iconName) { error in
            if let error = error {
                print("Error changing app icon: \(error.localizedDescription)")
            }
        }
    }

    // Helper function to create icon buttons
    private func iconButton(_ label: String, icon: String) -> some View {
        Button(action: {
            changeAppIcon(to: icon)
            showIconPopover = false
        }) {
            HStack {
                Image(systemName: icon == "AppIcon" ? "app.fill" : "circle.fill")
                    .foregroundColor(.accentColor)
                Text(label)
                    .foregroundColor(.primaryText)
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}
