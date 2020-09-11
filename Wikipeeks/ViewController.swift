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
    @IBOutlet weak var topicCounter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func searchPressed(_ sender: UIButton) {
        firstly { () -> Promise<String> in
            activityIndicator.startAnimating()
            guard let topic = self.searchField.text else {
                throw AppErrors.appError(reason: "Topic was blank. Please enter something in the search field")
            }
            return .value(topic)
        }.then(Api.search)
        .ensure { [weak self] in
            self?.activityIndicator.stopAnimating()
        }.then(showTopicCount)
        .done(showArticle)
        .catch(showError)
    }
        
    private func showTopicCount(_ topic: String, _ result: SearchResult) -> Promise<SearchResult> {
        let topicCount = result.parse.text.value.occurrencesOf(topic)
        self.topicCounter.attributedText =
            NSMutableAttributedString()
                .bold(topic)
                .normal(" occurs ")
                .bold("\(topicCount)")
                .normal(" times")
        self.topicCounter.isHidden = false
        return .value(result)
    }
    
    private func showArticle(_ result: SearchResult) {
        webView.loadHTMLString(result.parse.text.value, baseURL: URL(string: "https://en.wikipedia.org"))
    }
    
    private func showError(_ error: Error) {
        print("An error occurred: \(error)")
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
