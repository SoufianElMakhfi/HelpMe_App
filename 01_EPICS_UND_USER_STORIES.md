# 📋 HelpMe – Epics & User Stories (Backlog)

> Alle Features strukturiert als Epics mit User Stories, Akzeptanzkriterien und Prioritäten.

---

## Priorisierungs-Legende

| Label | Bedeutung |
|---|---|
| 🔴 **Must Have** | MVP-kritisch, ohne geht kein Launch |
| 🟡 **Should Have** | Wichtig für Wettbewerbsfähigkeit, zeitnah nach MVP |
| 🟢 **Nice to Have** | Differenzierung, kann iterativ nachgeliefert werden |

---

## Epic 1: Authentifizierung & Onboarding 🔴

> **Ziel**: Nutzer können sich registrieren, anmelden und ihre Rolle (Kunde/Handwerker) wählen.

### Story 1.1: Supabase & Auth Setup
**Als** Entwickler,
**möchte ich** eine vollständige Auth-Infrastruktur mit Supabase aufsetzen,
**damit** Nutzer sich sicher registrieren und anmelden können.

**Akzeptanzkriterien:**
- [ ] PostgreSQL-Datenbank ist aufgesetzt und erreichbar
- [ ] Tabelle `profiles` existiert mit Spalte `role` (Enum: `customer`, `pro`)
- [ ] E-Mail + Passwort-Registrierung funktioniert
- [ ] Social Login (Google, Apple) ist implementiert
- [ ] JWT-basierte Session-Verwaltung ist aktiv
- [ ] Row Level Security (RLS) Policies sind konfiguriert

**Story Points:** 5
**Abhängigkeiten:** Keine

---

### Story 1.2: Split-Screen Onboarding
**Als** neuer Nutzer,
**möchte ich** beim ersten Öffnen klar zwischen „Ich brauche Hilfe" und „Ich biete Handwerk" wählen können,
**damit** ich sofort in den richtigen Bereich geleitet werde.

**Akzeptanzkriterien:**
- [ ] Vollbild UI mit zwei großen Cards (vertikal gestackt)
- [ ] Oben: „Ich brauche Hilfe" mit Kunden-Illustration
- [ ] Unten: „Ich biete Handwerk" mit Handwerker-Illustration
- [ ] Marker-Effekt auf Headlines (Construction Color)
- [ ] Smooth Animation beim Auswählen (Rive/Lottie)
- [ ] Nach Auswahl wird `role` im Profil gespeichert
- [ ] Weiterleitung zum rollenspezifischen Dashboard

**Story Points:** 3
**Abhängigkeiten:** Story 1.1

---

### Story 1.3: Handwerker-Profil-Verifizierung
**Als** Handwerker,
**möchte ich** meine Qualifikationen und Gewerbedokumente hochladen können,
**damit** Kunden mir vertrauen und ich das Verifizierungs-Badge erhalte.

**Akzeptanzkriterien:**
- [ ] Upload-Formular für: Meisterbrief, Gewerbeschein, Personalausweis
- [ ] Datei-Vorschau nach Upload
- [ ] Status-Tracking: „Eingereicht" → „In Prüfung" → „Verifiziert" / „Abgelehnt"
- [ ] Badge-System UI: Meister-Garantie-Badge, Gewerbe-Check-Badge
- [ ] Badges werden auf dem öffentlichen Profil angezeigt
- [ ] Admin-Interface für manuelle Prüfung (Phase 1: manuell, später KI-gestützt)
- [ ] Benachrichtigung bei Status-Änderung (Push + E-Mail)

**Story Points:** 8
**Abhängigkeiten:** Story 1.1

---

### Story 1.4: Handwerker-Profil-Seite
**Als** Kunde,
**möchte ich** ein detailliertes Profil jedes Handwerkers sehen können,
**damit** ich eine informierte Entscheidung treffen kann.

