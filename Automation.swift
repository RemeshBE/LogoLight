import Foundation
import SwiftUI
import CoreLocation
import CoreWLAN
import IOKit.ps

enum SunsetCity: String, CaseIterable, Identifiable {
    case brussels, amsterdam, london, paris, berlin, madrid, newYork, losAngeles, sydney
    var id: Self { self }

    var name: String {
        switch self {
        case .brussels: "Brussels"
        case .amsterdam: "Amsterdam"
        case .london: "London"
        case .paris: "Paris"
        case .berlin: "Berlin"
        case .madrid: "Madrid"
        case .newYork: "New York"
        case .losAngeles: "Los Angeles"
        case .sydney: "Sydney"
        }
    }

    private var coordinates: (latitude: Double, longitude: Double) {
        switch self {
        case .brussels: (50.85, 4.35)
        case .amsterdam: (52.37, 4.90)
        case .london: (51.51, -0.13)
        case .paris: (48.86, 2.35)
        case .berlin: (52.52, 13.40)
        case .madrid: (40.42, -3.70)
        case .newYork: (40.71, -74.01)
        case .losAngeles: (34.05, -118.24)
        case .sydney: (-33.87, 151.21)
        }
    }

    // NOAA approximation for apparent sunset, converted to the Mac’s time zone.
    func minutes(for date: Date, calendar: Calendar) -> Int? {
        var local = Calendar(identifier: .gregorian)
        local.timeZone = calendar.timeZone
        guard let day = local.ordinality(of: .day, in: .year, for: date),
              let year = local.range(of: .day, in: .year, for: date) else { return nil }
        let angle = 2 * Double.pi * Double(day - 1) / Double(year.count)
        let equation = 229.18 * (0.000075 + 0.001868 * cos(angle) - 0.032077 * sin(angle)
            - 0.014615 * cos(2 * angle) - 0.040849 * sin(2 * angle))
        let declination = 0.006918 - 0.399912 * cos(angle) + 0.070257 * sin(angle)
            - 0.006758 * cos(2 * angle) + 0.000907 * sin(2 * angle)
            - 0.002697 * cos(3 * angle) + 0.00148 * sin(3 * angle)
        let latitude = coordinates.latitude * .pi / 180
        let cosine = cos(90.833 * .pi / 180) / (cos(latitude) * cos(declination))
            - tan(latitude) * tan(declination)
        guard (-1...1).contains(cosine) else { return nil }
        let utcMinutes = 720 - 4 * coordinates.longitude + 4 * acos(cosine) * 180 / .pi - equation
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(secondsFromGMT: 0)!
        guard let midnight = utc.date(from: local.dateComponents([.year, .month, .day], from: date)) else {
            return nil
        }
        let sunset = midnight.addingTimeInterval(utcMinutes.rounded() * 60)
        let time = local.dateComponents([.hour, .minute], from: sunset)
        guard let hour = time.hour, let minute = time.minute else { return nil }
        return hour * 60 + minute
    }
}

@MainActor
final class AutomationSensors {
    private let location = CLLocationManager()

    func requestWiFiAccess() {
        location.requestWhenInUseAuthorization()
    }

    var network: String? { CWWiFiClient.shared().interface()?.ssid() }

    var onBattery: Bool {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let source = IOPSGetProvidingPowerSourceType(snapshot)?.takeUnretainedValue() else { return false }
        return (source as String) == "Battery Power"
    }
}

struct AutomationPanel: View {
    @ObservedObject var model: LogoModel
    @Environment(\.dismiss) private var dismiss
    private var language: Language { model.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Label(language.text("Automatisering"), systemImage: "bolt.circle").font(.title2.bold())
            Toggle(language.text("Uit op batterij"), isOn: $model.batteryOff)
            Divider()
            Toggle(language.text("Uit op wifi"), isOn: $model.wifiOff)
            if model.wifiOff {
                TextField(language.text("Wifinaam"), text: $model.wifiName)
                HStack {
                    Button(language.text("Gebruik huidige wifi")) { model.useCurrentWiFi() }
                    Button(language.text("Geef wifitoegang")) { model.requestWiFiAccess() }
                }
                Text(model.currentWiFi ?? language.text("Wifinaam niet beschikbaar. Sta locatie toe voor LogoLight in Systeeminstellingen."))
                    .font(.callout).foregroundStyle(.secondary)
            }
            Button(language.text("Gereed")) { dismiss() }.keyboardShortcut(.cancelAction)
        }
        .padding(24)
        .frame(width: 450, alignment: .leading)
    }
}
