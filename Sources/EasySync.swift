// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct EasySync: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "easy-sync",
        discussion: "",
        version: "0.0.1",
        shouldDisplay: true,
        subcommands: [
            BackupCommand.self,
            DiffCommand.self,
        ]
    )
}