**Akzeptanzkriterien:**
- [ ] Profilbild, Name, Betriebsname
- [ ] Verifizierungs-Badges prominent sichtbar
- [ ] Gewerke / Fachgebiete als Tags
- [ ] Bewertungsdurchschnitt + Anzahl Bewertungen
- [ ] Galerie bisheriger Arbeiten (Vorher/Nachher)
- [ ] Verfügbarkeitskalender (optional Phase 1)
- [ ] Entfernung zum eigenen Standort
- [ ] „Anfrage senden"-Button

**Story Points:** 5
**Abhängigkeiten:** Story 1.3

---

## Epic 2: Projekt-Erstellung & KI-Analyse 🔴

> **Ziel**: Kunden können Projekte erstellen, Fotos hochladen und erhalten eine KI-gestützte Analyse.

### Story 2.1: Projekt anlegen (Basis)
**Als** Kunde,
**möchte ich** ein neues Projekt mit Beschreibung, Kategorie und Fotos anlegen können,
**damit** Handwerker mein Problem verstehen und ein Angebot abgeben können.

**Akzeptanzkriterien:**
- [ ] Mehrstufiges Formular (Wizard): Kategorie → Beschreibung → Fotos → Standort → Zeitrahmen
- [ ] Kategorie-Auswahl: Elektro, Sanitär, Maler, Tischler, Dachdecker, Sonstige
- [ ] Freitext-Beschreibung mit Mindestlänge (50 Zeichen)
- [ ] Foto-Upload (min. 1, max. 10 Bilder)
- [ ] Kamera-Integration (direkt aus der App fotografieren)
- [ ] Standort-Eingabe (PLZ, Adresse oder GPS)
- [ ] Gewünschter Zeitrahmen: Sofort, Diese Woche, Dieser Monat, Flexibel
- [ ] Projekt-Vorschau vor dem Absenden
- [ ] Projekt-Status: „Offen" nach Erstellung

**Story Points:** 8
**Abhängigkeiten:** Story 1.1

---

### Story 2.2: KI-gestützte Schadenserkennung
**Als** Kunde,
**möchte ich** nach dem Foto-Upload eine automatische Analyse durch KI erhalten,
**damit** ich besser verstehe, was genau das Problem ist und was es voraussichtlich kosten wird.

**Akzeptanzkriterien:**
- [ ] Gemini/OpenAI Vision API ist angebunden
- [ ] Automatische Erkennung des Schadenstyps aus Fotos
- [ ] Generierung einer verständlichen Schadensbeschreibung
- [ ] Vorgeschlagene Materialliste (mit ungefähren Kosten)
- [ ] Geschätzte Arbeitszeit-Range
- [ ] Kostenvoranschlag-Range basierend auf Region und Gewerk
- [ ] Disclaimer: „KI-Schätzung – finales Angebot kommt vom Handwerker"
- [ ] Loading-Animation während der Analyse
- [ ] Fallback wenn KI unsicher ist: „Empfehlung: Vor-Ort-Besichtigung"

**Story Points:** 13
**Abhängigkeiten:** Story 2.1

---

### Story 2.3: Video-Upload für Projekte
**Als** Kunde,
**möchte ich** auch Videos von meinem Problem hochladen können,
**damit** der Handwerker den Schaden besser einschätzen kann.

**Akzeptanzkriterien:**
- [ ] Video-Aufnahme direkt in der App (max. 60 Sekunden)
- [ ] Video-Upload aus Galerie
- [ ] Komprimierung vor Upload
- [ ] Video-Vorschau im Projekt
- [ ] KI analysiert auch Key-Frames aus Videos

**Story Points:** 5
**Abhängigkeiten:** Story 2.1

---

## Epic 3: Smart Matching & Geo-Location 🔴

> **Ziel**: Projekte werden automatisch an passende Handwerker im Umkreis geleitet.

### Story 3.1: Geo-basiertes Matching
**Als** System,
**möchte ich** neue Projekte automatisch an Handwerker im definierten Umkreis weiterleiten,
**damit** nur relevante Profis benachrichtigt werden.

