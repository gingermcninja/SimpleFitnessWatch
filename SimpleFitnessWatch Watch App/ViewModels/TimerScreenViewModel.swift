//
//  TimerScreenViewModel.swift
//  SimpleFitnessWatch
//
//  Created by Paul McGrath on 5/20/26.
//

import Foundation
import Combine
import WatchKit
import HealthKit

enum TimerMode: Equatable {
    case stopped
    case running
    case paused
    case pausedResting
    case resting
}

class TimerScreenViewModel: ObservableObject {
    @Published var restPeriodSeconds: Int = 60
    @Published var elapsedSeconds: Int = 0
    @Published var elapsedRestSeconds: Int = 0
    @Published var timerMode: TimerMode = .stopped
    @Published var previousMode: TimerMode?

    private var startRestSeconds: Int?
    private var displayTimer: Timer?
    private var timerStartDate: Date?
    private var accumulatedSeconds: TimeInterval = 0
    private var accumulatedRestSeconds: TimeInterval = 0

    let workoutManager = WorkoutManager()

    init(restPeriodSeconds: Int) {
        self.restPeriodSeconds = restPeriodSeconds
        workoutManager.requestAuthorization()
    }

    var formattedTime: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var formattedRestTime: String {
        let minutes = elapsedRestSeconds / 60
        let seconds = elapsedRestSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func updateElapsedTime() {
        let now = Date()
        if let startDate = timerStartDate {
            elapsedSeconds = Int(accumulatedSeconds + now.timeIntervalSince(startDate))
        }
        if let restSeconds = startRestSeconds {
            let totalRest = elapsedSeconds - restSeconds
            elapsedRestSeconds = totalRest
            if totalRest >= restPeriodSeconds {
                stopRestTimer()
            }
        }
    }

    private func startDisplayTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }

    func startTimer(mode: TimerMode) {
        let wasStoppedOrFirstStart = timerMode == .stopped
        let wasPaused = timerMode == .paused || timerMode == .pausedResting
        timerMode = mode

        if wasStoppedOrFirstStart {
            accumulatedSeconds = 0
            timerStartDate = Date()
            workoutManager.startWorkout()
        } else if wasPaused {
            timerStartDate = Date()
            workoutManager.resumeWorkout()
        }

        startDisplayTimer()
        updateElapsedTime()
    }

    func pauseTimer() {
        timerMode = timerMode == .resting ? .pausedResting : .paused

        if let startDate = timerStartDate {
            accumulatedSeconds += Date().timeIntervalSince(startDate)
            timerStartDate = nil
        }

        displayTimer?.invalidate()
        displayTimer = nil
        workoutManager.pauseWorkout()
    }

    func stopTimer() {
        timerMode = .stopped
        displayTimer?.invalidate()
        displayTimer = nil
        timerStartDate = nil
        accumulatedSeconds = 0
        accumulatedRestSeconds = 0
        elapsedSeconds = 0
        elapsedRestSeconds = 0
        workoutManager.stopWorkout()
    }

    func startRestTimer() {
        startRestSeconds = elapsedSeconds
        previousMode = timerMode
        timerMode = .resting
        accumulatedRestSeconds = 0
    }

    func stopRestTimer() {
        timerMode = previousMode ?? .running
        startRestSeconds = nil
        previousMode = nil
        accumulatedRestSeconds = 0
        elapsedRestSeconds = 0
        WKInterfaceDevice.current().play(.start)
    }
}
