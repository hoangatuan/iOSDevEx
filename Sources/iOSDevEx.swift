
import ArgumentParser

struct DevExCommand: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "iOSDevEx",
        abstract: "📦 A tool box to enhance your application",
        version: version,
        subcommands: [
            DetectSlowCompile.self
        ],
        defaultSubcommand: DetectSlowCompile.self
    )
}

enum DevExToolBox {
    public static func start() async {
        await DevExCommand.main()
    }
}

