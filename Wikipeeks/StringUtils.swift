//
//  StringUtils.swift
//  Wikipeeks
//
//  Created by Runar Svendsen on 11/09/2020.
//  Copyright © 2020 Runar Svendsen. All rights reserved.
//

import Foundation
import UIKit

extension String {
    /*
       // borrowed logic from https://stackoverflow.com/questions/31746223/number-of-occurrences-of-substring-in-string-in-swift
     */
    func occurrencesOf(_ substring: String) -> Int {
        return self.components(separatedBy: substring).count - 1
    }
}

/*
 A few convenience methods for building attributed strings courtesy of https://stackoverflow.com/questions/28496093/making-text-bold-using-attributed-string-in-swift
*/
extension NSMutableAttributedString {
    func bold(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [ .font: UIFont.boldSystemFont(ofSize: 16)]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
    
    func normal(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [ .font: UIFont.systemFont(ofSize: 16)]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
}
