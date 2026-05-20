//
//  SettingsView.swift
//  SimpleFitnessWatch
//
//  Created by Paul McGrath on 5/20/26.
//

import SwiftUI

struct SettingsView: View {
    @Binding var restPeriodSeconds: Int

    private let restOptions = [30, 45, 60, 90, 120, 180]

    var body: some View {
        List {
            Section("Rest Period") {
                Picker("Duration", selection: $restPeriodSeconds) {
                    ForEach(restOptions, id: \.self) { seconds in
                        Text(formatRestOption(seconds)).tag(seconds)
                    }
                }
            }
        }
    }

    private func formatRestOption(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds % 60 == 0 {
            return "\(seconds / 60)m"
        } else {
            return "\(seconds / 60)m \(seconds % 60)s"
        }
    }
}


#Preview {
    @Previewable @State var restPeriodSeconds = 60
    SettingsView(restPeriodSeconds: $restPeriodSeconds)
}
