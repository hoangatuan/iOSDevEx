
import ArgumentParser
import Foundation
import ShellOut
import ToolBoxCore
import Files
import XCLogParser

struct DetectSlowCompile: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "detect-slow-compile",
        abstract: "Detect slow compile code"
    )

    #if DEBUG
    var project: String = ""

    var workspace: String = "/Users/tuanhoang/Documents/iOSDevEx/ExampleProject/Cocoapod/CocoapodDemoProject/CocoapodDemoProject.xcworkspace"

    var scheme: String = "CocoapodDemoProject"

    var projectRootPath: String = ""

    var warnLongFunctionBodies: Int = 10

    var warnLongExpressionTypeChecking: Int = 10

    #else
    @Option(name: .long,
            help: """
    The name of an Xcode project. The tool will try to find the latest log folder
    with this prefix in the DerivedData directory. Use with `--strictProjectName`
    for stricter name matching.
    """)
    var project: String?
    
    @Option(name: .long,
            help: """
    The path to the .xcworkspace folder. Used to find the Derived Data project directory
    if no `--project` flag is present.
    """)
    var workspace: String?

    @Argument(help: "build the scheme NAME")
    var scheme: String

    @Option(name: .long, help: """
    The project root path in case the xcodeproj/xcworkspace is not at the root path.
    """)
    var projectRootPath: String

    @Argument(help: "The warnLongFunctionBodies value threshold")
    var warnLongFunctionBodies: Int

    @Argument(help: "The warnLongExpressionTypeChecking value threshold")
    var warnLongExpressionTypeChecking: Int
    #endif

    func run() throws {

        let handler = DetectSlowCompileHandler(
            config: .init(
                xcworkspacePath: workspace,
                xcodeprojPath: project,
                projectRootPath: projectRootPath,
                scheme: scheme,
                warnLongFunctionBodies: warnLongFunctionBodies,
                warnLongExpressionTypeChecking: warnLongExpressionTypeChecking
            )
        )

        let warnings = try handler.detect()
        print(warnings)
    }
}
