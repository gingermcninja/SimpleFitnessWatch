//
//  TimerScreenViewModel.swift
//  SimpleFitnessWatch
//
//  Created by Paul McGrath on 5/20/26.
//

import Foundation
import Combine
import WatchKit

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
    private var timer: Timer?
    private var restTimer: Timer?

    init(restPeriodSeconds: Int) {
        self.restPeriodSeconds = restPeriodSeconds
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
    
    func startTimer(mode: TimerMode) {
        timerMode = mode
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
            guard let mode = self?.timerMode, let restTime = self?.elapsedRestSeconds, let restPeriod = self?.restPeriodSeconds else { return }
            if mode == .resting {
                self?.elapsedRestSeconds += 1
                if restTime >= restPeriod {
                    self?.stopRestTimer()
                }
            }
        }
    }

    func pauseTimer() {
        timerMode = timerMode == .resting ? .pausedResting : .paused
        timer?.invalidate()
        timer = nil
    }

    func stopTimer() {
        timerMode = .stopped
        timer?.invalidate()
        timer = nil
        elapsedSeconds = 0
    }
    
    func startRestTimer() {
        previousMode = timerMode
        timerMode = .resting
        /*
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedRestSeconds += 1
            guard let restTime = self?.elapsedRestSeconds, let restPeriod = self?.restPeriodSeconds else { return }
            if restTime >= restPeriod {
                self?.stopRestTimer()
            }
        }
         */
    }
    
    func stopRestTimer() {
        timerMode = previousMode ?? .running
        previousMode = nil
        //restTimer?.invalidate()
        //restTimer = nil
        elapsedRestSeconds = 0
        WKInterfaceDevice.current().play(.start)
    }
}
