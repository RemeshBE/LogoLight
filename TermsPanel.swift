import SwiftUI

struct TermsPanel: View {
    let language: Language
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(language.text("Gebruiksvoorwaarden"), systemImage: "doc.text")
                .font(.title2.bold())
                .accessibilityAddTraits(.isHeader)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                        VStack(alignment: .leading, spacing: 5) {
                            Text(section.0).font(.headline).accessibilityAddTraits(.isHeader)
                            Text(section.1).foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            }
            Divider()
            HStack {
                Spacer()
                Button(language.text("Gereed")) { dismiss() }.keyboardShortcut(.cancelAction)
            }
        }
        .padding(24)
        .frame(width: 490, height: 465)
    }

    private var sections: [(String, String)] {
        switch language {
        case .nl:
            [
                ("Waarvoor dient LogoLight?", "LogoLight bedient de verlichting van het Apple-logo op ondersteunde MacBook Pro-modellen met PROLED XDR-display. LogoLight is onafhankelijk van Apple."),
                ("Installatie en bediening", "De installatie vraagt om beheerdersrechten voor de logodienst. De instelling voor de verlichting geldt voor alle gebruikers van deze Mac. Het tijdschema werkt zolang LogoLight in de menubalk draait."),
                ("Instellingen en privacy", "Je taal, schema, wifinaam en eventuele pauze worden lokaal op je Mac bewaard. Voor de logobediening is geen account of internetverbinding nodig."),
                ("Gebruik op eigen risico", "Gebruik LogoLight op eigen risico. Voor zover de wet dat toestaat, is de maker niet verantwoordelijk voor schade door het gebruik van de app. Je wettelijke rechten blijven gelden.")
            ]
        case .en:
            [
                ("What LogoLight does", "LogoLight controls the illuminated Apple logo on supported MacBook Pro models with a PROLED XDR display. LogoLight is independent of Apple."),
                ("Installation and controls", "Installation requires administrator permission for the lighting service. The lighting setting applies to all users of this Mac. The schedule runs while LogoLight is active in the menu bar."),
                ("Settings and privacy", "Your language, schedule, Wi-Fi network name and any pause are stored locally on your Mac. Controlling the logo requires no account or internet connection."),
                ("Use at your own risk", "Use LogoLight at your own risk. To the extent permitted by law, the developer is not responsible for damage caused by use of the app. Your statutory rights still apply.")
            ]
        case .fr:
            [
                ("À quoi sert LogoLight ?", "LogoLight contrôle l’éclairage du logo Apple sur les MacBook Pro compatibles avec écran PROLED XDR. LogoLight est indépendant d’Apple."),
                ("Installation et utilisation", "L’installation demande des droits d’administration pour le service d’éclairage. Le réglage s’applique à tous les utilisateurs du Mac. La programmation fonctionne tant que LogoLight est actif dans la barre des menus."),
                ("Réglages et confidentialité", "Votre langue, votre programmation, le nom du réseau Wi-Fi et la pause éventuelle sont enregistrées sur votre Mac. Le contrôle du logo ne nécessite ni compte ni connexion Internet."),
                ("Utilisation à vos propres risques", "Utilisez LogoLight à vos propres risques. Dans la mesure permise par la loi, le développeur n’est pas responsable des dommages résultant de l’utilisation de l’application. Vos droits légaux restent applicables.")
            ]
        case .de:
            [
                ("Was LogoLight macht", "LogoLight steuert die Beleuchtung des Apple-Logos auf unterstützten MacBook-Pro-Modellen mit PROLED-XDR-Display. LogoLight ist unabhängig von Apple."),
                ("Installation und Bedienung", "Für die Installation des Beleuchtungsdiensts sind Administratorrechte erforderlich. Die Beleuchtungseinstellung gilt für alle Benutzer dieses Macs. Der Zeitplan läuft, solange LogoLight in der Menüleiste aktiv ist."),
                ("Einstellungen und Datenschutz", "Sprache, Zeitplan, WLAN-Name und eine eventuelle Pause werden lokal auf deinem Mac gespeichert. Für die Steuerung des Logos sind weder ein Konto noch eine Internetverbindung nötig."),
                ("Nutzung auf eigenes Risiko", "Nutze LogoLight auf eigenes Risiko. Soweit gesetzlich zulässig, haftet der Entwickler nicht für Schäden durch die Nutzung der App. Deine gesetzlichen Rechte bleiben bestehen.")
            ]
        case .es:
            [
                ("Para qué sirve LogoLight", "LogoLight controla la iluminación del logotipo de Apple en modelos compatibles de MacBook Pro con pantalla PROLED XDR. LogoLight es independiente de Apple."),
                ("Instalación y uso", "La instalación requiere permisos de administrador para el servicio de iluminación. El ajuste se aplica a todos los usuarios del Mac. El horario funciona mientras LogoLight esté activo en la barra de menús."),
                ("Ajustes y privacidad", "El idioma, el horario, el nombre de la red wifi y las pausas se guardan localmente en tu Mac. Controlar el logotipo no requiere una cuenta ni conexión a internet."),
                ("Uso bajo tu responsabilidad", "Usa LogoLight bajo tu propia responsabilidad. En la medida en que lo permita la ley, el desarrollador no se hace responsable de los daños derivados del uso de la app. Tus derechos legales siguen vigentes.")
            ]
        }
    }
}