**Akzeptanzkriterien:**
- [ ] PostGIS Integration in Supabase
- [ ] Handwerker definieren ihren Einsatzradius (5-100 km)
- [ ] Projekte werden nach PLZ/Koordinaten erfasst
- [ ] Automatische Benachrichtigung an passende Handwerker (Gewerk + Radius)
- [ ] Sortierung nach Entfernung + Bewertung

**Story Points:** 8
**Abhängigkeiten:** Story 1.1, Story 2.1

---

### Story 3.2: Handwerker-Jobkarte
**Als** Handwerker,
**möchte ich** alle verfügbaren Jobs in meinem Umkreis auf einer Karte sehen können,
**damit** ich effizient Aufträge in meiner Nähe annehmen kann.

**Akzeptanzkriterien:**
- [ ] Interaktive Kartenansicht (Mapbox/Google Maps)
- [ ] Projekt-Pins mit Kategorie-Icons
- [ ] Cluster-Ansicht bei Zoom-Out
- [ ] Filter: Gewerk, Entfernung, Budget-Range
- [ ] Direkter Tap auf Pin öffnet Projekt-Zusammenfassung
- [ ] Umschalten zwischen Karten- und Listenansicht

**Story Points:** 8
**Abhängigkeiten:** Story 3.1

---

### Story 3.3: Live-Tracking bei Anfahrt
**Als** Kunde,
**möchte ich** in Echtzeit sehen, wo mein Handwerker ist und wann er ankommt,
**damit** ich mich vorbereiten kann und Planungssicherheit habe.

**Akzeptanzkriterien:**
- [ ] Handwerker startet Anfahrt-Modus in der App
- [ ] Live-Position (GPS) wird auf Kunden-Seite angezeigt
- [ ] Geschätzte Ankunftszeit (ETA) wird berechnet
- [ ] Push-Benachrichtigung: „Dein Handwerker ist in 10 Min da"
- [ ] Auto-Beendigung des Trackings bei Ankunft (Geofence)

**Story Points:** 8
**Abhängigkeiten:** Story 3.1

---

## Epic 4: Kommunikation & Chat 🔴

> **Ziel**: Kunden und Handwerker können in Echtzeit kommunizieren.

### Story 4.1: Realtime Chat
**Als** Kunde oder Handwerker,
**möchte ich** in Echtzeit mit meinem Gegenüber chatten können,
**damit** wir Details klären, Bilder teilen und uns abstimmen können.

**Akzeptanzkriterien:**
- [ ] Supabase Realtime Channel pro Projekt
- [ ] Text-Nachrichten mit Zeitstempel und Gelesen-Status
- [ ] Bild-Versand im Chat
- [ ] Push-Benachrichtigung bei neuen Nachrichten
- [ ] Nachrichten-Persistenz (History abrufbar)
- [ ] Typing-Indicator
- [ ] Chat ist einem Projekt zugeordnet

**Story Points:** 8
**Abhängigkeiten:** Story 2.1

---

### Story 4.2: Quick-Actions im Chat
**Als** Handwerker,
**möchte ich** vordefinierte Aktionen direkt aus dem Chat heraus ausführen,
**damit** ich effizienter arbeiten kann.

**Akzeptanzkriterien:**
- [ ] Button „Angebot senden" → öffnet Angebots-Formular inline
- [ ] Button „Termin vorschlagen" → öffnet Datepicker
- [ ] Button „Material nachbestellen" → öffnet Bestell-Widget
- [ ] Button „Abnahme starten" → leitet zum Abnahme-Flow
- [ ] Aktionen werden als spezielle Chat-Nachrichten angezeigt
- [ ] Kunde kann auf Aktionen reagieren (Annehmen / Ablehnen)

**Story Points:** 8
**Abhängigkeiten:** Story 4.1

---

### Story 4.3: Video-Besichtigung
**Als** Kunde,
**möchte ich** dem Handwerker per Video-Call meinen Schaden zeigen können,
**damit** er vorab eine Einschätzung geben kann, ohne vor Ort sein zu müssen.

