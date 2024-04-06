//
//  File.swift
//  
//
//  Created by Tuan Hoang Anh on 6/4/24.
//

import Files

extension Folder {
    func getFilePaths(contain str: String) -> [String] {
        var results: [String] = []
        files.recursive.forEach { file in
            if file.path.contains(str) {
                results.append(file.path)
            }
        }
        
        return results
    }
    
    func getFilePaths(hasSuffix str: String) -> [String] {
        var results: [String] = []
        files.recursive.forEach { file in
            if file.path.hasSuffix(str) {
                results.append(file.path)
            }
        }
        
        return results
    }
}
