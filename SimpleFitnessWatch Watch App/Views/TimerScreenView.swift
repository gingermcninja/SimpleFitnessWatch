//
//  TimerView.swift
//  SimpleFitnessWatch
//
//  Created by Paul McGrath on 5/20/26.
//

import SwiftUI

struct TimerScreenView: View {
    @ObservedObject var viewModel: TimerScreenViewModel

    var body: some View {
        VStack(spacing: 4) {
            timerModeLabel
            timerDisplay
            buttonGrid
        }
        .padding(.horizontal)
    }

    private var timerModeLabel: some View {
        Text(modeLabelText)
            .font(.caption)
            .foregroundStyle(modeLabelColor)
            .textCase(.uppercase)
    }

    private var modeLabelText: String {
        switch viewModel.timerMode {
        case .stopped: "Ready"
        case .running: "Workout"
        case .paused: "Paused"
        case .pausedResting: "Paused"
        case .resting: "Rest"
        }
    }

    private var modeLabelColor: Color {
        switch viewModel.timerMode {
        case .stopped: .secondary
        case .running: .green
        case .paused: .yellow
        case .pausedResting: .yellow
        case .resting: .blue
        }
    }

    private var timerDisplay: some View {
        VStack(spacing: 0) {
            Text(viewModel.formattedTime)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .foregroundStyle(viewModel.timerMode == .resting ? .blue : .primary)
            if viewModel.timerMode == .resting || viewModel.timerMode == .pausedResting {
                Text(viewModel.formattedRestTime)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(viewModel.timerMode == .resting ? .blue : .primary)
            }
        }
    }



    private var buttonGrid: some View {
        VStack(spacing: 4) {
            if viewModel.timerMode == .stopped {
                TimerButton(
                    title: "Start",
                    systemImage: "play.fill",
                    tint: .green
                ) {
                    viewModel.startTimer(mode: .running)
                }
            } else {
                HStack(spacing: 4) {
                    if viewModel.timerMode == .running || viewModel.timerMode == .resting {
                        TimerButton(
                            title: "Pause",
                            systemImage: "pause.fill",
                            tint: .yellow
                        ) {
                            viewModel.pauseTimer()
                        }
                    } else {
                        TimerButton(
                            title: "Resume",
                            systemImage: "play.fill",
                            tint: .green
                        ) {
                            let newMode: TimerMode = (viewModel.timerMode == .pausedResting) ? .resting : .running
                            viewModel.startTimer(mode: newMode)
                        }
                    }

                    TimerButton(
                        title: "Rest",
                        systemImage: "bed.double.fill",
                        tint: .blue
                    ) {
                        viewModel.startRestTimer()
                    }
                    .disabled(viewModel.timerMode == .resting || viewModel.timerMode == .pausedResting)
                }

                TimerButton(
                    title: "Stop",
                    systemImage: "stop.fill",
                    tint: .red
                ) {
                    viewModel.stopTimer()
                }
            }
        }
    }
}

struct TimerButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemImage)
                    .font(.body)
                Text(title)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, minHeight: 36)
        }
        .tint(tint)
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    TimerScreenView(viewModel: TimerScreenViewModel(restPeriodSeconds: 60))
}

