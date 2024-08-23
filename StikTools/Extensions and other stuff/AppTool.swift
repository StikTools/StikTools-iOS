//
//  AppTool.swift
//  StikTools
//
//  Created by Stephen Bove on 8/23/24.
//

import SwiftUI

struct AppTool: Identifiable, Equatable {
    var id = UUID()
    var imageName: String
    var title: String
    var color: Color
    var destination: AnyView

    static func == (lhs: AppTool, rhs: AppTool) -> Bool {
        return lhs.id == rhs.id
    }
}
