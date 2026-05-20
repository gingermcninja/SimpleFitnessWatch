//
//  TimerScreenViewModel.swift
//  SimpleFitnessWatch
//
//  Created by Paul McGrath on 5/20/26.
//

import Foundation
import Observation

enum TimerMode {
    case stopped
    case running
    case paused
    case resting
}

@Observable
class TimerScreenViewModel {
    var restPeriodSeconds: Int = 60
    var elapsedSeconds: Int = 0
    var timerMode: TimerMode = .stopped
    private var timer: Timer?
    
    
    init(restPeriodSeconds: Int) {
        self.restPeriodSeconds = restPeriodSeconds
    }

    func startTimer(mode: TimerMode) {
        timerMode = mode
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.elapsedSeconds += 1
        }
    }

    func pauseTimer() {
        timerMode = .paused
        timer?.invalidate()
        timer = nil
    }

    func stopTimer() {
        timerMode = .stopped
        timer?.invalidate()
        timer = nil
        elapsedSeconds = 0
    }
}
