//
//  A lightweight Wikipedia api implementation.
//
//  Created by Runar Svendsen on 11/09/2020.
//  Copyright © 2020 Runar Svendsen. All rights reserved.
//

import Foundation
import PromiseKit

struct Api {
    
    static func search(for topic: String) -> Promise<(String, SearchResult)> {
        let decoder = JSONDecoder()
        guard let encodedTopic = topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://en.wikipedia.org/w/api.php?action=parse&section=0&prop=text&format=json&page=\(encodedTopic)") else {
                return Promise(error: AppErrors.appError(reason: "Could not start search, please try again"))
        }
        var searchData: Data!
        return URLSession.shared.dataTask(.promise, with: URLRequest(url: url))
            .map { (data, response) -> (String, SearchResult) in
                searchData = data
                let searchResult = try decoder.decode(SearchResult.self, from: searchData)
                return (topic, searchResult)
            }.recover { error -> Promise<(String, SearchResult)> in
                print(error)
                let searchResultError = try decoder.decode(SearchResultError.self, from: searchData)
                throw AppErrors.appError(reason: searchResultError.error.info)
        }
    }
}

/* Value objects for search result */
struct SearchResult: Decodable {
    let parse: Parse
}

struct Parse: Decodable {
    let title: String
    let pageID: Int
    let text: ParseText
    
    enum CodingKeys: String, CodingKey {
        case pageID = "pageid"
        case title
        case text
    }
}

struct ParseText: Decodable {
    let value: String

    enum CodingKeys: String, CodingKey {
        case value = "*"
    }
}

/* Value objects for parsing search result errors */
struct SearchResultError: Decodable {
    let error: SearchError
    let servedBy: String
    
    enum CodingKeys: String, CodingKey {
        case error
        case servedBy = "servedby"
    }
}

struct SearchError: Decodable {
    let code: String
    let info: String
    let value: String
    enum CodingKeys: String, CodingKey {
        case code
        case info
        case value = "*"
    }
}
