//
//  TimerView.swift
//  SimpleFitnessWatch
//
//  Created by Paul McGrath on 5/20/26.
//

import SwiftUI

struct TimerScreenView: View {
    @State var viewModel: TimerScreenViewModel

    var body: some View {
        VStack(spacing: 8) {
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
        case .resting: "Rest"
        }
    }

    private var modeLabelColor: Color {
        switch viewModel.timerMode {
        case .stopped: .secondary
        case .running: .green
        case .paused: .yellow
        case .resting: .blue
        }
    }

    private var timerDisplay: some View {
        Text(formattedTime)
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .foregroundStyle(viewModel.timerMode == .resting ? .blue : .primary)
    }

    private var formattedTime: String {
        let minutes = viewModel.elapsedSeconds / 60
        let seconds = viewModel.elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private var buttonGrid: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                TimerButton(
                    title: "Start",
                    systemImage: "play.fill",
                    tint: .green
                ) {
                    viewModel.startTimer(mode: .running)
                }
                .disabled(viewModel.timerMode == .running)

                TimerButton(
                    title: "Pause",
                    systemImage: "pause.fill",
                    tint: .yellow
                ) {
                    viewModel.pauseTimer()
                }
                .disabled(viewModel.timerMode == .paused || viewModel.timerMode == .stopped)
            }

            HStack(spacing: 6) {
                TimerButton(
                    title: "Stop",
                    systemImage: "stop.fill",
                    tint: .red
                ) {
                    viewModel.stopTimer()
                }
                .disabled(viewModel.timerMode == .stopped)

                TimerButton(
                    title: "Rest",
                    systemImage: "bed.double.fill",
                    tint: .blue
                ) {
                    viewModel.startTimer(mode: .resting)
                }
                .disabled(viewModel.timerMode == .resting || viewModel.timerMode == .stopped)
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
            .frame(maxWidth: .infinity, minHeight: 44)
        }
        .tint(tint)
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    TimerScreenView(viewModel: TimerScreenViewModel(restPeriodSeconds: 60))
}

