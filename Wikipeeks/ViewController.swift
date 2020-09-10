//
//  ViewController.swift
//  Wikipeeks
//
//  Created by Runar Svendsen on 10/09/2020.
//  Copyright © 2020 Runar Svendsen. All rights reserved.
//

import UIKit
import WebKit
import PromiseKit

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func searchPressed(_ sender: UIButton) {
        guard let topic = self.searchField.text else {
            print("No topic")
            return
        }
        search(for: topic)
        .done(show)
        .catch(showError)
    }
    
    private func search(for topic: String) -> Promise<SearchResult> {
        let decoder = JSONDecoder()
        guard let encodedTopic = topic.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://en.wikipedia.org/w/api.php?action=parse&section=0&prop=text&format=json&page=\(encodedTopic)") else {
                return Promise(error: AppErrors.appError(reason: "Could not start search, please try again"))
        }
        activityIndicator.startAnimating()
        var searchData: Data!
        return URLSession.shared.dataTask(.promise, with: URLRequest(url: url))
            .map {
                searchData = $0.data
                return try decoder.decode(SearchResult.self, from: searchData)
            }.recover { error -> Promise<SearchResult> in
                print(error)
                let searchResultError = try decoder.decode(SearchResultError.self, from: searchData)
                throw AppErrors.appError(reason: searchResultError.error.info)
            }.ensure {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func show(_ result: SearchResult) {
        webView.loadHTMLString(result.parse.text.value, baseURL: URL(string: "https://en.wikipedia.org"))
    }
    
    private func showError(_ error: Error) {
        print("An error occurred: \(error)")
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

/* Value objects search result */
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

/* Error objects */
enum AppErrors: Error {
  case appError(reason: String)
}

extension AppErrors: LocalizedError {
  var errorDescription: String? {
    switch(self) {
    case .appError(reason: let reason):
      return reason
    }
  }
}


