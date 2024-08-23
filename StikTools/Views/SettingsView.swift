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
