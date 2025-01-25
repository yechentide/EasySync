//
// Created by yechentide on 2025/01/24
//

import Foundation

enum ShellCommand: String {
    case defaults       = "/usr/bin/defaults"
    case plistBuddy     = "/usr/libexec/PlistBuddy"
    case mdls           = "/usr/bin/mdls"
    case mdfind         = "/usr/bin/mdfind"
    case diff           = "/usr/bin/diff"

    enum ShellCommandError: Error {
        case nonZeroExitStatus(Int32, String)
    }

    @discardableResult
    func run(with arguments: [String], input: String? = nil, collectOutput: Bool = true) throws -> String {
        if self == .diff {
            print(arguments)
        }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: self.rawValue)
        process.arguments = arguments

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        if collectOutput {
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
        }
        if let input = input {
            let stdinPipe = Pipe()
            process.standardInput = stdinPipe
            if let inputData = input.data(using: .utf8) {
                stdinPipe.fileHandleForWriting.write(inputData)
                stdinPipe.fileHandleForWriting.closeFile()
            }
        }

        try process.run()
        if !collectOutput {
            process.waitUntilExit()
            return ""
        }

        var stdoutData = Data()
        var stderrData = Data()
        while true {
            if let data = try? stdoutPipe.fileHandleForReading.readToEnd() {
                stdoutData.append(data)
            }
            if let data = try? stderrPipe.fileHandleForReading.readToEnd() {
                stderrData.append(data)
            }
            if !process.isRunning {
                break
            }
        }
        try stdoutPipe.fileHandleForReading.close()
        try stderrPipe.fileHandleForReading.close()

        if process.terminationStatus != 0 {
            let stderr = String(data: stderrData, encoding: .utf8) ?? ""
            throw ShellCommandError.nonZeroExitStatus(process.terminationStatus, stderr)
        }

        let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
        return stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func clear() {
        print("\u{001B}[2J\u{001B}[H")
    }
}
