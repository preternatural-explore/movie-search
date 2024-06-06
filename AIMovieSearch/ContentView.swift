//
//  ContentView.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/12/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @StateObject var searchModel: MovieSearchModel
    
    var body: some View {
        NavigationStack {
            MovieItemsView()
                .navigationTitle("Movies")
#if os(iOS)
                .toolbarBackground(AppColors.navigationBarColor, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
#elseif os(macOS)
                .toolbarBackground(AppColors.navigationBarColorMac)
                .toolbarColorScheme(.dark)
                .toolbarBackground(.visible)
                .navigationSubtitle(searchModel.state == .searching ? "Searching..." :  "")
#endif
                .searchable(text: $searchModel.searchText, prompt: "Search")
                .onSubmit(of: .search) {
                    Task { @MainActor in
                        await searchModel.search()
                    }
                }
                .overlay {
                    if let searchResults = searchModel.searchResults {
                        MovieSearchResultsView(searchResults: searchResults )
                    }
                }
        }
        
    }
}
