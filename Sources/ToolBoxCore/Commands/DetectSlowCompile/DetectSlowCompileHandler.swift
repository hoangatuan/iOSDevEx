//
//  File.swift
//  
//
//  Created by Tuan Hoang on 10/3/24.
//

import Foundation
import Files
import ShellOut
import XCLogParser

public enum DetectSlowCompileError: Error {
    case invalidProjectPath
}

public class DetectSlowCompileHandler {

    let config: Configuration
    var tempDirectoryURL: String = ""

    public init(config: Configuration) {
        self.config = config
    }

    public func detect() throws -> [String] {
        do {
            try createTempProject()
            FileManager.default.changeCurrentDirectoryPath(tempDirectoryURL)
            
            try modifyPackageFiles()
            let results = try generateWarningForXcode15_3()
            try cleanUp()
            return results
        } catch {
            try cleanUp()
            throw error
        }
    }

    private func modifyPackageFiles() throws {
        let filePaths = try getPackageFilePaths()
        for path in filePaths {
            let file = try File(path: path)
            let config = """
            \nfor target in package.targets {
                target.swiftSettings = target.swiftSettings ?? []
                target.swiftSettings?.append(
                    .unsafeFlags([
                        "-Xfrontend", "-warn-long-function-bodies=\(config.warnLongFunctionBodies)", "-Xfrontend", "-warn-long-expression-type-checking=\(config.warnLongExpressionTypeChecking)",
                    ])
                )
            }
            """
            try file.append(config, encoding: .utf8)
        }
    }

    private func getPackageFilePaths() throws -> [String] {
        var results: [String] = []
        try Folder(path: tempDirectoryURL).files.recursive.forEach { file in
            if file.path.contains("Package.swift") {
                results.append(file.path)
            }
        }

        return results
    }

    private func createTempProject() throws {
        let projectRootPath = config.projectDirectoryURL
        guard !projectRootPath.isEmpty, let projectDirectoryURL = URL(string: projectRootPath) else { throw DetectSlowCompileError.invalidProjectPath }

        let lastComponent = projectDirectoryURL.lastPathComponent
        let modifiedDirectory = projectDirectoryURL.deletingLastPathComponent()
        let destination = modifiedDirectory.appendingPathComponent(lastComponent + "_detect_slow_compile")
        self.tempDirectoryURL = destination.path

        if FileManager.default.fileExists(atPath: tempDirectoryURL) {
            try FileManager.default.removeItem(atPath: tempDirectoryURL)
        }

        try FileManager.default.copyItem(
            atPath: projectDirectoryURL.path,
            toPath: destination.path
        )
    }

    /// This func can be used for every Xcode version, and it has better performance compare to using XCLogParser.
    /// The downside is it's hard to customize the format of the warnings.
    private func generateWarningForXcode15_3() throws -> [String] {
        let warningsFileName = "warnings.txt"
        var arguments: [String] = [
            "-scheme \(config.scheme)",
            "-sdk iphonesimulator",
            "-destination 'platform=iOS Simulator,name=iPhone 15 Pro'",
            "OTHER_SWIFT_FLAGS=\"-Xfrontend -warn-long-function-bodies=\(config.warnLongFunctionBodies) -Xfrontend -warn-long-expression-type-checking=\(config.warnLongExpressionTypeChecking)\"",
            //                "-derivedDataPath", /// to support in case CI/CD pipelines run in parallel
            "clean",
            "build",
            "| grep .[0-9]ms | grep -v ^0.[0-9]ms | grep \"^\(tempDirectoryURL)\" | sort -nr > \(warningsFileName)"
        ]

        let xcworkspacePath = config.xcworkspacePath.replacingOccurrences(of: config.projectDirectoryURL, with: self.tempDirectoryURL)
        let xcodeprojPath = config.xcodeprojPath.replacingOccurrences(of: config.projectDirectoryURL, with: self.tempDirectoryURL)

        if xcodeprojPath.isEmpty {
            arguments.insert("-workspace \(xcworkspacePath)", at: 0)
        } else {
            arguments.insert("-project \(xcodeprojPath)", at: 0)
        }

        try shellOut(to: "xcodebuild", arguments: arguments)
        let content = try String(contentsOfFile: warningsFileName)
        let warnings = content.split(separator: "\n")
        return warnings.map { String($0) }
    }

    /// This function can only be used for Xcode version before Xcode 15.3: https://github.com/MobileNativeFoundation/XCLogParser/issues/203
    /// We can update this logic to customize the format of the warnings log.
    private func generateWarningsForXcodeSmallerThan15_3() throws -> [String]? {
        var arguments: [String] = [
            "-scheme \(config.scheme)",
            "-sdk iphonesimulator",
            "-destination 'platform=iOS Simulator,name=iPhone 15 Pro'",
            "OTHER_SWIFT_FLAGS=\"-Xfrontend -warn-long-function-bodies=\(config.warnLongFunctionBodies) -Xfrontend -warn-long-expression-type-checking=\(config.warnLongExpressionTypeChecking)\"",
            //                "-derivedDataPath", /// to support in case CI/CD pipelines run in parallel
            "-resultBundlePath ./BuildResults",
            "clean",
            "build"
        ]

        let xcworkspacePath = config.xcworkspacePath.replacingOccurrences(of: config.projectDirectoryURL, with: self.tempDirectoryURL)
        let xcodeprojPath = config.xcodeprojPath.replacingOccurrences(of: config.projectDirectoryURL, with: self.tempDirectoryURL)

        if xcodeprojPath.isEmpty {
            arguments.insert("-workspace \(xcworkspacePath)", at: 0)
        } else {
            arguments.insert("-project \(xcodeprojPath)", at: 0)
        }
        
        try shellOut(to: "xcodebuild", arguments: arguments)
        return try runParseCommand()
    }

    private func runParseCommand() throws -> [String]? {
        let logOptions = LogOptions(
            projectName: "",
            xcworkspacePath: config.xcworkspacePath,
            xcodeprojPath: config.xcodeprojPath,
            derivedDataPath: "",
            xcactivitylogPath: ""
        )

        let logFinder = LogFinder()
        let activityLogParser = ActivityParser()
        let logURL = try logFinder.findLatestLogWithLogOptions(logOptions)

        let activityLog = try activityLogParser.parseActivityLogInURL(logURL,
                                                                      redacted: false,
                                                                      withoutBuildSpecificInformation:
                                                                        false)

        let buildParser = ParserBuildSteps(machineName: "",
                                           omitWarningsDetails: false,
                                           omitNotesDetails: true,
                                           truncLargeIssues: false)

        let buildSteps = try buildParser.parse(activityLog: activityLog)
        return buildSteps.warnings?.compactMap { $0.detail }
    }

    private func cleanUp() throws {
        try FileManager.default.removeItem(atPath: tempDirectoryURL)
    }
}
