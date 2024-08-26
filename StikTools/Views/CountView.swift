//
//  CountView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

struct CountView: View {
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
                    .background(.white.opacity(0.2))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                
                Text("\(counter)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(gradient: Gradient(colors: [.white, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .background(.white.opacity(0.2))
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
