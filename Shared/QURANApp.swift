//
//  QURANApp.swift
//  Shared
//
//  Created by standard on 9/23/22.
//

import SwiftUI

@main
struct QURANApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