**Akzeptanzkriterien:**
- [ ] 1:1 Video-Call mit WebRTC oder Twilio/Daily.co
- [ ] Start des Calls aus dem Chat heraus
- [ ] Kamera-Wechsel (Front/Back) während des Calls
- [ ] Screenshot-Funktion während des Calls
- [ ] Screenshots werden automatisch dem Projekt hinzugefügt
- [ ] Call-Ende-Zusammenfassung (Dauer, Screenshots)

**Story Points:** 13
**Abhängigkeiten:** Story 4.1

---

## Epic 5: Angebote & Beauftragung 🔴

> **Ziel**: Handwerker können Angebote erstellen, Kunden können vergleichen und beauftragen.

### Story 5.1: Angebot erstellen & senden
**Als** Handwerker,
**möchte ich** ein strukturiertes Angebot für ein Projekt erstellen und senden können,
**damit** der Kunde transparent sehen kann, was die Arbeit kostet.

**Akzeptanzkriterien:**
- [ ] Angebots-Formular mit: Position, Beschreibung, Menge, Einzelpreis
- [ ] Materialkosten separat aufführbar
- [ ] Mehrere Positionen hinzufügbar
- [ ] Anfahrtskosten optional
- [ ] Voraussichtlicher Zeitrahmen
- [ ] Gültigkeitsdauer des Angebots
- [ ] PDF-Export des Angebots
- [ ] Angebot wird im Chat als Rich-Card angezeigt
- [ ] Automatische MwSt-Berechnung (19%/7%)

**Story Points:** 8
**Abhängigkeiten:** Story 4.1

---

### Story 5.2: Angebote vergleichen & beauftragen
**Als** Kunde,
**möchte ich** alle eingegangenen Angebote vergleichen und das beste auswählen können,
**damit** ich eine fundierte Entscheidung treffen kann.

**Akzeptanzkriterien:**
- [ ] Übersicht aller Angebote pro Projekt
- [ ] Vergleichsansicht (Side-by-Side): Preis, Zeitrahmen, Bewertung des Handwerkers
- [ ] Sortierung nach: Preis, Bewertung, Entfernung
- [ ] „Beauftragen"-Button mit Bestätigungs-Dialog
- [ ] Beauftragung löst den Treuhand-Flow aus (Epic 6)
- [ ] Absage an nicht gewählte Handwerker (automatische Nachricht)

**Story Points:** 5
**Abhängigkeiten:** Story 5.1

---

## Epic 6: Treuhand-Zahlungssystem 🔴

> **Ziel**: Sichere Zahlung durch Treuhand – Geld wird bei Beauftragung reserviert und erst nach Abnahme ausgezahlt.

### Story 6.1: Stripe Connect Integration
**Als** System,
**möchte ich** Stripe Connect als Zahlungsinfrastruktur integrieren,
**damit** Geld sicher zwischen Kunden und Handwerkern fließen kann.

**Akzeptanzkriterien:**
- [ ] Stripe Connect Onboarding für Handwerker (Standard-Account)
- [ ] Handwerker gibt IBAN und Steuerdaten ein
- [ ] Stripe Identity für KYC-Prüfung
- [ ] Test-Modus vollständig funktionsfähig
- [ ] Webhook-Handler für alle relevanten Events

**Story Points:** 8
**Abhängigkeiten:** Story 1.1

---

### Story 6.2: Treuhand-Flow (Escrow)
**Als** Kunde,
**möchte ich** bei der Beauftragung den Betrag einfrieren lassen,
**damit** der Handwerker weiß, dass das Geld vorhanden ist, und ich geschützt bin.

**Akzeptanzkriterien:**
- [ ] Bei Beauftragung: Zahlungsmittel Autorisierung (Kreditkarte, SEPA)
- [ ] Betrag wird reserviert, nicht abgebucht
- [ ] Anzeige im Kundenkonto: „€X.XXX reserviert für Projekt Y"
- [ ] Handwerker sieht: „Zahlung gesichert ✅"
- [ ] Bei Abbruch durch Kunden: automatische Freigabe

