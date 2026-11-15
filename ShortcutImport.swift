import AppKit
import SwiftUI

enum ShortcutRecipe: String, CaseIterable, Identifiable {
    case on, off, pause15, pause60, pauseTomorrow = "pause-until-tomorrow", resume

    var id: String { rawValue }
    var url: String { "logolicht://" + rawValue }

    var title: String {
        switch self {
        case .on: "Logo aan"
        case .off: "Logo uit"
        case .pause15: "Logo kwartier uit"
        case .pause60: "Filmavond"
        case .pauseTomorrow: "Logo uit tot morgen"
        case .resume: "Logo hervat"
        }
    }

}

struct ShortcutPanel: View {
    let language: Language
    private let statusState = State<String?>(wrappedValue: nil)
    private var status: String? {
        get { statusState.wrappedValue }
        nonmutating set { statusState.wrappedValue = newValue }
    }
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
        VStack(alignment: .leading, spacing: 10) {
            Text(language.text("Opdrachten")).font(.title2.bold())
            Text(language.text("Zo maak je een opdracht"))
                .foregroundStyle(.secondary)
            ForEach(Array(language.shortcutSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .firstTextBaseline, spacing: 9) {
                    Text("\(index + 1).").monospacedDigit().foregroundStyle(.secondary)
                    Text(step).fixedSize(horizontal: false, vertical: true)
                }.font(.callout)
            }
            GroupBox {
                VStack(alignment: .leading, spacing: 7) {
                    Label("1.  URL", systemImage: "link")
                    Text("logolicht://pause60").font(.callout.monospaced()).foregroundStyle(.mint)
                    Image(systemName: "arrow.down").foregroundStyle(.secondary).accessibilityHidden(true)
                    Label(language.text("2.  Open URL’s"), systemImage: "arrow.up.right")
                }.frame(maxWidth: .infinity, alignment: .leading)
            } label: { Text(language.text("Voorbeeld Filmavond")) }
            Divider()
            ForEach(ShortcutRecipe.allCases) { recipe in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(language.text(recipe.title))
                        Text(recipe.url).font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(language.text("Open editor")) { create(recipe) }
                    Button {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(recipe.url, forType: .string)
                        status = language.text("URL gekopieerd")
                    } label: {
                        Label(language.text("Kopieer URL"), systemImage: "doc.on.doc")
                    }
                    .accessibilityLabel(language.text("Kopieer URL"))
                    .help(language.text("Kopieer URL"))
                }
            }
            Button(language.text("Gereed")) { dismiss() }
                .keyboardShortcut(.cancelAction)
            if let status {
                Text(status).font(.callout).foregroundStyle(.secondary).textSelection(.enabled)
            }
        }
        .padding(24)
        }
        .frame(width: 560, height: 650)
    }

    @MainActor
    private func create(_ recipe: ShortcutRecipe) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(recipe.url, forType: .string)
        if NSWorkspace.shared.open(URL(string: "shortcuts://create-shortcut")!) {
            status = language.text("URL gekopieerd") + " · " + language.text(recipe.title)
        } else {
            status = language.text("Opdrachten kon niet worden geopend.")
        }
    }
}
