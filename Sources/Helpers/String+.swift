//
//  File.swift
//  
//
//  Created by Tuan Hoang on 7/3/24.
//

import Foundation

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
