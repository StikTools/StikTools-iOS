//
//  RNGView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

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
