//
//  OpenAIManager.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/12/24.
//

import OpenAI
import LargeLanguageModels

struct AIIntelligenceManager {
    
    static let client = OpenAI.Client(apiKey: "YOUR_API_KEY")
    static let intelligence: any LLMRequestHandling & TextEmbeddingsRequestHandling = AIIntelligenceManager.client
    static let embeddingModel = OpenAI.Model.embedding(.text_embedding_3_small)
    static let chatModel = OpenAI.Model.chat(.gpt_3_5_turbo)
    
    static func descriptionForMovie(_ movie: MovieItem) -> String {
        return
            """
            Movie Title: \(movie.title)
            Movie Genre: \(movie.genre)
            Movie Release Year: \(movie.releaseYear?.toString(dateFormat: "yyyy") ?? "release year not available")
            Movie Director: \(movie.director)
            Movie Rating: \(movie.adjustedRating ?? 0))
            
            Movie Plot (from Wikipedia or IMBD):
            \(movie.plotWikiLong ?? movie.plotIMBDShort)
            """
    }
    
    static func messagesForText(_ text: String) -> [AbstractLLM.ChatMessage] {
        /// This is an example of few-shot prompting (i.e. using example task inputs+outputs).
        ///
        /// We do this so that GPT knows that it is only supposed to answer with the string and nothing more. If we don't add the examples, it'll add random text like "Sure! I can help you with that" 🤮
        ///
        /// https://docs.anthropic.com/claude/docs/use-examples
        [
            AbstractLLM.ChatMessage.system {
                """
                You are MovieSearchGPT.
                
                The user will give you a search query. It can be a word, a sentence, or a paragraph.
                Your job is to shorten it down to the length and format of a Google search.
                Add keywords to the original search query as appropriate.
                
                Remember, you must ONLY return the modified search query. NOTHING more.
                """
            },
            AbstractLLM.ChatMessage.user {
                """
                sci-fi
                """
            },
            AbstractLLM.ChatMessage.assistant {
                """
                A science fiction (sci-fi) movie or film.
                """
            },
            AbstractLLM.ChatMessage.user {
                """
                A film where two people get really sad after falling in love and then breaking up.
                """
            },
            AbstractLLM.ChatMessage.assistant {
                """
                A movie where the plot is a romantic drama that ends in tragedy.
                """
            },
            AbstractLLM.ChatMessage.user {
                """
                \(text)
                """
            }
        ]
    }
}


