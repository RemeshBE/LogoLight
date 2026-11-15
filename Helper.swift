import Darwin
import CoreFoundation
import Foundation

final class LogoHelper: NSObject, LogoControl, NSXPCListenerDelegate {
    private let queue = DispatchQueue(label: "local.logolicht.mac.changes")

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection connection: NSXPCConnection) -> Bool {
        var user = UUID().uuid
        var admin = UUID().uuid
        var member: Int32 = 0
        guard mbr_uid_to_uuid(connection.effectiveUserIdentifier, &user) == 0,
              mbr_gid_to_uuid(80, &admin) == 0,
              mbr_check_membership(&user, &admin, &member) == 0,
              member == 1 else { return false }

        connection.exportedInterface = NSXPCInterface(with: LogoControl.self)
        connection.exportedObject = self
        connection.resume()
        return true
    }

    func apply(_ requestedAction: String, reply: @escaping (String?) -> Void) {
        guard let action = LogoAction(rawValue: requestedAction) else {
            reply("Onbekende logoactie.")
            return
        }

        queue.async {
            let process = Process()
            let errors = Pipe()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
            process.arguments = action.arguments
            process.environment = ["HOME": "/var/root", "PATH": "/usr/bin:/bin"]
            process.standardError = errors

            do {
                try process.run()
                let output = errors.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                let message = String(decoding: output, as: UTF8.self)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if process.terminationStatus == 0 {
                    reply(nil)
                } else if action == .on, CFPreferencesCopyValue(
                    "LEBacklightMode" as CFString, "com.apple.CoreBrightness" as CFString,
                    kCFPreferencesCurrentUser, kCFPreferencesAnyHost
                ) == nil {
                    reply(nil)
                } else {
                    reply(message.isEmpty ? "De wijziging is niet bevestigd." : message)
                }
            } catch {
                reply(error.localizedDescription)
            }
        }
    }
}

@main
enum Helper {
    static func main() {
        let helper = LogoHelper()
        let listener = NSXPCListener(machServiceName: logoServiceName)
        listener.delegate = helper
        listener.resume()
        withExtendedLifetime(helper) { RunLoop.main.run() }
    }
}
