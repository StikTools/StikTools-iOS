//
//  NewsItem.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import Foundation

struct NewsItem: Identifiable, Decodable {
    let id: String
    let title: String
    let subtitle: String
}
