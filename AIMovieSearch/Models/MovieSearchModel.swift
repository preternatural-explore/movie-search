//
//  MovieSearchModel.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/18/24.
//

import SwiftData
import LargeLanguageModels

@MainActor
class MovieSearchModel: ObservableObject {
    enum State: Equatable {
        case readyToSearch
        case searching
        case failedToSearch(AnyError)
        case searchFinished
    }
    
    let searchManager: SearchManager
    
    @Published var state: State = .readyToSearch
    @Published var searchText: String = ""
    @Published var searchResults: [SearchManager.SearchResult]?
    
    init(modelContainer: ModelContainer) {
        self.searchManager = try! SearchManager(modelContainer: modelContainer)
    }
    
    func search() async {
        guard !searchText.isEmpty else {
            preconditionFailure("Search text cannot be empty!")
        }
        
        do {
            state = .searching
            searchResults = try await searchManager.search(searchText)
            state = .searchFinished
        } catch {
            state = .failedToSearch(AnyError(erasing: error))
        }
    }
}
