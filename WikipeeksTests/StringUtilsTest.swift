//
//  StringUtilsTest.swift
//  WikipeeksTests
//
//  Created by Runar Svendsen on 11/09/2020.
//  Copyright © 2020 Runar Svendsen. All rights reserved.
//

import Foundation
import XCTest

class StringUtilsTest: XCTestCase {
    
    func testOccurrencesOf() {
        let expected = 3
        let source = "The quick brown fox jumps over the lazy dog"
        XCTAssert(source.occurrencesOf("e") == expected)
    }
    
}
