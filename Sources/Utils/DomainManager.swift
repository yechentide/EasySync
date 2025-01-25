//
// Created by yechentide on 2025/01/24
//

import Foundation

struct DomainManager {
    enum PlistError: Error {
        case keyNotFound
        case invalidValueFormat
    }

    static let shared = DomainManager()
    static let ignoredDomains: Set<String> = []

    private init() {}

    static func isAppleDomain(_ domain: String) -> Bool {
        domain.hasPrefix("com.apple.")
    }

    static func temporaryConfigFileURL(for domain: String) -> URL {
        return FileManager.default.temporaryDirectory.appending(path: domain, directoryHint: .notDirectory)
    }

    func listDomains() throws -> [String] {
        let domainsString = try ShellCommand.defaults.run(with: ["domains"])
        var domains: [String] = []
        domainsString.split(separator: ",").forEach {
            let domain = String($0.trimmingCharacters(in: .whitespaces))
            guard !Self.ignoredDomains.contains(domain) else {
                return
            }
            domains.append(domain)
        }
        return domains
    }

    func exportConfig(for domain: String, to configFileURL: URL? = nil) throws -> String {
        let config = try ShellCommand.defaults.run(with: ["export", domain, "-"])
        if let url = configFileURL {
            try config.write(to: url, atomically: false, encoding: .utf8)
        }
        return config
    }

    func importConfig(_ config: String, for domain: String) throws {
        try ShellCommand.defaults.run(with: ["import", domain, "-"], input: config)
    }

    func value(forKey key: String, in domain: String) throws -> Any? {
        let configFileURL = Self.temporaryConfigFileURL(for: domain)
        let _ = try exportConfig(for: domain, to: configFileURL)
        defer {
            try? FileManager.default.removeItem(at: configFileURL)
        }

        do {
            let value = try ShellCommand.plistBuddy.run(with: [
                "-c", "Print :\(key)", configFileURL.path()
            ])
            return value
        } catch {
            switch error {
                case ShellCommand.ShellCommandError.nonZeroExitStatus(_, let msg):
                    if msg.lowercased().contains("not exist") {
                        return nil
                    }
                    throw error
                default:
                    throw error
            }
        }
    }

    func setValues(_ pairs: [(key: String, value: Any)], for domain: String) throws {
        let configFileURL = Self.temporaryConfigFileURL(for: domain)
        let _ = try exportConfig(for: domain, to: configFileURL)
        defer {
            try? FileManager.default.removeItem(at: configFileURL)
        }

        for data in pairs {
            let output = try ShellCommand.plistBuddy.run(with: [
                "-c", "Set :'\(data.key)' \(data.value)", configFileURL.path()
            ])
            if !output.isEmpty {
                if output.contains("Does Not Exist") {
                    throw PlistError.keyNotFound
                }
                if output.contains("Unrecognized") {
                    throw PlistError.invalidValueFormat
                }
            }
        }
        let newConfig = try String(contentsOf: configFileURL, encoding: .utf8)
        try importConfig(newConfig, for: domain)
    }
}

/* type(of: value) */
// __NSCFBoolean
// __NSCFNumber
// __NSCFString __NSCFConstantString NSTaggedPointerString
// __NSTaggedDate
// __NSCFData
// __NSArrayM
// __NSDictionaryM
