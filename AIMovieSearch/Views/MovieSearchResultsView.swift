//
//  MovieSearchResultsView.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/18/24.
//

import SwiftUI

struct MovieSearchResultsView: View {
    var searchResults: [SearchManager.SearchResult]

    var body: some View {
        ScrollView {
            LazyVGrid(alignment: .leading, minWidth: 300) {
                ForEach(searchResults) { item in
                    MovieItemSearchedView(movie: item.movie, score: item.score)
                }
            }
        }
        .background(AppColors.backgroundColor)
    }
}
