//
//  DrawingView.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

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
