//
// Created by yechentide on 2025/01/25
//

import Foundation
import ArgumentParser

struct BackupCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "backup",
        abstract: "",
        discussion: "",
        shouldDisplay: true
    )

    @Option(name: .customLong("lang"), help: "Specifies the language code to use")
    var language: String? = nil

    @Option(name: .customLong("output-dir"), help: "Specifies the path to the output directory")
    var outputDirectoryPath: String? = nil

    func run() throws {
        setLanguage(language)

        let outputDirPath: String
        if let path = outputDirectoryPath {
            outputDirPath = path
        } else {
            outputDirPath = FileManager.default.currentDirectoryPath
        }
        Logger.info("Starting backup at the following path:", terminator: " ")
        print(outputDirPath)

        let domains = try DomainManager.shared.listDomains()
        let totalCount = domains.count
        Logger.info("Found \(totalCount) domains")

        var exported = 0
        let outputDirURL = URL(fileURLWithPath: outputDirPath)
        for domain in domains {
            let current = (exported + 1).description.padding(
                toLength: totalCount.description.count,
                withPad: " ",
                startingAt: 0
            )
            Logger.warn("\(current)/\(totalCount) Exporting domain: \(domain)")
            let filePath = outputDirURL.appending(path: "\(domain).plist")
            let _ = try DomainManager.shared.exportConfig(for: domain, to: filePath)
            exported += 1
        }

        Logger.ok("Backup completed!")
    }
}
