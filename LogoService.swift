import Foundation

let logoServiceName = "local.logolicht.mac.control"

enum LogoAction: String {
    case off = "Uit"
    case on = "Aan"

    var arguments: [String] {
        let domain = "com.apple.CoreBrightness"
        let key = "LEBacklightMode"
        switch self {
        case .off: return ["write", domain, key, "-int", "0"]
        case .on: return ["delete", domain, key]
        }
    }
}

@objc protocol LogoControl {
    func apply(_ action: String, reply: @escaping (String?) -> Void)
}