**Story Points:** 8
**Abhängigkeiten:** Story 6.1, Story 5.2

---

### Story 6.3: Digitale Abnahme & Auszahlung
**Als** Kunde und Handwerker,
**möchten wir** die Arbeit digital abnehmen können,
**damit** die Zahlung automatisch ausgelöst wird.

**Akzeptanzkriterien:**
- [ ] Handwerker markiert Arbeit als „Fertig"
- [ ] Abnahme-Protokoll: Vorher/Nachher-Fotos (Pflicht)
- [ ] Checkliste der erledigten Positionen
- [ ] Digitale Unterschrift des Kunden (Touch-Signatur)
- [ ] Nach Unterschrift: automatische Zahlungsauslösung an Handwerker
- [ ] PDF-Protokoll wird generiert und beiden Parteien zugestellt
- [ ] 48h Einspruchsfrist mit Mediation-Prozess
- [ ] Bewertungs-Prompt nach Abschluss

**Story Points:** 13
**Abhängigkeiten:** Story 6.2

---

## Epic 7: Notfall-Service (Uber-Modell) 🟡

> **Ziel**: Akut-Service für Notfälle mit sofortiger Handwerker-Vermittlung.

### Story 7.1: Notfall-Button
**Als** Kunde in einer Notfallsituation,
**möchte ich** mit einem Klick einen Sofort-Handwerker anfordern können,
**damit** mein Problem schnellstmöglich behoben wird.

**Akzeptanzkriterien:**
- [ ] Prominenter „Notfall"-Button auf dem Kunden-Dashboard
- [ ] Notfall-Kategorien: Rohrbruch, Stromausfall, Heizungsausfall, Schließdienst, Sonstige
- [ ] Standort wird automatisch per GPS ermittelt
- [ ] System sucht sofort verfügbare Handwerker im Umkreis
- [ ] Push-Benachrichtigung an „Notfall-Ready"-Handwerker
- [ ] Annahme-Deadline: 5 Minuten, sonst nächster Handwerker
- [ ] Transparentes Notfall-Pricing (Aufschlag X% klar kommuniziert)
- [ ] Live-Tracking nach Annahme

**Story Points:** 13
**Abhängigkeiten:** Story 3.1

---

### Story 7.2: Notfall-Ready Badge für Handwerker
**Als** Handwerker,
**möchte ich** mich als „Notfall-Ready" einstufen können,
**damit** ich Notfall-Aufträge mit höherem Verdienst erhalten kann.

**Akzeptanzkriterien:**
- [ ] Toggle in den Einstellungen: „Notfall-Bereitschaft"
- [ ] Definition der Bereitschaftszeiten
- [ ] „Notfall-Ready"-Badge auf dem Profil
- [ ] Statistik: Reaktionszeit, Annahme-Quote
- [ ] Mindest-Bewertung 4.0 für Notfall-Berechtigung

**Story Points:** 5
**Abhängigkeiten:** Story 7.1

---

## Epic 8: Materialbestellung 🟡

> **Ziel**: Handwerker können Material direkt über die App bestellen.

### Story 8.1: Materialbestellung Integration
**Als** Handwerker,
**möchte ich** benötigtes Material direkt über die App bestellen und zur Baustelle liefern lassen,
**damit** ich keine Zeit mit Einkaufsfahrten verliere.

**Akzeptanzkriterien:**
- [ ] API-Anbindung an mindestens einen Großhändler (MVP: Hagebau oder Hornbach)
- [ ] Materialsuche und Produktkatalog
- [ ] Warenkorb-Funktionalität
- [ ] Lieferadresse = Projekt-Adresse (voreingestellt)
- [ ] Kosten werden transparent dem Kunden angezeigt
- [ ] Vom Kunden freigegebene Bestellung (optional: automatisch bei Beauftragung)
- [ ] Bestell-Tracking

**Story Points:** 13
**Abhängigkeiten:** Story 2.1

