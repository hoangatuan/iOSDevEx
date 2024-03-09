
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

        // Step 1: Interate through all the files
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
            try shellOut(to: "xcodebuild", arguments: [
                "-workspace \(workspace)",
                "-scheme \(scheme)",
                "-sdk iphonesimulator",
                "-destination 'platform=iOS Simulator,name=iPhone 15 Pro'",
                "OTHER_SWIFT_FLAGS=\"-Xfrontend -warn-long-function-bodies=\(warnLongFunctionBodies) -Xfrontend -warn-long-expression-type-checking=\(warnLongExpressionTypeChecking)\"",
//                "-derivedDataPath", /// to support in case CI/CD pipelines run in parallel
                "clean",
                "build",
//                "| tee build_log.txt"
//                "| grep .[0-9]ms | grep -v ^0.[0-9]ms | sort -nr > culprits.txt"
            ])
            
            try runParseCommand()
        } catch let error {
            debugPrint("Tuanha24: \(error)")
        }
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

    private func runParseCommand() throws {
        let commandHandler = CommandHandler()
        let logOptions = LogOptions(
            projectName: "",
            xcworkspacePath: workspace,
            xcodeprojPath: "",
            derivedDataPath: "",
            xcactivitylogPath: ""
        )
        
        let actionOptions = ActionOptions(reporter: Reporter.issues,
                                          outputPath: "",
                                          redacted: false,
                                          withoutBuildSpecificInformation: false,
                                          machineName: "",
                                          rootOutput: "",
                                          omitWarningsDetails: false,
                                          omitNotesDetails: false,
                                          truncLargeIssues: false)
        let action = Action.parse(options: actionOptions)
        let command = Command(logOptions: logOptions, action: action)
        try commandHandler.handle(command: command)
    }
    
}

/*
 // Step 3: Processing the logs file
 let regex1: String = ".*(limit: \(warnLongFunctionBodies)ms).*"
 let regex2: String = ".*(limit: \(warnLongExpressionTypeChecking)ms).*"
 let contents = try File(path: "build_log.txt").readAsString().components(separatedBy: "\n")

 var arr: [String] = []
 for (index, content) in contents.enumerated() {
     print(index)
//            if content.matches(regex1) || content.matches(regex2) {
//                arr.append(content)
//            }
 }

 for text in arr {
     debugPrint(text)
 }
 */
