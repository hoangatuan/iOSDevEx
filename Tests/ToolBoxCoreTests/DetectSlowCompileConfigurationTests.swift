//
//  DetectSlowCompileConfigurationTests.swift
//  
//
//  Created by Tuan Hoang on 10/3/24.
//

import XCTest
@testable import ToolBoxCore

final class DetectSlowCompileConfigurationTests: XCTestCase {
    func testProjectLocation() {
        var configuration = DetectSlowCompileHandler.Configuration.init(
            xcworkspacePath: "/Users/tuanhoang/Documents/iMovie/iMovie.xcworkspace",
            xcodeprojPath: "",
            projectRootPath: "",
            scheme: "",
            warnLongFunctionBodies: 10,
            warnLongExpressionTypeChecking: 10
        )
        XCTAssertEqual(configuration.projectLocation, "/Users/tuanhoang/Documents/iMovie/iMovie.xcworkspace")
        
        configuration = DetectSlowCompileHandler.Configuration.init(
            xcworkspacePath: "",
            xcodeprojPath: "/Users/tuanhoang/Documents/iMovie/iMovie.xcodeproj",
            projectRootPath: "",
            scheme: "",
            warnLongFunctionBodies: 10,
            warnLongExpressionTypeChecking: 10
        )
        XCTAssertEqual(configuration.projectLocation, "/Users/tuanhoang/Documents/iMovie/iMovie.xcodeproj")
        
        configuration = DetectSlowCompileHandler.Configuration.init(
            xcworkspacePath: "/Users/tuanhoang/Documents/iMovie/iMovie.xcworkspace",
            xcodeprojPath: "/Users/tuanhoang/Documents/iMovie/iMovie.xcodeproj",
            projectRootPath: "",
            scheme: "",
            warnLongFunctionBodies: 10,
            warnLongExpressionTypeChecking: 10
        )
        XCTAssertEqual(configuration.projectLocation, "/Users/tuanhoang/Documents/iMovie/iMovie.xcworkspace")
    }
    
    func testProjectDirectoryURL() {
        var configuration = DetectSlowCompileHandler.Configuration.init(
            xcworkspacePath: "/Users/tuanhoang/Documents/iMovie/iMovie.xcworkspace",
            xcodeprojPath: "",
            projectRootPath: "",
            scheme: "",
            warnLongFunctionBodies: 10,
            warnLongExpressionTypeChecking: 10
        )
        XCTAssertEqual(configuration.projectDirectoryURL, "/Users/tuanhoang/Documents/iMovie")
        
        configuration = DetectSlowCompileHandler.Configuration.init(
            xcworkspacePath: "iMovie.xcworkspace",
            xcodeprojPath: "",
            projectRootPath: "/Users/tuanhoang/Documents/iMovie",
            scheme: "",
            warnLongFunctionBodies: 10,
            warnLongExpressionTypeChecking: 10
        )
        XCTAssertEqual(configuration.projectDirectoryURL, "/Users/tuanhoang/Documents/iMovie")
    }
}
