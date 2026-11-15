import AppKit
import Darwin
import Foundation
import SwiftUI
import ServiceManagement
import Combine

@main
struct LogoLicht: App {
    @NSApplicationDelegateAdaptor(LogoApplicationDelegate.self) private var application
    @StateObject private var model = LogoModel.shared

    var body: some Scene {
        MenuBarExtra {
            LogoMenu(model: model, showWindow: application.showWindow)
        } label: {
            if let countdown = model.countdown {
                Label(countdown, systemImage: model.symbol)
                    .labelStyle(.titleAndIcon)
            } else {
                Image(systemName: model.symbol).accessibilityLabel("LogoLight")
            }
        }
    }
}

@MainActor
final class LogoApplicationDelegate: NSObject, NSApplicationDelegate {
    private var mainWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        showWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        showWindow()
        return false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls { LogoModel.shared.handle(url) }
    }

    func showWindow() {
        let window: NSWindow
        if let mainWindow {
            window = mainWindow
        } else {
            let host = NSHostingController(rootView: LogoView(model: LogoModel.shared))
            window = NSWindow(contentViewController: host)
            window.title = "LogoLight"
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.isRestorable = false
            window.center()
            mainWindow = window
        }
        if window.isMiniaturized { window.deminiaturize(nil) }
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}

struct LogoMenu: View {
    @ObservedObject var model: LogoModel
    let showWindow: () -> Void

    var body: some View {
        Button(model.language.text("Zet aan")) { model.apply(.on) }.disabled(!model.canApply)
        Button(model.language.text("Zet uit")) { model.apply(.off) }.disabled(!model.canApply)
        Menu(model.language.text("Even uit")) {
            Button(model.language.text("15 minuten")) { model.pause(.minutes15) }
            Button(model.language.text("1 uur")) { model.pause(.hour) }
            Button(model.language.text("Tot morgen")) { model.pause(.tomorrow) }
        }.disabled(!model.supported)
        if model.pauseUntil != nil {
            Button(model.language.text("Hervat schema")) { model.resume() }
        }
        Toggle(model.language.text("Aftellen in de menubalk"), isOn: $model.countdownEnabled)
        if let countdown = model.countdown {
            Text(model.language.text("Resterende tijd") + " · " + countdown)
        }
        Text(model.nextLabel)
        Divider()
        Button(model.language.text("Open LogoLight")) { showWindow() }
        Divider()
        Button(model.language.text("Stop LogoLight")) { NSApp.terminate(nil) }
    }
}

struct LogoView: View {
    @ObservedObject var model: LogoModel
    @StateObject private var login = LoginPreference()
    private let showTerms = State(wrappedValue: false)
    private let showAutomation = State(wrappedValue: false)
    private let showShortcuts = State(wrappedValue: false)

