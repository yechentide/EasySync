//
// Created by yechentide on 2025/01/24
//

import Foundation

enum IconManager {
    static func appBundleIdentifier(for path: String) throws -> String {
        return try ShellCommand.mdls.run(with: ["-name", "kMDItemCFBundleIdentifier", "\(path)"])
    }

    static func readInfoPlist(from appPath: String) throws -> [String: Any] {
        let appURL = URL(fileURLWithPath: appPath)
        let plistURL = appURL.appending(path: "Contents").appending(path: "Info.plist")
        let plistData = try Data(contentsOf: plistURL)
        guard let plist = try PropertyListSerialization.propertyList(
            from: plistData, options: [], format: nil
        ) as? [String: Any] else {
            return [:]
        }
        return plist
    }

    static func appIconFileURL(forAppAt path: String) throws -> URL {
        let appURL = URL(fileURLWithPath: path)
        let plistURL = appURL.appending(path: "Contents").appending(path: "Info.plist")
        var iconFileName = try ShellCommand.plistBuddy.run(with: [
            "-c", "Print :CFBundleIconFile", plistURL.path(percentEncoded: false)
        ])
        if !iconFileName.hasSuffix(".icns") {
            iconFileName += ".icns"
        }
        return appURL.appending(path: "Contents").appending(path: "Resources").appending(path: iconFileName)
    }

    static func findApp(with bundleID: String) throws -> URL? {
        let appPath = try ShellCommand.mdfind.run(with: [
            "kMDItemCFBundleIdentifier == '\(bundleID)'"
        ])
        if appPath.isEmpty {
            return nil
        }
        return URL(fileURLWithPath: appPath)
    }
}
