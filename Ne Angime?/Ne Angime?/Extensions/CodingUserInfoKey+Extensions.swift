//
//  CodingUserInfoKey+Extensions.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/3/21.
//

import Foundation

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}
