# AI-Powered Movie Search App

## Running the App
To run the AI Movie Search app: 

1. Download and open the project
2. Open `AIIntelligenceManager` file in the `DataManagers` folder and add your OpenAI API key:  

```swift
// DataManagers/AIIntelligenceManager
static let client = OpenAI.Client(apiKey: "YOUR_API_KEY")
```

*You can get the OpenAI API key on the [OpenAI developer website](https://platform.openai.com/). Note that you have to set up billing and add a small amount of money for the API calls to work (this will cost you less than 1 dollar).* 

3. Run the project on the Mac, iPad, or iPhone
4. Search for movies using natural language. For example: 

The app returns the following results for “romantic movie in new york”:

![file (1)](https://github.com/preternatural-explore/AIMovieSearch/assets/1157147/c0149695-3282-40a2-b117-43febd938c78)

Other searches to try out: 

- “Classic western films"
- "Best adventure movies"
- "Movies directed by Alfred Hitchcock"
- "French romantic comedies"
- "Movies about time travel"
- "Action movies set in the future"

## Table of Contents
- [Key Concepts](#key-concepts)
- [Why Use AI for Search?](#why-use-ai-for-search)
- [The AI Movie Search App Example](#the-ai-movie-search-app-example)
- [AI Concepts to Understand](#ai-concepts-to-understand)
  - [Text Embeddings](#text-embeddings)
  - [Retrieval-Augmented Generation (RAG)](#retrieval-augmented-generation-rag)
- [AI Movie Search Implementation](#ai-movie-search-implementation)
  - [1. Preparing the Data](#1-preparing-the-data)
  - [2. Converting the Data to Text Embeddings](#2-converting-the-data-to-text-embeddings)
  - [3. Converting the Search Query to an Embedding](#3-converting-the-search-query-to-an-embedding)
    - [3a. Use an LLM to Modify the Search Query](#3a-use-an-llm-to-modify-the-search-query)
    - [3b: Now Convert the Modified Search Query into a Text Embedding](#3b-now-convert-the-modified-search-query-into-a-text-embedding)
  - [4. Using Vector Search](#4-using-vector-search)
- [Conclusion](#conclusion)
- [FAQ](#faq)
  - [How to work with larger datasets?](#how-to-work-with-larger-datasets)
  - [How to get text embeddings for larger texts?](#how-to-get-text-embeddings-for-larger-texts)

## Key Concepts

The AI Movie Search app is developed to demonstrate the the following key concepts:

- How to work with the OpenAI API using the AI framework
- How to Structure Training Data to Experiment With
- How to work with Text Embeddings
- Retrieval-Augmented Generation (RAG)
- How to Implement Advanced Generalized Search (e.g. 'romantic movies in New York City')

## Why Use AI for Search?
In traditional software development, search is very limited. Customers are expected to search for exact or partially matching expressions that match database column values. Companies with higher budgets can take the time to add certain shortcuts that customers have to discover or learn about if they’re ambitious to make search easier. For example, in Gmail Search I can specify “from:[EMAIL_ADDRESS]” and get more accurate results. There is even Advanced Search where I can be a lot more specific:

<img width="712" alt="Screenshot 2024-06-06 at 10 16 02 AM" src="https://github.com/preternatural-explore/AIMovieSearch/assets/1157147/9cdb96de-c9e7-4954-9fec-7600c8804afc"><br />

However, this search methodology doesn’t work in the way we, as humans, think when searching. Sometimes we want to search for “that email about what everyone is supposed to bring to the family reunion party” or “the email from my accountant with my 2022 tax return”.  By integrating AI into the search process, we can create a search experience that is natural language based, allowing for a much more effortless search experience. 

## The AI Movie Search App Example

We will use the example of a Movie Plots App (similar to IMBD) to illustrate how to integrate AI-powered search into any application. This app helps customers decide which movie they want to watch. Instead of entering movie titles directly, customers search freely for:

- “sci-fi movies about aliens”
- “movies by Woody Allen”
- “cartoons about cars”
- "thriller movies set in London"
- "comedy films from the 90s"
- "Oscar-winning movies"
- "films starring Meryl Streep"
- "animated films about animals"
- “Bollywood movies with great fight scenes”
- "horror movies set in haunted houses"
- "dramas tackling social issues"
- "musicals with dance numbers"
- and much more!

Run the app and experiment with some of the above search queries to see the results!

## AI Concepts to Understand

Before going into the implementation details for the Movie Search app, there are two concepts which are important to understand:

### Text Embeddings

Text embedding models are translators for machines. They convert text, such as sentences or paragraphs, into sets of numbers, which the machine can easily use in complex calculations. Letters that appear close together extremely often are called tokens and are assigned a number. A full phrase is converted into an array of numbers which correspond to tokens. 

It’s easier to visualize the concept on websites such as [Tiktokenizer](https://tiktokenizer.vercel.app/). Here, you can see the full text converted into tokens (each of different color) which is then converted into an array of numbers representing each token:

<img width="1920" alt="Untitled" src="https://github.com/preternatural-explore/AIMovieSearch/assets/1157147/31285c05-e471-4d63-aa59-9a818fafacf3"><br />

The reason that Large Language Models (LLMs) are so powerful is because they do calculations based on arrays of numbers (in vector space) versus using language, which the computer is not good at. Text is turned into tokens, which map to numbers in an array (a vector). The computer then does calculations on the vectors. 

<img width="986" alt="Screenshot 2024-06-06 at 3 08 34 PM" src="https://github.com/preternatural-explore/AIMovieSearch/assets/1157147/d3689517-0b10-4f7d-893f-98bd2e32e73c"><br />

The calculations are based on probabilities of the next most likely tokens based on their appearance in the training data. Once the calculations are done, the LLM outputs an array of numbers (a vector), which then gets converted into corresponding tokens, creating human-readable text. 

### Retrieval-Augmented Generation (RAG)

If you try to research about RAGs, you’ll undoubtedly come across many complicated and confusing scientific papers, blog posts, discussions, etc. However, at its core, Retrieval-Augmented Generation (RAG) is simply an overarching concept with a variety of implementation techniques for connecting a Large Language Model (LLM) to an external data source. 

As the name *Retrieval-Augmented Generation* helpfully suggests, it has two major components: 

1. *Retrieval*: Retrieve the relevant data from the external data source and provide to the LLM along with the user query. 
2. *Generation*: The LLM will generate a response to the user query using the provided relevant data. 

Let’s take the example of a car selling app. The user may ask “Are there any blue cars available?”. The LLM has no access to the actual cars available at nearby dealerships, so we have to *augment* its knowledge by *retrieving* the list of cars available near the user’s location with information about each car (make, model, year, price, color, etc). We then send the user query and the list of available cars with information about each car to the LLM, and it will *generate* a response based on the external car availability data. 

This RAG pipeline can be conceptually broken down into the following steps: 

1) There is a question or query, as an input. e.g. “Are there any blue cars available?”

2) Based on this input, we search through our datasource to *retrieve* the most relevant piece(s) of information. e.g. Cars available near the user’s location with information about each car (make, model, year, price, color, etc)

3) We pass the query and the retrieved information to the LLM. To make things simple, we can imagine this is a prompt to the LLM. e.g. “Using the provided car availability data [provided data] only, answer the following question: ‘Are there any blue cars available?’ If the information is not in the car data, answer with ‘sorry, we do not have this information’”

4) The language model will *generate* an answer to the question. e.g. “Yes - there are 3 blue cars available”

The AI Movie Search app uses the RAG strategy. The app itself has a database (in the form a csv) of movie information, which the LLM will be using as the external source of data to search through. The exact implementation is slightly different than the simplified version above, the details of which are in the implementation section below. 

## AI Movie Search Implementation

### 1. Preparing the Data

The most important and tedious step in working with LLMs is ensuring that you have a good clean data source. The “garbage in, garbage out” rule highly applies here. This includes cleaning and structuring the data effectively. 

For instance, if you have encoded terms in your database, these need to be decoded for the LLM to yield accurate responses. Consider a car-selling app where car types are encoded in your dataset (e.g., 0 = Toyota, 1 = Honda, 2 = Tesla, etc.). If you feed car information to the LLM in this encoded format, it won't understand that 0 represents Toyota. Therefore, if a user asks "are there any Toyotas available," the LLM will not provide an accurate response. In general, it is important to format your data to fit the language of how the customer will query it in natural language. 

The data for the AI Movie Search app was taken from [Kaggle.com](https://www.kaggle.com/), a website that contains a big variety of datasets that can be used for experimentation. Specifically, the [IMDB Movies Dataset](https://www.kaggle.com/datasets/harshitshankhdhar/imdb-dataset-of-top-1000-movies-and-tv-shows), which contains the top 1000 movies and tv shows with posters, was combined with the [Wikipedia Movie Plots Dataset](https://www.kaggle.com/datasets/jrobischon/wikipedia-movie-plots), which contains the Plot descriptions for ~35,000 movies. 

Since the goal was to build a beautiful app, the priority was given to the IMDB dataset for the movie posters. And since this is an app focused on searching for information about movies, a much longer and more descriptive Wikipedia plot summary is needed (which is never displayed to the customer directly, but used as input for the LLM to improve the response accuracy).  

However, note the limitations - the IMDB dataset only contains the top 1000 movies and tv shows from ***3 years ago***, when it was uploaded! Meanwhile, the Wikipedia Movie Plots Dataset was uploaded even earlier, 6 years ago! This dataset serves the purpose of demonstration for this app, but for production, we would use the IMDB and Wikipedia APIs to create a more up-to-date dataset. 

Knowing the strengths and limitations of your dataset is crucial, as these weaknesses will directly impact the final customer experience. 

The final dataset is included in the app as a `movieData.csv` file in the `Resources` folder. The `CSVDataManager` converts the data in the CSV file into SwiftData models when the app is opened by the customer for the first time. 

### 2. Converting the Data to Text Embeddings

When working with database columns, the data source is disjointed. That is why it is so hard to search for movies by a specific director, for example - most apps will just have regex-based search done on the movie title column. Only in Advanced Search you can specify the director, which will then do a lookup in the director column. 

To prepare the data for LLM-based searched, the first step is to join the data into one piece of text. This is done in the `AIIntelligenceManager`:
```swift
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
```
This text is then converted into a Text Embedding (see explanation above) - to make this simpler, the description is translated into tokens (smaller segments of words) and mapped into an array of numbers which signify the tokens. 

This process is done in the `MovieTextEmbeddingsIndexer`:
```swift
let embeddings = try await intelligence.textEmbeddings(
    for: Array(descriptionsByID.values),
    model: AIIntelligenceManager.embeddingModel
)

let embeddingsWithIDs = embeddings.enumerated().map({
    (
        descriptionsByID.elements[$0.offset].key.stringValue,
        $0.element.embedding.rawValue
    )
})
```
The array of all 1000 movie descriptions is sent to OpenAI’s Text Embeddings API. OpenAI in turn returns the the indexed result of embeddings (arrays of doubles), which are written to a local CSV file with the key as the SwiftData `MovieItem` model id and the embedding value for easy mapping between the SwiftData model and the embedding. 

The final CSV file will look as follows:

<img width="1920" alt="Untitled" src="https://github.com/preternatural-explore/AIMovieSearch/assets/1157147/ddbd575d-74ae-4796-99e7-9b2e12d42db0"><br />

Taking a closer look at one row, we can see the full text embedding - what one movie description converted into token mappings looks like: 

<img width="1420" alt="Untitled" src="https://github.com/preternatural-explore/AIMovieSearch/assets/1157147/75e8e5ad-ab4a-4cc1-8f9e-b86072f80ce7"><br />

From this, we can see that the magic of LLMs comes down to doing calculations with numbers  :) 

### 3. Converting the Search Query to an Embedding

Now that we’ve done the backend work of converting our datasource into text embeddings, we focus to the front-end. What happens when the user enters a search query such as “a thriller in London”. 

The answer to this is very simple - we have to convert the search query into a text embedding, using the same embedding model as the movie description embeddings (in this case Open AI’s text-embedding-3-small). 

As mentioned above, LLMs can be thought of as super calculators. They work with numbers, not actually text (the text is converted to numbers). So to do math between the user query and the movie descriptions, we have to convert both to sets of numbers using the same tokenizer model (otherwise the numbers wouldn’t match up!). 

**3a. Use an LLM to Modify the Search Query**

But before doing the embeddings conversion, we can use an LLM to improve the user’s search query. For the search to be more effective, we want to match more closely to the style that the movie description is written in. Remember, the descriptions are converted to numbers and math is performed to determine which numbers closely match the user query. So the closer the user query numbers (based on tokens) match the description numbers, the better the results.

This is done in the `SearchManager` using the Few-Shot Prompting technique of giving a few examples of the output we expect to the LLM: 

```swift
// SearchManager
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

// AIIntelligenceManager
static func messagesForText(_ text: String) -> [AbstractLLM.ChatMessage] {
    /// This is an example of few-shot prompting (i.e. using example task inputs+outputs).
    ///
    /// We do this so that GPT knows that it is only supposed to answer with the string and nothing more. If we don't add the examples, it'll add random text like "Sure! I can help you with that"
    ///
    /// https://docs.anthropic.com/claude/docs/use-examples
    let messages: [AbstractLLM.ChatMessage] = [
        .system {
            """
            You are MovieSearchGPT.
            
            The user will give you a search query. It can be a word, a sentence, or a paragraph.
            Your job is to shorten it down to the length and format of a Google search.
            Add keywords to the original search query as appropriate.
            
            Remember, you must ONLY return the modified search query. NOTHING more.
            """
        },
        // sample user seach query
        .user {
            """
            sci-fi
            """
        },
        // example response from the LLM
        .assistant {
            """
            A science fiction (sci-fi) movie or film.
            """
        },
	      // another sample search query
        .user {
            """
            A film where two people get really sad after falling in love and then breaking up.
            """
        },
        // another example response from the LLM
        .assistant {
            """
            A movie where the plot is a romantic drama that ends in tragedy.
            """
        },
        // the actual user search query
        .user {
            """
            \(text)
            """
        }
    ]
    return messages
}
```

Note that this modification of the user query process can be applied to any subject-matter. For example, if you have an app that requires search through scientific papers, you would modify the search query to match the language of the scientific paper. Or if you are building an app around fitness, you would modify the user query to use fitness-specific jargon, and so on.

**3b: Now Convert the Modified Search Query into a Text Embedding**

The modified search query can now be turned into a Text Embedding using the same OpenAI API call for text embeddings: 

```swift
// SearchManager

let text = try await modifySearchQuery(text)

let searchEmbedding: [Double] = try await intelligence.textEmbedding(
    for: text,
    model: AIIntelligenceManager.embeddingModel
).rawValue
```

### 4. Using Vector Search

Now we simply search through the movie embeddings using the search embedding. This sounds complex, but it is done with a simple cosine similarity search accomplished with only a few lines of code using Apple’s `Accelerate`  framework: 

```swift
// DataFrameIndex

// Accelerate framework
extension vDSP {
    public static func cosineSimilarity<U: AccelerateBuffer>(
        lhs: U,
        rhs: U
    ) -> Double where U.Element == Double {
        let dotProduct = vDSP.dot(lhs, rhs)
        
        let lhsMagnitude = vDSP.sumOfSquares(lhs).squareRoot()
        let rhsMagnitude = vDSP.sumOfSquares(rhs).squareRoot()
        
        return dotProduct / (lhsMagnitude * rhsMagnitude)
    }
}
```

The final query code is as follows: 

```swift
// DataFrameIndex

func query(
    _ query: [Double],
    topK: Int
) -> [SearchResult] {
    let similarities = storage.rows.map { row -> Double in
        let vector = row[vectorColumnName, [Double].self]
        return vDSP.cosineSimilarity(lhs: vector!, rhs: query)
    }
    
    // the results are then sorted by highest relevance 
    let sortedIndices = similarities.indices.sorted(by: { similarities[$0] > similarities[$1] })
    let topIndices = Array(sortedIndices.prefix(topK))
    
    return topIndices.map { index in
        let key = storage[row: index][keyColumnName, String.self]!
        let score = similarities[index]
        return SearchResult(id: key, score: score)
    }
}
```

The interesting part here is that there is not only one search result, but many results each assigned a relevance score. Low relevance results can be filtered out. To manage customer expectations, the relevance score could be displayed. This way, even if a result is ranked first, customers can understand it may not be the most pertinent to their search.

### Conclusion

To implement AI-powered Search in the Movie App, we utilized the Retrieval-Augmented Generation (RAG) strategy. Instead of directly using OpenAI’s LLM, which lacks access to our specific dataset, we employed their text embeddings model to break down the text into their established token mappings.  

We then modified the user query to match our dataset style and transformed the revised search query using the same text embeddings model as the dataset. Once the embeddings were set, we applied a simple cosine similarity search via Apple's `Accelerate` framework to calculate the movie text embeddings that were closest mathematically to the user's search query embedding. This process yielded a list of results with relevance scores.

## FAQ

### How to work with larger datasets?

In this example of the movie search app, the dataset is small enough to be stored locally in a CSV file and SwiftData. But what if actually scraped the IMBD database and got over 35,000 movie results? 

In that case, the data would be stored in a database on the server. In addition to this database, you would have a vector database such as [Pinecone](https://www.pinecone.io/learn/vector-database/) (there will be a boom in the vector database field) which will only hold the key (id reference of the object in your main database) and value (the text embedding which you can generate via a script). These databases are specialized in vector search and  will have a protocol for providing the search query and getting back the relevant results. 

### How to get text embeddings for larger texts?

In the movie search app example, we were able to provide an array of all movie descriptions to the OpenAI API and get back the results. But what if we have a set of very large texts that would be too big to put into an array?

This would involve a more complex strategy of chunking (or splitting up the text) into several parts. However, this might get complicated as you would need to know exactly where to split up the text and the search might get complicated as LLMs need the full context for effective search. As of now OpenAI is building it’s own vector database where you can upload the files and the embeddings and search will be managed for you.




