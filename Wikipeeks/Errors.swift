//
//  Errors.swift
//  Wikipeeks
//
//  Created by Runar Svendsen on 11/09/2020.
//  Copyright © 2020 Runar Svendsen. All rights reserved.
//

import Foundation

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


