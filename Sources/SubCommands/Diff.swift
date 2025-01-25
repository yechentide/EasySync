//
// Created by yechentide on 2025/01/25
//

import Foundation
import ArgumentParser

struct DiffCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "diff",
        abstract: "",
        discussion: "",
        shouldDisplay: true
    )

    @Option(name: .customLong("lang"), help: "Specifies the language code to use")
    var specifiedLang: String? = nil

    @Option(name: .customLong("input-dir"), help: "Specifies the path to the input directory")
    var specifiedInputDirPath: String? = nil

    func run() throws {
        setLanguage(specifiedLang)

        let inputDirURL: URL
        if let path = specifiedInputDirPath {
            inputDirURL = URL(fileURLWithPath: path)
        } else {
            inputDirURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        }
        Logger.info("Using input directory:", terminator: " ")
        print(inputDirURL.path())

        let plistFiles = try getPlistFiles(from: inputDirURL)

        let currentDomains = try DomainManager.shared.listDomains()
        var currentDomainSet: Set<String> = []
        for domain in currentDomains {
            currentDomainSet.insert(domain)
        }
        
        for newDomain in plistFiles.keys {
            guard currentDomainSet.contains(newDomain) else {
                continue
            }
            let newConfig = String(data: try Data(contentsOf: plistFiles[newDomain]!), encoding: .utf8) ?? ""
            let currentConfig = try DomainManager.shared.exportConfig(for: newDomain)
            if isConfigChanged(currentConfig: currentConfig, newConfig: newConfig.trimmingCharacters(in: .whitespacesAndNewlines)) {
                ShellCommand.clear()
                Logger.warn("Configuration changed for domain: \(newDomain)")
                try printDiff(configA: currentConfig, configB: newConfig)
                ShellCommand.clear()
            }
        }
    }

    private func printDiff(configA: String, configB: String) throws {
        let urlA = URL(fileURLWithPath: "/tmp/" + UUID().uuidString + ".plist")
        let urlB = URL(fileURLWithPath: "/tmp/" + UUID().uuidString + ".plist")
        try configA.write(to: urlA, atomically: false, encoding: .utf8)
        try configB.write(to: urlB, atomically: false, encoding: .utf8)
        let _ = try ShellCommand.diff.run(
            with: ["-u", "--color=always", urlA.path(), urlB.path()],
            collectOutput: false
        )
        Logger.info("Press ENTER to continue ...")
        let _ = readLine()
    }

    private func isConfigChanged(currentConfig: String?, newConfig: String?) -> Bool {
        return currentConfig != newConfig
    }

    private func getPlistFiles(from dirURL: URL) throws -> [String:URL] {
        var plistFiles: [String:URL] = [:]

        let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
        let contents = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: keys)
        for fileURL in contents {
            let attributes = try fileURL.resourceValues(forKeys: Set(keys))
            guard attributes.isDirectory == false,
                  let fileName = attributes.name,
                  fileName.hasSuffix(".plist")
            else {
                continue
            }
            let domain = String(fileName.dropLast(".plist".count))
            guard !DomainManager.ignoredDomains.contains(domain) else {
                continue
            }
            let url = dirURL.appending(path: fileName)
            plistFiles[domain] = url
        }

        return plistFiles
    }
}
