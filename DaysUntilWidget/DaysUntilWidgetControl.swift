//
//  DaysUntilWidgetControl.swift
//  DaysUntilWidget
//
//  Created by Stephen Bove on 7/23/24.
//

import AppIntents
import SwiftUI
import WidgetKit

struct DaysUntilWidgetControl: ControlWidget {
    static let kind: String = "com.stik.StikTools.DaysUntilWidget"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent(),
                valueLabel: { isRunning in
                    Label(isRunning ? "On" : "Off", systemImage: "timer")
                }
            )
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension DaysUntilWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static var title: LocalizedStringResource { "Start a timer" }

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}
