
import ArgumentParser
import Foundation
import Files
import ShellOut
import XCLogParser

struct DetectSlowCompile: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "detect-slow-compile",
        abstract: "Detect slow compile code"
    )

    #if DEBUG
    var workspace: String = "iMovie.xcworkspace"

    var scheme: String = "iMovie"

    var projectRootPath: String = "/Users/tuanhoang/Documents/iMovie"

    var warnLongFunctionBodies: Int = 10

    var warnLongExpressionTypeChecking: Int = 10

    #else
    @Argument(help: "")
    var workspace: String

    @Argument(help: "")
    var scheme: String

    @Option(name: .shortAndLong, help: "The root path of your project")
    var projectRootPath: String
    #endif

    func run() throws {

        FileManager.default.changeCurrentDirectoryPath(projectRootPath)

         Step 1: Interate through all the files
        let filePaths = try getPackageFilePaths()
        for path in filePaths {
            let file = try File(path: path)
            let config = """
            \nfor target in package.targets {
                target.swiftSettings = target.swiftSettings ?? []
                target.swiftSettings?.append(
                    .unsafeFlags([
                        "-Xfrontend", "-warn-long-function-bodies=\(warnLongFunctionBodies)", "-Xfrontend", "-warn-long-expression-type-checking=\(warnLongExpressionTypeChecking)",
                    ])
                )
            }
            """
            try file.append(config, encoding: .utf8)
        }

        // Step 2: Build and generate the logs file
        do {
//            let warnings = try generateWarningsForXcodeSmallerThan15_3()
            let warnings = try generateWarningForXcode15_3()
        } catch let error {
            debugPrint("\(error)")
        }
    }

    /// This function will be used for Xcode smaller than 15.3
    private func generateWarningsForXcodeSmallerThan15_3() throws -> [String]? {
        try shellOut(to: "xcodebuild", arguments: [
            "-workspace \(workspace)",
            "-scheme \(scheme)",
            "-sdk iphonesimulator",
            "-destination 'platform=iOS Simulator,name=iPhone 15 Pro'",
            "OTHER_SWIFT_FLAGS=\"-Xfrontend -warn-long-function-bodies=\(warnLongFunctionBodies) -Xfrontend -warn-long-expression-type-checking=\(warnLongExpressionTypeChecking)\"",
//                "-derivedDataPath", /// to support in case CI/CD pipelines run in parallel
            "-resultBundlePath ./BuildResults",
            "clean",
            "build"
        ])

        return try runParseCommand()
    }

    private func generateWarningForXcode15_3() throws -> [String]? {
        try shellOut(to: "xcodebuild", arguments: [
            "-workspace \(workspace)",
            "-scheme \(scheme)",
            "-sdk iphonesimulator",
            "-destination 'platform=iOS Simulator,name=iPhone 15 Pro'",
            "OTHER_SWIFT_FLAGS=\"-Xfrontend -warn-long-function-bodies=\(warnLongFunctionBodies) -Xfrontend -warn-long-expression-type-checking=\(warnLongExpressionTypeChecking)\"",
//                "-derivedDataPath", /// to support in case CI/CD pipelines run in parallel
            "clean",
            "build",
            "| grep .[0-9]ms | grep -v ^0.[0-9]ms | grep \"^\(projectRootPath)\" | sort -nr > warning.txt"
        ])

        let content = try String(contentsOfFile: "warning.txt")

        let warnings = content.split(separator: "\n")
        return warnings.map { String($0) }
    }

    private func getPackageFilePaths() throws -> [String] {
        var results: [String] = []
        try Folder(path: projectRootPath).files.recursive.forEach { file in
            if file.path.contains("Package.swift") {
                results.append(file.path)
            }
        }

        return results
    }

    private func runParseCommand() throws -> [String]? {
        let logOptions = LogOptions(
            projectName: "",
            xcworkspacePath: workspace,
            xcodeprojPath: "",
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
    
}
