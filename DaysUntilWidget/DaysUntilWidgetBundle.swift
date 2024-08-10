//
//  DaysUntilWidgetBundle.swift
//  DaysUntilWidget
//
//  Created by Stephen Bove on 7/23/24.
//

import WidgetKit
import SwiftUI

@main
struct DaysUntilWidgetBundle: WidgetBundle {
    var body: some Widget {
        DaysUntilWidget()
        DaysUntilWidgetControl()
        DaysUntilWidgetLiveActivity()
    }
}
