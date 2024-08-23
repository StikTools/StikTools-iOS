//
//  FancyCard.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

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