    private let mint = Color(red: 0.52, green: 0.96, blue: 0.86)
    private let surface = Color.white.opacity(0.075)
    private var language: Language { model.language }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 15) {
                Image(systemName: "sparkle")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(mint)
                    .shadow(color: mint.opacity(0.7), radius: 10)
                    .frame(width: 58, height: 58)
                    .background(mint.opacity(0.10), in: RoundedRectangle(cornerRadius: 17))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 3) {
                    Text("LogoLight").font(.system(size: 28, weight: .bold))
                    Text(language.text("Verlichting Apple logo")).foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                Picker(language.text("Taal"), selection: $model.language) {
                    ForEach(Language.allCases) { option in Text(option.name).tag(option) }
                }
                .labelsHidden()
                .accessibilityLabel(language.text("Taal"))
                .fixedSize()
                    Button { showTerms.wrappedValue = true } label: {
                        Label(language.text("Gebruiksvoorwaarden"), systemImage: "doc.text")
                    }
                    .buttonStyle(.bordered)
                    .fixedSize()
                    .sheet(isPresented: showTerms.projectedValue) { TermsPanel(language: language) }
                }
            }

            if model.supported {
                VStack(alignment: .leading, spacing: 12) {
                    statusCard
                    HStack(spacing: 10) {
                        actionButton(.on, icon: "lightbulb.fill")
                        actionButton(.off, icon: "lightbulb.slash")
                    }
                    .disabled(!model.canApply)
                    if model.pauseUntil != nil {
                        Button(language.text("Hervat schema")) { model.resume() }
                    }
                    if model.showStatusMessage {
                        Text(language.text(model.status))
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }
                }
                .padding(16)
                .background(surface, in: RoundedRectangle(cornerRadius: 17))
                VStack(alignment: .leading, spacing: 13) {
                    Toggle(language.text("Dagelijks tijdschema"), isOn: $model.enabled)
                        .toggleStyle(.switch)
                        .font(.headline)
                    if model.enabled {
                        Divider()
                        Toggle(language.text("Aan bij zonsondergang"), isOn: $model.sunsetEnabled)
                        if model.sunsetEnabled {
                            Picker(language.text("Stad"), selection: $model.sunsetCity) {
                                ForEach(SunsetCity.allCases) { city in Text(city.name).tag(city) }
                            }
                        }
                        HStack(spacing: 20) {
                            timePicker("Aan om", date: $model.onTime).disabled(model.sunsetEnabled)
                            timePicker("Uit om", date: $model.offTime)
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Toggle(language.text("Apart weekendschema"), isOn: $model.weekendEnabled)
                            if model.weekendEnabled {
                                Toggle(language.text("Weekend altijd uit"), isOn: $model.weekendOff)
                                if !model.weekendOff {
                                    HStack(spacing: 20) {
                                        timePicker("Aan om", date: $model.weekendOnTime).disabled(model.sunsetEnabled)
                                        timePicker("Uit om", date: $model.weekendOffTime)
                                    }
                                }
                            }
                            Divider()
                            Text(language.text("Vandaag")).font(.subheadline.weight(.semibold))
                            timeline
                            Text(model.nextLabel).font(.callout).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(16)
                .background(surface, in: RoundedRectangle(cornerRadius: 17))
                Toggle(language.text("Open LogoLight bij inloggen"), isOn: Binding(
                    get: { login.enabled }, set: { login.set($0) }
                ))
                Text(language.text(login.message ?? "Het schema werkt zolang LogoLight in de menubalk draait."))
                    .font(.callout).foregroundStyle(.secondary)
            } else {
                Text(language.text("Een MacBook Pro met PROLED XDR-display is vereist."))
            }

            if model.supported {
                Button { showAutomation.wrappedValue = true } label: {
                    Label(language.text("Automatisering"), systemImage: "bolt.circle")
                }
                .sheet(isPresented: showAutomation.projectedValue) { AutomationPanel(model: model) }
                Button { showShortcuts.wrappedValue = true } label: {
                    Label(language.text("Opdrachten"), systemImage: "square.on.square")
                }
                .sheet(isPresented: showShortcuts.projectedValue) { ShortcutPanel(language: language) }
            }
            Text(language.text("Gemaakt met behulp van AI door RemeshBE"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
        .tint(mint)
        .fixedSize(horizontal: false, vertical: true)
        .padding(24)
        .frame(width: 490, alignment: .leading)
        .background(LinearGradient(colors: [
            Color(red: 0.15, green: 0.12, blue: 0.26),
            Color(red: 0.07, green: 0.09, blue: 0.16)
        ], startPoint: .topLeading, endPoint: .bottomTrailing))
        .preferredColorScheme(.dark)
        .environment(\.locale, Locale(identifier: language.rawValue))
    }

    private var statusCard: some View {
        let active = model.applied == .on
        let accent = active ? mint : Color.white.opacity(0.64)
        let title = model.applied == nil ? "Stand onbekend" : active ? "Logo aan" : "Logo uit"
        return HStack(spacing: 14) {
            Image(systemName: model.symbol)
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(accent)
                .shadow(color: active ? mint.opacity(0.65) : .clear, radius: 10)
                .frame(width: 52, height: 52)
                .background(accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(language.text("Laatst bevestigde stand"))
                    .font(.caption.weight(.medium)).foregroundStyle(.secondary)
                Text(language.text(title))
                    .font(.system(size: 25, weight: .bold)).foregroundStyle(accent)
            }
            Spacer()
        }
        .padding(14)
        .background(accent.opacity(active ? 0.09 : 0.05), in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(accent.opacity(active ? 0.27 : 0.13)))
        .accessibilityElement(children: .combine)
    }

    private var timeline: some View {
        let ranges = model.today.litRanges
        return VStack(spacing: 5) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.14))
                    ForEach(ranges, id: \.lowerBound) { range in
                        Rectangle().fill(mint)
                            .frame(width: geometry.size.width * CGFloat(range.count) / 1440)
                            .offset(x: geometry.size.width * CGFloat(range.lowerBound) / 1440)
                    }
                }.clipShape(Capsule())
            }.frame(height: 10)
            HStack {
                Text("00:00"); Spacer(); Text("12:00"); Spacer(); Text("24:00")
            }.font(.caption.monospacedDigit()).foregroundStyle(.secondary)
        }
        .accessibilityHidden(true)
    }

    private func actionButton(_ action: LogoAction, icon: String) -> some View {
        Button { model.apply(action) } label: {
            Label(language.text(action == .on ? "Zet aan" : "Zet uit"), systemImage: icon)
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .foregroundStyle(action == .on ? mint : Color.white.opacity(0.88))
    }

    private func timePicker(_ title: String, date: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(language.text(title)).foregroundStyle(.secondary)
            DatePicker(language.text(title), selection: date, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .accessibilityLabel(language.text(title))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

@MainActor
final class LoginPreference: ObservableObject {
    @Published private(set) var enabled = SMAppService.mainApp.status == .enabled
    @Published private(set) var message: String?

    func set(_ value: Bool) {
        do {
            if value {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            let status = SMAppService.mainApp.status
            enabled = status == .enabled
            if status == .requiresApproval {
                message = "Sta LogoLight toe bij Inloggen in Systeeminstellingen."
                SMAppService.openSystemSettingsLoginItems()
            } else {
                message = nil
            }
        } catch {
            enabled = SMAppService.mainApp.status == .enabled
            message = error.localizedDescription
        }
    }
}

@MainActor
final class LogoModel: ObservableObject {
    static let shared = LogoModel()
    enum PauseLength {
        case minutes15, hour, tomorrow
    }

    private static let supportedModels: Set<String> = ["Mac17,10", "Mac17,11", "Mac17,12", "Mac17,13"]
    private let defaults = UserDefaults.standard

    let supported: Bool = {
        var size = 0
        guard sysctlbyname("hw.model", nil, &size, nil, 0) == 0, size > 0 else { return false }
        var buffer = [UInt8](repeating: 0, count: size)
        guard sysctlbyname("hw.model", &buffer, &size, nil, 0) == 0 else { return false }
        return supportedModels.contains(String(decoding: buffer.prefix { $0 != 0 }, as: UTF8.self))
    }()

    @Published var language = Language(rawValue: UserDefaults.standard.string(forKey: "language") ?? "") ?? .nl {
        didSet { defaults.set(language.rawValue, forKey: "language") }
    }
    @Published var enabled: Bool { didSet { saveSchedule() } }
    @Published var onTime: Date { didSet { saveSchedule() } }
    @Published var offTime: Date { didSet { saveSchedule() } }
    @Published var weekendEnabled: Bool { didSet { saveSchedule() } }
    @Published var weekendOff: Bool { didSet { saveSchedule() } }
    @Published var weekendOnTime: Date { didSet { saveSchedule() } }
    @Published var weekendOffTime: Date { didSet { saveSchedule() } }
    @Published private(set) var pauseUntil: Date?
    @Published private(set) var status = "Huidige stand onbekend."
    @Published private(set) var applied: LogoAction?
    @Published private var next: Date?
    @Published private var displayDay = Calendar.autoupdatingCurrent.startOfDay(for: .now)
    @Published private var busy = false

    private var timer: Timer?
    private var wakeObserver: NSObjectProtocol?
    private var zoneObserver: NSObjectProtocol?
    private var scheduledAction: LogoAction?
    private var nextRefresh = Date.distantPast
    private var retryAfter = Date.distantPast
    private var pendingManual: LogoAction?

    @Published var batteryOff = UserDefaults.standard.bool(forKey: "batteryOff") {
        didSet { updateAutomation() }
    }
    @Published var wifiOff = UserDefaults.standard.bool(forKey: "wifiOff") {
        didSet { updateAutomation() }
    }
    @Published var wifiName = UserDefaults.standard.string(forKey: "wifiName") ?? "" {
        didSet { updateAutomation() }
    }
    @Published var sunsetEnabled = UserDefaults.standard.bool(forKey: "sunsetEnabled") {
        didSet { updateAutomation() }
    }
    @Published var sunsetCity = SunsetCity(rawValue: UserDefaults.standard.string(forKey: "sunsetCity") ?? "") ?? .brussels {
        didSet { updateAutomation() }
    }
    @Published var countdownEnabled = UserDefaults.standard.bool(forKey: "countdownEnabled") {
        didSet { updateAutomation() }
    }
    @Published private(set) var currentWiFi: String?
    @Published private(set) var countdown: String?
    @Published private var externalReason: String?
    private lazy var sensors = AutomationSensors()
    private var sunsets: [Date: Int] = [:]
    private var sunsetCacheDate: Date?
    private var lastSensorCheck = Date.distantPast
    private var turnOnAfterWiFi = false

    func requestWiFiAccess() { sensors.requestWiFiAccess() }

    func useCurrentWiFi() {
        if let network = sensors.network {
            wifiName = network
        } else {
            requestWiFiAccess()
        }
    }

    private func updateAutomation() {
        defaults.set(batteryOff, forKey: "batteryOff")
        defaults.set(wifiOff, forKey: "wifiOff")
        defaults.set(wifiName, forKey: "wifiName")
        defaults.set(sunsetEnabled, forKey: "sunsetEnabled")
        defaults.set(sunsetCity.rawValue, forKey: "sunsetCity")
        defaults.set(countdownEnabled, forKey: "countdownEnabled")
        sunsetCacheDate = nil
        nextRefresh = .distantPast
        lastSensorCheck = .distantPast
        retryAfter = .distantPast
        checkSchedule()
    }

    private func refreshSunsets(for day: Date) {
        guard sunsetCacheDate != day else { return }
        sunsetCacheDate = day
        sunsets.removeAll()
        guard sunsetEnabled else { return }
        let calendar = Calendar.autoupdatingCurrent
        for offset in 0...9 {
            if let date = calendar.date(byAdding: .day, value: offset, to: day),
               let minute = sunsetCity.minutes(for: date, calendar: calendar) {
                sunsets[date] = minute
            }
        }
    }

    private func refreshSensors(at now: Date) {
        guard now.timeIntervalSince(lastSensorCheck) >= 4 else { return }
        lastSensorCheck = now
        let network = wifiOff ? sensors.network : nil
        if currentWiFi != network { currentWiFi = network }
        let matches = wifiOff && !wifiName.isEmpty && network == wifiName
        if matches {
            turnOnAfterWiFi = false
        } else if wifiOff, externalReason == "Uit op wifi" {
            turnOnAfterWiFi = true
        } else if !wifiOff {
            turnOnAfterWiFi = false
        }
        let reason = matches ? "Uit op wifi" : batteryOff && sensors.onBattery ? "Uit op batterij" : nil
        guard reason != externalReason else { return }
        if reason != nil && externalReason == nil && defaults.string(forKey: "beforeExternal") == nil {
            let before = defaults.string(forKey: "beforePause") ?? applied?.rawValue ?? LogoAction.on.rawValue
            defaults.set(before, forKey: "beforeExternal")
        }
        externalReason = reason
        scheduledAction = nil
        retryAfter = .distantPast
    }

    private func refreshCountdown(at now: Date) {
        let label: String?
        if countdownEnabled,
           let end = pauseUntil, end > now {
            let minutes = Int(ceil(end.timeIntervalSince(now) / 60))
            label = minutes >= 60 ? "\(minutes / 60)h \(minutes % 60)m" : "\(minutes)m"
        } else {
            label = nil
        }
        if label != countdown { countdown = label }
    }

    var canApply: Bool { supported && !busy }

    var showStatusMessage: Bool {
        switch status {
        case "Huidige stand onbekend.", "Verlichting ingeschakeld.", "Verlichting uitgeschakeld.": false
        default: true
        }
    }

    var symbol: String {
        switch applied {
        case .on: "lightbulb.fill"
        case .off: "lightbulb.slash"
        case nil: "lightbulb"
        }
    }

    var today: DailyPlan { plan.plan(at: displayDay) }

    var nextLabel: String {
        if let externalReason { return language.text(externalReason) }
        guard let date = pauseUntil ?? next else { return language.text("Geen volgende wijziging") }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.rawValue)
        formatter.doesRelativeDateFormatting = true
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let title = pauseUntil == nil ? "Volgende wijziging" : "Tijdelijk uit tot"
        return language.text(title) + " · " + formatter.string(from: date)
    }

    private var plan: WeeklyPlan {
        WeeklyPlan(
            weekday: DailyPlan(on: minutes(onTime), off: minutes(offTime)),
            weekend: weekendEnabled
                ? DailyPlan(on: minutes(weekendOnTime), off: minutes(weekendOffTime), allOff: weekendOff)
                : nil,
            sunsetByDay: sunsets
        )
    }

    init() {
        enabled = defaults.bool(forKey: "scheduleEnabled")
        onTime = Self.time(defaults.object(forKey: "scheduleOn") as? Int ?? 480)
        offTime = Self.time(defaults.object(forKey: "scheduleOff") as? Int ?? 1380)
        weekendEnabled = defaults.bool(forKey: "weekendEnabled")
        weekendOff = defaults.bool(forKey: "weekendOff")
        weekendOnTime = Self.time(defaults.object(forKey: "weekendOn") as? Int ?? 600)
        weekendOffTime = Self.time(defaults.object(forKey: "weekendOffTime") as? Int ?? 1380)
        pauseUntil = defaults.object(forKey: "pauseUntil") as? Date
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.checkSchedule() }
        }
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.nextRefresh = .distantPast
                self?.lastSensorCheck = .distantPast
                self?.checkSchedule()
            }
        }
        zoneObserver = NotificationCenter.default.addObserver(
            forName: .NSSystemTimeZoneDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.reloadTimes() }
        }
        checkSchedule()
    }

    private static func time(_ minutes: Int) -> Date {
        Calendar.autoupdatingCurrent.date(bySettingHour: minutes / 60, minute: minutes % 60,
            second: 0, of: Date()) ?? Date()
    }

    private func minutes(_ date: Date) -> Int {
        let time = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: date)
        return (time.hour ?? 0) * 60 + (time.minute ?? 0)
    }

    private var reloading = false

    private func reloadTimes() {
        sunsetCacheDate = nil
        reloading = true
        onTime = Self.time(defaults.object(forKey: "scheduleOn") as? Int ?? 480)
        offTime = Self.time(defaults.object(forKey: "scheduleOff") as? Int ?? 1380)
        weekendOnTime = Self.time(defaults.object(forKey: "weekendOn") as? Int ?? 600)
        weekendOffTime = Self.time(defaults.object(forKey: "weekendOffTime") as? Int ?? 1380)
        reloading = false
        nextRefresh = .distantPast
        checkSchedule()
    }

    private func saveSchedule() {
        guard !reloading else { return }
        defaults.set(enabled, forKey: "scheduleEnabled")
        defaults.set(minutes(onTime), forKey: "scheduleOn")
        defaults.set(minutes(offTime), forKey: "scheduleOff")
        defaults.set(weekendEnabled, forKey: "weekendEnabled")
        defaults.set(weekendOff, forKey: "weekendOff")
        defaults.set(minutes(weekendOnTime), forKey: "weekendOn")
        defaults.set(minutes(weekendOffTime), forKey: "weekendOffTime")
        scheduledAction = nil
        nextRefresh = .distantPast
        retryAfter = .distantPast
        checkSchedule()
    }

    func pause(_ length: PauseLength) {
        guard supported else { return }
        let now = Date()
        let calendar = Calendar.autoupdatingCurrent
        let until: Date
        switch length {
        case .minutes15: until = now.addingTimeInterval(900)
        case .hour: until = now.addingTimeInterval(3600)
        case .tomorrow:
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else { return }
            until = tomorrow
        }
        if pauseUntil == nil {
            defaults.set(defaults.string(forKey: "beforeExternal") ?? applied?.rawValue ?? LogoAction.on.rawValue, forKey: "beforePause")
        }
        pauseUntil = until
        defaults.set(until, forKey: "pauseUntil")
        pendingManual = nil
        retryAfter = .distantPast
        checkSchedule()
    }

    func resume() {
        let before = defaults.string(forKey: "beforePause").flatMap(LogoAction.init(rawValue:))
        clearPause()
        scheduledAction = nil
        retryAfter = .distantPast
        if !enabled, !turnOnAfterWiFi { pendingManual = before ?? .on }
        checkSchedule()
    }

    private func clearPause() {
        pauseUntil = nil
        defaults.removeObject(forKey: "pauseUntil")
        defaults.removeObject(forKey: "beforePause")
    }

    private func checkSchedule() {
        guard supported, !busy else { return }
        let now = Date()
        let day = Calendar.autoupdatingCurrent.startOfDay(for: now)
        if displayDay != day { displayDay = day }
        refreshSunsets(for: day)
        refreshSensors(at: now)
        if let end = pauseUntil, now >= end {
            resume()
            return
        }
        let weekly = plan
        if enabled, now >= nextRefresh {
            next = weekly.nextChange(after: now)
            nextRefresh = next ?? now.addingTimeInterval(3600)
        } else if !enabled, next != nil {
            next = nil
        }

        refreshCountdown(at: now)
        if externalReason != nil {
            if applied != .off, now >= retryAfter { sendScheduled(.off) }
            return
        }
        if let previous = defaults.string(forKey: "beforeExternal") {
            defaults.removeObject(forKey: "beforeExternal")
            if !enabled, !turnOnAfterWiFi, pauseUntil == nil, pendingManual == nil {
                pendingManual = LogoAction(rawValue: previous)
            }
        }

        if turnOnAfterWiFi, pauseUntil == nil, now >= retryAfter {
            let target: LogoAction = weekly.isOn(at: now) ? .on : .off
            send(.on) { [weak self] success in
                guard let self else { return }
                if success {
                    self.turnOnAfterWiFi = false
                    if self.enabled { self.scheduledAction = target }
                } else {
                    self.retryAfter = Date().addingTimeInterval(60)
                }
            }
            return
        }

        if let manual = pendingManual {
            pendingManual = nil
            send(manual)
            return
        }

        guard now >= retryAfter else { return }
        if pauseUntil != nil {
            if applied != .off { sendScheduled(.off) }
        } else if enabled {
            let target: LogoAction = weekly.isOn(at: now) ? .on : .off
            if scheduledAction != target { sendScheduled(target) }
        }
    }

    private func sendScheduled(_ command: LogoAction) {
        send(command) { [weak self] success in
            guard let self else { return }
            if success, self.externalReason == nil, self.pauseUntil == nil, self.pendingManual == nil, self.enabled,
               self.plan.isOn(at: .now) == (command == .on) {
                self.scheduledAction = command
            } else if !success {
                self.retryAfter = Date().addingTimeInterval(60)
            }
        }
    }

    func apply(_ action: LogoAction) {
        guard supported else { return }
        refreshSensors(at: .now)
        if action == .on, let externalReason {
            status = externalReason
            return
        }
        clearPause()
        if enabled { scheduledAction = plan.isOn(at: .now) ? .on : .off }
        pendingManual = action
        checkSchedule()
    }

    func handle(_ url: URL) {
        guard url.scheme == "logolicht", url.path.isEmpty, url.query == nil, url.fragment == nil else { return }
        switch url.host {
        case "on": apply(.on)
        case "off": apply(.off)
        case "pause15": pause(.minutes15)
        case "pause60": pause(.hour)
        case "pause-until-tomorrow": pause(.tomorrow)
        case "resume": resume()
        default: break
        }
    }

    private func send(_ action: LogoAction, completion: ((Bool) -> Void)? = nil) {
        busy = true
        status = "Bezig…"
        let connection = NSXPCConnection(machServiceName: logoServiceName, options: .privileged)
        connection.remoteObjectInterface = NSXPCInterface(with: LogoControl.self)
        connection.resume()

        var finished = false
        let finish: (String?) -> Void = { [weak self] error in
            DispatchQueue.main.async {
                guard !finished else { return }
                finished = true
                connection.invalidate()
                if error == nil { self?.applied = action }
                self?.status = error ?? (action == .on ? "Verlichting ingeschakeld." : "Verlichting uitgeschakeld.")
                self?.busy = false
                completion?(error == nil)
                self?.checkSchedule()
            }
        }
        guard let proxy = connection.remoteObjectProxyWithErrorHandler({ _ in
            finish("De logodienst is niet bereikbaar. Installeer LogoLight opnieuw.")
        }) as? LogoControl else {
            finish("De logodienst is niet bereikbaar.")
            return
        }
        proxy.apply(action.rawValue, reply: finish)
    }
}