---

## Epic 9: Bewertungs- & Badge-System 🟡

> **Ziel**: Dynamisches Reputationssystem, das Vertrauen und Engagement fördert.

### Story 9.1: Bewertungssystem
**Als** Kunde,
**möchte ich** nach Projektabschluss den Handwerker bewerten können,
**damit** andere Kunden von meiner Erfahrung profitieren.

**Akzeptanzkriterien:**
- [ ] Bewertung nach Abnahme: 1-5 Sterne
- [ ] Kriterien: Qualität, Pünktlichkeit, Kommunikation, Preis-Leistung
- [ ] Freitext-Kommentar
- [ ] Foto-Upload zur Bewertung (Ergebnis zeigen)
- [ ] Handwerker kann auf Bewertung antworten
- [ ] Bewertungen sind öffentlich auf dem Profil

**Story Points:** 5
**Abhängigkeiten:** Story 6.3

---

### Story 9.2: Dynamische Performance-Badges
**Als** Handwerker,
**möchte ich** automatisch Badges für besondere Leistungen erhalten,
**damit** mein Profil heraussticht und ich mehr Aufträge bekomme.

**Akzeptanzkriterien:**
- [ ] Badge-Definitionen:
  - 🏆 **Pünktlichkeits-Champion**: 95%+ pünktliche Erscheinung
  - 📍 **Lokalmatador**: 50+ Aufträge in einer Region
  - 🔄 **Wiederholungs-Täter**: 30%+ Wiederbeauftragungen vom selben Kunden
  - ⭐ **Top-Bewertet**: Durchschnitt 4.8+ bei 20+ Bewertungen
  - ⚡ **Blitz-Antworter**: Durchschnittliche Antwortzeit < 30 Min
  - 🆘 **Notfall-Held**: 50+ erfolgreiche Notfall-Einsätze
- [ ] Badges werden automatisch vergeben/entzogen
- [ ] Badge-Showcase auf dem Profil
- [ ] Benachrichtigung bei neuem Badge
- [ ] Badges beeinflussen Such-Ranking positiv

**Story Points:** 8
**Abhängigkeiten:** Story 9.1

---

## Epic 10: Admin & Moderation 🔴

> **Ziel**: Backend-Tools für Plattform-Verwaltung.

### Story 10.1: Admin-Dashboard
**Als** Admin,
**möchte ich** einen Überblick über die Plattform-KPIs und Aktivitäten haben,
**damit** ich datenbasierte Entscheidungen treffen kann.

**Akzeptanzkriterien:**
- [ ] Dashboard mit KPIs: Aktive Nutzer, Projekte, Umsatz, Conversion
- [ ] Nutzer-Verwaltung (Sperren, Freischalten)
- [ ] Handwerker-Verifizierung Queue
- [ ] Streitfall-Management
- [ ] Transaktions-Übersicht
- [ ] Content-Moderation (Bewertungen, Bilder)

**Story Points:** 13
**Abhängigkeiten:** Alle vorherigen Epics

---

## Backlog-Übersicht

| # | Epic | Prio | Total SP | Phase |
|---|---|---|---|---|
| 1 | Auth & Onboarding | 🔴 Must | 21 | Phase 1 |
| 2 | Projekt & KI | 🔴 Must | 26 | Phase 2 |
| 3 | Smart Matching | 🔴 Must | 24 | Phase 2 |
| 4 | Kommunikation | 🔴 Must | 29 | Phase 3 |
| 5 | Angebote | 🔴 Must | 13 | Phase 3 |
| 6 | Treuhand-Zahlung | 🔴 Must | 29 | Phase 3 |
| 7 | Notfall-Service | 🟡 Should | 18 | Phase 4 |
| 8 | Materialbestellung | 🟡 Should | 13 | Phase 4 |
| 9 | Badges & Bewertung | 🟡 Should | 13 | Phase 4 |
| 10 | Admin | 🔴 Must | 13 | Phase 1-4 |
| | **GESAMT** | | **~199 SP** | |
