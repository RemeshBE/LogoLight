import Foundation

enum Language: String, CaseIterable, Identifiable {
    case nl, en, fr, de, es

    var id: String { rawValue }
    var name: String {
        switch self {
        case .nl: "Nederlands"
        case .en: "English"
        case .fr: "Français"
        case .de: "Deutsch"
        case .es: "Español"
        }
    }

    func text(_ dutch: String) -> String {
        guard self != .nl else { return dutch }
        return Self.translations[dutch]?[Self.allCases.firstIndex(of: self)! - 1] ?? dutch
    }

    private static let translations: [String: [String]] = [
        "Resterende tijd": ["Time remaining", "Temps restant", "Verbleibende Zeit", "Tiempo restante"],
        "Open LogoLight": ["Open LogoLight", "Ouvrir LogoLight", "LogoLight öffnen", "Abrir LogoLight"],
        "Automatisering": ["Automation", "Automatisation", "Automatisierung", "Automatización"],
        "Uit op batterij": ["Off on battery", "Éteint sur batterie", "Aus im Akkubetrieb", "Apagado con batería"],
        "Aftellen in de menubalk": ["Countdown in the menu bar", "Compte à rebours dans la barre des menus", "Countdown in der Menüleiste", "Cuenta atrás en la barra de menús"],
        "Uit op wifi": ["Off on Wi-Fi", "Éteint sur ce Wi-Fi", "Aus in diesem WLAN", "Apagado en esta red wifi"],
        "Wifinaam": ["Wi-Fi network name", "Nom du réseau Wi-Fi", "WLAN-Name", "Nombre de la red wifi"],
        "Gebruik huidige wifi": ["Use current Wi-Fi", "Utiliser le Wi-Fi actuel", "Aktuelles WLAN verwenden", "Usar la red actual"],
        "Geef wifitoegang": ["Allow Wi-Fi detection", "Autoriser la détection Wi-Fi", "WLAN-Erkennung erlauben", "Permitir detección wifi"],
        "Wifinaam niet beschikbaar. Sta locatie toe voor LogoLight in Systeeminstellingen.": ["Wi-Fi name unavailable. Check your connection and allow location access for LogoLight in System Settings.", "Nom du Wi-Fi indisponible. Vérifiez la connexion et autorisez la localisation pour LogoLight dans Réglages Système.", "WLAN-Name nicht verfügbar. Prüfe die Verbindung und erlaube LogoLight den Standortzugriff in den Systemeinstellungen.", "Nombre wifi no disponible. Comprueba la conexión y permite el acceso a la ubicación para LogoLight en Ajustes del Sistema."],
        "Aan bij zonsondergang": ["On at sunset", "Allumer au coucher du soleil", "An bei Sonnenuntergang", "Encender al atardecer"],
        "Stad": ["City", "Ville", "Stadt", "Ciudad"],
        "Laatst bevestigde stand": ["Last confirmed setting", "Dernier réglage confirmé", "Zuletzt bestätigte Einstellung", "Último ajuste confirmado"],
        "Stand onbekend": ["State unknown", "État inconnu", "Status unbekannt", "Estado desconocido"],
        "Gebruiksvoorwaarden": ["Terms of Use", "Conditions d’utilisation", "Nutzungsbedingungen", "Condiciones de uso"],
        "Voorbeeld Filmavond": ["Movie Night example", "Exemple Soirée cinéma", "Beispiel Filmabend", "Ejemplo Noche de cine"],
        "2.  Open URL’s": ["2.  Open URLs", "2.  Ouvrir les URL", "2.  URLs öffnen", "2.  Abrir URL"],
        "Zo maak je een opdracht": ["Create a shortcut", "Créer un raccourci", "Kurzbefehl erstellen", "Crear un atajo"],
        "Open editor": ["Open editor", "Ouvrir l’éditeur", "Editor öffnen", "Abrir editor"],
        "Kies een naam en open de editor. Voeg URL en Open URL’s toe.": ["Choose a name and open the editor. Add URL and Open URLs.", "Choisissez un nom et ouvrez l’éditeur. Ajoutez URL et Ouvrir les URL.", "Wähle einen Namen und öffne den Editor. Füge URL und URLs öffnen hinzu.", "Elige un nombre y abre el editor. Añade URL y Abrir URL."],
        "Logo aan": ["Logo On", "Allume logo", "Logo an", "Enciende logo"],
        "Logo uit": ["Logo Off", "Éteins logo", "Logo aus", "Apaga logo"],
        "Logo kwartier uit": ["Logo Pause", "Pause logo", "Logo Pause", "Pausa logo"],
        "Logo uit tot morgen": ["Logo Off Until Tomorrow", "Logo éteint jusqu’à demain", "Logo aus bis morgen", "Logo apagado hasta mañana"],
        "Logo hervat": ["Logo Resume", "Reprends logo", "Logo fortsetzen", "Reanuda logo"],
        "Gereed": ["Done", "Terminé", "Fertig", "Listo"],
        "Opdrachten": ["Shortcuts", "Raccourcis", "Kurzbefehle", "Atajos"],
        "Maak opdrachten…": ["Create shortcuts…", "Créer des raccourcis…", "Kurzbefehle erstellen…", "Crear atajos…"],
        "Maak opdracht": ["Create shortcut", "Créer le raccourci", "Kurzbefehl erstellen", "Crear atajo"],
        "Kies een opdracht en bevestig de import in Opdrachten.": ["Choose a shortcut and confirm the import in Shortcuts.", "Choisissez un raccourci et confirmez l’importation dans Raccourcis.", "Wähle einen Kurzbefehl und bestätige den Import in Kurzbefehle.", "Elige un atajo y confirma la importación en Atajos."],
        "Even uit · 15 minuten": ["Pause lighting · 15 minutes", "Éteindre · 15 minutes", "Licht aus · 15 Minuten", "Apagar · 15 minutos"],
        "Even uit · Tot morgen": ["Pause lighting · Until tomorrow", "Éteindre · Jusqu’à demain", "Licht aus · Bis morgen", "Apagar · Hasta mañana"],
        "Filmavond": ["Movie night", "Soirée cinéma", "Filmabend", "Noche de cine"],
        "Kopieer URL": ["Copy URL", "Copier l’URL", "URL kopieren", "Copiar URL"],
        "URL gekopieerd": ["URL copied", "URL copiée", "URL kopiert", "URL copiada"],
        "Opdrachten kon niet worden geopend.": ["Could not open Shortcuts.", "Impossible d’ouvrir Raccourcis.", "Kurzbefehle konnte nicht geöffnet werden.", "No se pudo abrir Atajos."],
        "Even uit": ["Pause lighting", "Éteindre temporairement", "Vorübergehend aus", "Apagar temporalmente"],
        "15 minuten": ["15 minutes", "15 minutes", "15 Minuten", "15 minutos"],
        "1 uur": ["1 hour", "1 heure", "1 Stunde", "1 hora"],
        "Tot morgen": ["Until tomorrow", "Jusqu’à demain", "Bis morgen", "Hasta mañana"],
        "Hervat schema": ["Resume schedule", "Reprendre la programmation", "Zeitplan fortsetzen", "Reanudar horario"],
        "Apart weekendschema": ["Separate weekend schedule", "Programmation distincte le week-end", "Eigener Wochenendzeitplan", "Horario distinto el fin de semana"],
        "Weekend altijd uit": ["Always off on weekends", "Toujours éteint le week-end", "Am Wochenende immer aus", "Siempre apagado el fin de semana"],
        "Vandaag": ["Today", "Aujourd’hui", "Heute", "Hoy"],
        "Volgende wijziging": ["Next change", "Prochain changement", "Nächste Änderung", "Próximo cambio"],
        "Geen volgende wijziging": ["No upcoming change", "Aucun changement prévu", "Keine Änderung geplant", "Sin cambios previstos"],
        "Tijdelijk uit tot": ["Paused until", "Éteint jusqu’à", "Aus bis", "Apagado hasta"],
        "Zet aan": ["Turn on", "Allumer", "Einschalten", "Encender"],
        "Zet uit": ["Turn off", "Éteindre", "Ausschalten", "Apagar"],
        "Tijdschema…": ["Schedule…", "Programmation…", "Zeitplan…", "Horario…"],
        "Stop LogoLight": ["Quit LogoLight", "Quitter LogoLight", "LogoLight beenden", "Salir de LogoLight"],
        "Verlichting Apple logo": ["Apple logo lighting", "Éclairage du logo Apple", "Apple-Logobeleuchtung", "Iluminación del logotipo de Apple"],
        "Handmatige bediening": ["Manual controls", "Commandes manuelles", "Manuelle Steuerung", "Control manual"],
        "Dagelijks tijdschema": ["Daily schedule", "Programmation quotidienne", "Täglicher Zeitplan", "Horario diario"],
        "Aan om": ["On at", "Allumer à", "An um", "Encender a las"],
        "Uit om": ["Off at", "Éteindre à", "Aus um", "Apagar a las"],
        "Open LogoLight bij inloggen": ["Open LogoLight at login", "Ouvrir LogoLight à la connexion", "LogoLight bei Anmeldung öffnen", "Abrir LogoLight al iniciar sesión"],
        "Het schema werkt zolang LogoLight in de menubalk draait.": ["The schedule runs while LogoLight is in the menu bar.", "La programmation fonctionne tant que LogoLight est dans la barre des menus.", "Der Zeitplan läuft, solange LogoLight in der Menüleiste aktiv ist.", "El horario funciona mientras LogoLight esté en la barra de menús."],
        "Een MacBook Pro met PROLED XDR-display is vereist.": ["Requires a MacBook Pro with a PROLED XDR display.", "Nécessite un MacBook Pro avec écran PROLED XDR.", "Erfordert ein MacBook Pro mit PROLED XDR Display.", "Requiere un MacBook Pro con pantalla PROLED XDR."],
        "Taal": ["Language", "Langue", "Sprache", "Idioma"],
        "Gemaakt met behulp van AI door RemeshBE": ["Made with the help of AI by RemeshBE", "Créé avec l’aide de l’IA par RemeshBE", "Mit KI-Unterstützung erstellt von RemeshBE", "Creado con ayuda de IA por RemeshBE"],
        "Huidige stand onbekend.": ["Current state unknown.", "État actuel inconnu.", "Aktueller Zustand unbekannt.", "Estado actual desconocido."],
        "Kies verschillende tijden voor aan en uit.": ["Choose different on and off times.", "Choisissez des heures différentes pour l’allumage et l’extinction.", "Wähle unterschiedliche Ein- und Ausschaltzeiten.", "Elige horas distintas para encender y apagar."],
        "Bezig…": ["Working…", "En cours…", "Bitte warten…", "En curso…"],
        "Verlichting ingeschakeld.": ["Lighting enabled.", "Éclairage activé.", "Beleuchtung eingeschaltet.", "Iluminación activada."],
        "Verlichting uitgeschakeld.": ["Lighting disabled.", "Éclairage désactivé.", "Beleuchtung ausgeschaltet.", "Iluminación desactivada."],
        "De logodienst is niet bereikbaar.": ["The logo service is unavailable.", "Le service d’éclairage est indisponible.", "Der Logodienst ist nicht erreichbar.", "El servicio de iluminación no está disponible."],
        "De logodienst is niet bereikbaar. Installeer LogoLight opnieuw.": ["The logo service is unavailable. Reinstall LogoLight.", "Le service d’éclairage est indisponible. Réinstallez LogoLight.", "Der Logodienst ist nicht erreichbar. Installiere LogoLight erneut.", "El servicio de iluminación no está disponible. Reinstala LogoLight."],
        "Sta LogoLight toe bij Inloggen in Systeeminstellingen.": ["Allow LogoLight under Login Items in System Settings.", "Autorisez LogoLight dans Ouverture dans Réglages Système.", "Erlaube LogoLight unter Anmeldeobjekte in den Systemeinstellungen.", "Permite LogoLight en Ítems de inicio en Ajustes del Sistema."]
    ]
}

