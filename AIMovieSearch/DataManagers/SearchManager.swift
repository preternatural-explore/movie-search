//
//  SearchManager.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/18/24.
//

import Foundation
import LargeLanguageModels
import SwiftData

/// - Searching the movies given a search query (also using embeddings)
class SearchManager: Logging  {

    private var data: DataFrameIndex
    
    let logger = PassthroughLogger()
    
    private let intelligence = AIIntelligenceManager.intelligence
    
    private let modelContext: ModelContext
    
    private let indexURL = MovieTextEmbeddingsIndexer.indexURL
    
    init(modelContainer: ModelContainer) throws {
        modelContext = ModelContext(modelContainer)
        
        data = try DataFrameIndex(indexURL)
        logger.info("Text Embeddings Index File Location: \(indexURL.absoluteString)")
    }
    
    struct SearchResult: Identifiable {
        let id: Int
        let movie: MovieItem
        let score: Double
    }
    
    func search(_ text: String, maximumNumberOfResults: Int = 100) async throws -> [SearchResult] {
        let text = try await modifySearchQuery(text)
        
        logger.info("Searching with final query: \(text)")
        
        // TODO: @vmanot improve API
        let searchEmbedding: [Double] = try await intelligence.textEmbedding(
            for: text,
            model: AIIntelligenceManager.embeddingModel
        ).rawValue
        
        let embeddingSearchResults: [DataFrameIndex.SearchResult] = data.query(
            searchEmbedding,
            topK: maximumNumberOfResults
        )
        
        logger.info("Finished with \(embeddingSearchResults.count) result(s).")

        return try embeddingSearchResults.enumerated().map { (offset: Int, result: DataFrameIndex.SearchResult) in
            let id = UUID(uuidString: result.id)!
            let fetchDescriptor = FetchDescriptor(predicate: #Predicate<MovieItem> { movie in
                movie.id == id
            })

            let movieItem: MovieItem = try  modelContext.fetch(fetchDescriptor).first!
            
            return SearchResult(
                id: offset,
                movie: movieItem,
                score: result.score
            )
        }
    }
    
    private func modifySearchQuery(_ text: String) async throws -> String {
        let messages: [AbstractLLM.ChatMessage] = AIIntelligenceManager.messagesForText(text)
        
        let completion = try await intelligence.complete(
            prompt: AbstractLLM.ChatPrompt(messages: messages),
            model: AIIntelligenceManager.chatModel
        )
        let modifiedQuery = try String(completion.message.content)
        
        logger.info("Modified query:\n\"\(modifiedQuery)\"")
        
        return modifiedQuery
    }
}
