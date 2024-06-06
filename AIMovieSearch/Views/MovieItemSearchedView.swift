//
//  MovieItemSearchedView.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/18/24.
//

import SwiftUI

struct MovieItemSearchedView: View {
    let movie: MovieItem
    let score: Double?
    
    var body: some View {
        VStack {
            MovieItemView(movie: movie)
            if let score {
                Text("Relavance: \(score.formatted(toDecimalPlaces: 2))")
                    .font(.body.weight(.medium).monospaced())
                    .foregroundColor(.secondary)
                    .padding(.top, .extraSmall)
            }
        }
    }
}
