//
//  Pomodoro_Screen_TimerApp.swift
//  Pomodoro Screen Timer
//
//  Created by Mia on 9/17/25.
//

import SwiftUI
import CoreData

@main
struct Pomodoro_Screen_TimerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
