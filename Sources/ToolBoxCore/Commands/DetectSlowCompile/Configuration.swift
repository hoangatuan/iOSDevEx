//
//  File.swift
//  
//
//  Created by Tuan Hoang on 10/3/24.
//

import Foundation

extension DetectSlowCompileHandler {
    public struct Configuration {
        /// The path to an .xcworkspace
        let xcworkspacePath: String

        /// The path to an .xcodeprojPath
        let xcodeprojPath: String

        /// The root path of the project
        let projectRootPath: String

        /// Scheme name to perform build
        let scheme: String

        let warnLongFunctionBodies: Int
        let warnLongExpressionTypeChecking: Int

        /// Computed property, return the xcworkspacePath if not empty or
        /// the xcodeprojPath if xcworkspacePath is empty
        var projectLocation: String {
            return xcworkspacePath.isEmpty ? xcodeprojPath : xcworkspacePath
        }

        var projectDirectoryURL: String {
            guard var url = URL(string: projectLocation) else { return "" }
            url.deleteLastPathComponent()
            return projectRootPath.isEmpty ? url.path : projectRootPath
        }

        public init(
            xcworkspacePath: String? = nil,
            xcodeprojPath: String? = nil,
            projectRootPath: String? = nil,
            scheme: String,
            warnLongFunctionBodies: Int,
            warnLongExpressionTypeChecking: Int
        ) {
            self.xcworkspacePath = xcworkspacePath ?? ""
            self.xcodeprojPath = xcodeprojPath ?? ""
            self.projectRootPath = projectRootPath ?? ""
            self.scheme = scheme
            self.warnLongFunctionBodies = warnLongFunctionBodies
            self.warnLongExpressionTypeChecking = warnLongExpressionTypeChecking
        }
    }
}
