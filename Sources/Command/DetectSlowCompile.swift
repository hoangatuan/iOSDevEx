
import ArgumentParser
import Foundation
import Files

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
        // xcodebuild -workspace YourWorkspace.xcworkspace -scheme YourScheme clean build OTHER_SWIFT_FLAGS="-Xfrontend -warn-long-function-bodies"

//        xcodebuild [build options] [project/scheme options] | tee build_log.txt

        // Step 3: Processing the logs file
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

}
