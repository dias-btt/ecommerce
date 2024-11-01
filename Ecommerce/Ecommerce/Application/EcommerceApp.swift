//
//  EcommerceApp.swift
//  Ecommerce
//
//  Created by Диас Сайынов on 01.11.2024.
//

import SwiftUI

@main
struct EcommerceApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
