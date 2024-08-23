//
//  FancyButtonStyle.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

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
