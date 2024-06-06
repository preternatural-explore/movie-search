//
//  AIMovieSearchApp.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/12/24.
//

import SwiftUI
import SwiftData

@main
struct AIMovieSearchApp: App {
    
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MovieItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        let modelContainer = self.sharedModelContainer
        
        Task.detached(priority: .high) {
            await Self.load(container: modelContainer)
        }
    }
    
    static func load(container: ModelContainer) async {
        await CSVDataManager(modelContainer: container).parseCSV()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(searchModel: MovieSearchModel(modelContainer: sharedModelContainer))
        }
        .modelContainer(sharedModelContainer)
    }
}
