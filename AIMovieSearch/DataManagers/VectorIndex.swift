//
//  VectorIndex.swift
//  AIMovieSearch
//
//  Created by Natasha Murashev on 3/18/24.
//

import Accelerate
import TabularData

/// A naive vector index that uses a DataFrame to store vectors.
public struct DataFrameIndex {
    public var storage: DataFrame
    
    private let keyColumnName = "key"
    private let vectorColumnName = "vector"
    
    public var keys: Column<String> {
        storage[keyColumnName, String.self]
    }
    
    public init(minimumCapacity: Int = 0) {
        self.storage = DataFrame()
        
        self.storage.append(column: Column<String>(name: keyColumnName, capacity: minimumCapacity))
        self.storage.append(column: Column<[Double]>(name: vectorColumnName, capacity: minimumCapacity))
    }
    
    public init(_ url: URL) throws {
        self.init(minimumCapacity: 0)

        if FileManager.default.fileExists(at: url) {
            let loaded = try DataFrame(contentsOfCSVFile: url, columns: [keyColumnName, vectorColumnName])
            
            for row in loaded.rows {
                let key: String = row[keyColumnName, String.self]!
                let vectorString: String = row[vectorColumnName, String.self]!

                let vector = vectorString.dropFirst().dropLast().components(separatedBy: ",").map({ Double($0.trimmingWhitespace())! })
                
                self.storage.append(valuesByColumn: [keyColumnName: key, vectorColumnName: vector])
            }
        }
    }
    
    public func contains(_ key: String) -> Bool {
        let column = storage.columns.first(where: { $0.name == keyColumnName })!.assumingType(String.self)
        
        return column.contains(where: { $0 == key })
    }
    
    public func save(to url: URL) throws {
        try self.storage.writeCSV(to: url)
    }
    
    public mutating func insert(contentsOf pairs: some Sequence<(String, [Double])>) {
        for pair in pairs {
            storage.append(valuesByColumn: [keyColumnName: pair.0, vectorColumnName: pair.1])
        }
    }
    
    public mutating func remove(_ items: Set<String>) {
        storage = DataFrame(storage.filter({ !items.contains($0[keyColumnName, String.self]!) }))
    }
    
    public mutating func removeAll() {
        storage = DataFrame()
    }
    
    struct SearchResult {
        let id: String
        let score: Double
    }
    
    func query(
        _ query: [Double],
        topK: Int
    ) -> [SearchResult] {
        let similarities = storage.rows.map { row -> Double in
            let vector = row[vectorColumnName, [Double].self]
            return vDSP.cosineSimilarity(lhs: vector!, rhs: query)
        }
        
        let sortedIndices = similarities.indices.sorted(by: { similarities[$0] > similarities[$1] })
        let topIndices = Array(sortedIndices.prefix(topK))
        
        return topIndices.map { index in
            let key = storage[row: index][keyColumnName, String.self]!
            let score = similarities[index]
            return SearchResult(id: key, score: score)
        }
    }
}

//Accelerate Framework
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