extension Language {
    var shortcutSteps: [String] {
        switch self {
        case .nl:
            [
                "Kies hieronder een opdracht, bijvoorbeeld Filmavond. Klik op Open editor. LogoLight opent een lege opdracht en kopieert de URL.",
                "Klik bovenaan op de naam van de nieuwe opdracht en verander die in Filmavond.",
                "Zoek rechts naar URL en voeg de actie URL toe. Klik in het URL-veld en plak met ⌘V.",
                "Zoek naar Open URL’s en voeg die actie direct onder URL toe. Controleer of de tweede actie het blauwe blokje URL gebruikt.",
                "Klik rechtsboven in Opdrachten op de afspeelknop ▶. Klik daarna op het LogoLight-lampje in de menubalk. Bij Filmavond zie je Tijdelijk uit tot met de eindtijd."
            ]
        case .en:
            [
                "Choose a shortcut below, such as Movie night. Click Open editor. LogoLight opens a blank shortcut and copies its URL.",
                "Click the new shortcut’s name at the top and change it to Movie night.",
                "Search for URL on the right and add the URL action. Click its URL field and paste with ⌘V.",
                "Search for Open URLs and add it directly below URL. Check that the second action uses the blue URL token.",
                "Click the play button ▶ in the top-right corner of Shortcuts. Then click the LogoLight bulb in the menu bar. For Movie night, Paused until shows the end time."
            ]
        case .fr:
            [
                "Choisissez un raccourci ci-dessous, par exemple Soirée cinéma. Cliquez sur Ouvrir l’éditeur. LogoLight ouvre un raccourci vide et copie son URL.",
                "Cliquez sur le nom du nouveau raccourci en haut et renommez-le Soirée cinéma.",
                "À droite, recherchez URL et ajoutez l’action URL. Cliquez dans son champ URL et collez avec ⌘V.",
                "Recherchez Ouvrir les URL et ajoutez cette action juste sous URL. Vérifiez que la seconde action utilise le bloc bleu URL.",
                "Cliquez sur le bouton de lecture ▶ en haut à droite dans Raccourcis. Cliquez ensuite sur l’ampoule LogoLight dans la barre des menus. Pour Soirée cinéma, Éteint jusqu’à indique l’heure de fin."
            ]
        case .de:
            [
                "Wähle unten einen Kurzbefehl aus, etwa Filmabend. Klicke auf Editor öffnen. LogoLight öffnet einen leeren Kurzbefehl und kopiert die URL.",
                "Klicke oben auf den Namen des neuen Kurzbefehls und benenne ihn in Filmabend um.",
                "Suche rechts nach URL und füge die Aktion URL hinzu. Klicke in das URL-Feld und füge die Adresse mit ⌘V ein.",
                "Suche nach URLs öffnen und füge die Aktion direkt unter URL ein. Prüfe, ob die zweite Aktion den blauen URL-Baustein verwendet.",
                "Klicke in Kurzbefehle oben rechts auf die Wiedergabetaste ▶. Klicke dann auf die LogoLight-Lampe in der Menüleiste. Bei Filmabend zeigt Aus bis die Endzeit."
            ]
        case .es:
            [
                "Elige un atajo de la lista, por ejemplo Noche de cine. Haz clic en Abrir editor. LogoLight abre un atajo vacío y copia su URL.",
                "Haz clic en el nombre del nuevo atajo en la parte superior y cámbialo a Noche de cine.",
                "Busca URL a la derecha y añade la acción URL. Haz clic en su campo URL y pega con ⌘V.",
                "Busca Abrir URL y añade la acción justo debajo de URL. Comprueba que la segunda acción use el bloque azul URL.",
                "Haz clic en el botón de reproducción ▶ arriba a la derecha en Atajos. Luego haz clic en la bombilla de LogoLight en la barra de menús. Para Noche de cine, Apagado hasta muestra la hora de finalización."
            ]
        }
    }
}
