//
//  ContentView.swift
//  SimpleFitnessWatch Watch App
//
//  Created by Paul McGrath on 5/20/26.
//

import SwiftUI



struct ContentView: View {
    @State private var selectedTab = 0
    @State private var restPeriodSeconds: Int = 60

    var body: some View {
        TabView(selection: $selectedTab) {
            let timerScreenViewModel: TimerScreenViewModel = TimerScreenViewModel(restPeriodSeconds: restPeriodSeconds)
            TimerScreenView(viewModel: timerScreenViewModel)
                .tag(0)
            SettingsView(restPeriodSeconds: $restPeriodSeconds)
                .tag(1)
        }
        .tabViewStyle(.verticalPage)
    }
}

#Preview {
    ContentView()
}
