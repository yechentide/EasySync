//
// Created by yechentide on 2025/01/25
//

import Rainbow

enum ShellColor: UInt32 {
    case info   = 0x7BBFEA
    case ok     = 0x00AE95
    case warn   = 0xFCF16E
    case error  = 0xE66B58
}

extension String {
    func hex(_ shellColor: ShellColor) -> String {
        return self.hex(shellColor.rawValue)
    }
}

enum Logger {
    static func info(_ message: String, renderMessage: Bool = true, terminator: String = "\n") {
        colorMessage(
            prefix: "[INFO] ", message: message,
            color: .info, renderMessage: renderMessage,
            terminator: terminator
        )
    }

    static func ok(_ message: String, renderMessage: Bool = true, terminator: String = "\n") {
        colorMessage(
            prefix: "[ OK ] ", message: message,
            color: .ok, renderMessage: renderMessage,
            terminator: terminator
        )
    }

    static func warn(_ message: String, renderMessage: Bool = true, terminator: String = "\n") {
        colorMessage(
            prefix: "[WARN] ", message: message,
            color: .warn, renderMessage: renderMessage,
            terminator: terminator
        )
    }

    static func error(_ message: String, renderMessage: Bool = true, terminator: String = "\n") {
        colorMessage(
            prefix: "[ERROR]", message: message,
            color: .error, renderMessage: renderMessage,
            terminator: terminator
        )
    }

    private static func colorMessage(prefix: String, message: String, color: ShellColor, renderMessage: Bool, terminator: String) {
        if renderMessage {
            let output = prefix + message
            print(output.hex(color), terminator: terminator)
        } else {
            print(prefix.hex(color) + message, terminator: terminator)
        }
    }
}
