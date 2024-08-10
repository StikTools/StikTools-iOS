//
//  DaysUntilWidgetLiveActivity.swift
//  DaysUntilWidget
//
//  Created by Stephen Bove on 7/23/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DaysUntilWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DaysUntilWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DaysUntilWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DaysUntilWidgetAttributes {
    fileprivate static var preview: DaysUntilWidgetAttributes {
        DaysUntilWidgetAttributes(name: "World")
    }
}

extension DaysUntilWidgetAttributes.ContentState {
    fileprivate static var smiley: DaysUntilWidgetAttributes.ContentState {
        DaysUntilWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DaysUntilWidgetAttributes.ContentState {
         DaysUntilWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DaysUntilWidgetAttributes.preview) {
   DaysUntilWidgetLiveActivity()
} contentStates: {
    DaysUntilWidgetAttributes.ContentState.smiley
    DaysUntilWidgetAttributes.ContentState.starEyes
}
