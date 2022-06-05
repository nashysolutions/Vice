import ArgumentParser
import ShellOut

private func runShell(_ command: String, continueOnError: Bool = false) throws {
    do {
        try shellOut(
            to: command,
            outputHandle: .standardOutput,
            errorHandle: .standardError
        )
    } catch {
        if !continueOnError {
            throw ShellError()
        }
    }
}

struct ShellError: Error, CustomStringConvertible {
    var description: String {
        "Failed when running shell command"
    }
}

struct Tasks: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "tasks",
        abstract: "An automation task runner for Vice.",
        subcommands: [Linting.self, Install.self, Uninstall.self]
    )
}

extension Tasks {
    struct Linting: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "lint",
            abstract: "Lint the Vice codebase."
        )

        func run() throws {
            try runShell("swift run swiftformat . --lint", continueOnError: true)
            try runShell("swift run swiftlint")
        }
    }
}

extension Tasks {
    struct Install: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "install",
            abstract: "Install Vice for running globally."
        )

        func run() throws {
            try runShell("swift build -c release")
            try runShell("install .build/release/vice /usr/local/bin/vice")
        }
    }
}

extension Tasks {
    struct Uninstall: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "uninstall",
            abstract: "Uninstall Vice and remove it from the system."
        )

        func run() throws {
            try runShell("rm -f /usr/local/bin/vice")
        }
    }
}

Tasks.main()
