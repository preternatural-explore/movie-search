//
//  MovieTextEmbeddingsIndexer.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/18/24.
//
import Foundation
import SwiftData
import OrderedCollections

/// This represents a searchable index of movies in the app.
///
/// - Indexing the movies using OpenAI's text embeddings
class MovieTextEmbeddingsIndexer {
    
    private let modelContext: ModelContext
    
    private let intelligence = AIIntelligenceManager.intelligence
    
    static let indexURL = URL.documentsDirectory.appendingPathComponent("textEmbeddingsIndex.csv")


    private var data: DataFrameIndex
    
    init(modelContainer: ModelContainer) throws {
        self.modelContext = ModelContext(modelContainer)
        
        data = try DataFrameIndex(MovieTextEmbeddingsIndexer.indexURL)
    }
    
    /// Indexes all the movies.
    ///
    /// Resets the index each time this is run.
    func indexAll() async throws {
        let movies = try modelContext.fetch(FetchDescriptor<MovieItem>())
        
        /// This assumes that the dataset is static (i.e. if the number of movies are the same, it means all movies have been added to the index).
        guard data.keys.count != movies.count else {
            return
        }
        
        // reset the data
        data = DataFrameIndex()
        
        let descriptionsByID: OrderedCollections.OrderedDictionary<UUID, String> = OrderedDictionary(
            uniqueKeysWithValues: movies.map(
                { ($0.id,
                   AIIntelligenceManager.descriptionForMovie($0))
                })
        )
        
        
        let embeddings = try await intelligence.textEmbeddings(
            for: Array(descriptionsByID.values),
            model: AIIntelligenceManager.embeddingModel
        )
        
        // TODO: @vmanot - simplify the API here
        let embeddingsWithIDs = embeddings.enumerated().map({
            (
                descriptionsByID.elements[$0.offset].key.stringValue,
                $0.element.embedding.rawValue
            )
        })
        
        data.insert(contentsOf: embeddingsWithIDs)
        
        try data.save(to: MovieTextEmbeddingsIndexer.indexURL)
    }
}
