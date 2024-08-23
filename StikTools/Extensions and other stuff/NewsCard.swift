//
//  NewsCard.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

struct NewsCard: View {
    let newsItem: NewsItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(newsItem.title)
                .font(.headline)
                .foregroundColor(.primaryText)
            Text(newsItem.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .shadow(radius: 2)
        .frame(width: 250) // Adjust width as needed
    }
}
