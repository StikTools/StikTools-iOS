//
//  CounterButton.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

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
                        .fill(.white.opacity(0.2))
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
