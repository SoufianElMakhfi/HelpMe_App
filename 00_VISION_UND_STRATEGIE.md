# 🔧 HelpMe – Vision & Strategie

> **Der MyHammer-Killer: Den kompletten Handwerker-Prozess von der Schadensanalyse bis zur Bezahlung in einer App lösen.**

---

## 1. Mission Statement

HelpMe digitalisiert die gesamte Wertschöpfungskette zwischen Kunde und Handwerker. Vom ersten Foto eines Schadens über die KI-gestützte Analyse, die transparente Preisfindung, die sichere Treuhand-Zahlung bis zur digitalen Abnahme – alles in einer einzigen, modernen App.

---

## 2. Vision

> _„In 3 Jahren ist HelpMe die erste Anlaufstelle für jedes Handwerker-Projekt in der DACH-Region – von der tropfenden Dichtung bis zur Komplettsanierung."_

### Langfristige Ziele
| Zeithorizont | Ziel |
|---|---|
| **7-8 Monate** | MVP-Launch: Onboarding, KI-Analyse, Chat, Zahlung in einer Pilotregion |
| **12 Monate** | Notfall-Button, Materialbestellung, Badges – 5 Regionen |
| **24 Monate** | DACH-weit, vollständiges Badge-System, B2B-Partnerschaften |
| **36 Monate** | Marktführerschaft in mind. einer Region, Franchise-Modell für Handwerker-Netzwerke |

---

## 3. Unique Selling Propositions (USPs)

### 🤖 KI-Bildanalyse
- Foto hochladen → Schadenserkennung per Gemini/OpenAI
- Automatischer Materiallisten-Entwurf
- Kostenvoranschläge auf Basis von Erfahrungswerten

### 🔒 Treuhand-Sicherheit
- Geld wird bei Beauftragung eingefroren (Stripe Connect)
- Auszahlung erst nach digitaler Abnahme
- Kein Risiko für Kunden, garantierte Zahlung für Handwerker

### 📦 1-Klick-Materialbestellung
- API-Anbindung an Großhändler (Hagebau, Hornbach etc.)
- Direkte Lieferung zur Baustelle
- Transparente Kosten für den Kunden

### ⚡ Notfall-Button (Uber-Modell)
- On-Demand für Akut-Fälle (Rohrbruch, Heizungsausfall)
- „Notfall-Ready"-Handwerker mit garantierter Reaktionszeit
- Dynamisches Pricing mit Transparenz-Garantie

---

## 4. Branding & Design-DNA

### Inspiration
Die App nimmt sich **Zasta** als Design-Referenz: Clean, modern, FinTech-Look mit sympathischen Illustrationen. Kein typischer Handwerker-Look mit Tools und Schrauben, sondern ein **Premium-Digital-Erlebnis**.

### Farbpalette

| Rolle | Farbe | Hex | Einsatz |
|---|---|---|---|
| **Primary Background** | Anthrazit / Dunkel | `#1A1A2E` | Hintergrund (Dark Mode) |
| **Secondary Background** | Dunkelgrau | `#16213E` | Cards, Sections |
| **Construction Accent** | Signalgelb | `#FFB800` | Headlines, CTAs, Marker-Effekte |
| **Construction Accent Alt** | Warm Orange | `#FF6B35` | Pressed-States, Badges, Highlights |
| **Success** | Mint-Grün | `#00D09C` | Bestätigungen, Check-Marks |
| **Danger** | Signal-Rot | `#FF3B5C` | Fehler, Notfall-Button |
| **Text Primary** | Reinweiß | `#FFFFFF` | Haupttext auf dunklem Hintergrund |
| **Text Secondary** | Silbergrau | `#A0A3BD` | Untertitel, Hints |

### Typografie
- **Headlines**: Bold/Black, mit „Marker"-Text-Highlight-Effekt in Signalgelb
- **Body**: Clean Sans-Serif (Inter / Outfit)
- **Zahlen/Preise**: Monospace-Touch für technisch-präzises Gefühl

### UI-Prinzipien
1. **Dark-Mode First** – Standard ist der dunkle Modus
2. **Card-Based Layout** – Alles in Cards, klare Hierarchie
3. **Micro-Animations** – Subtle Transitions, kein statisches Gefühl
4. **Illustrationen** – Sympathische, minimalistische Illustrationen statt Stock-Fotos
5. **Große Touch-Targets** – Mobile First, handwerker-freundlich (auch mit Arbeitshandschuhen bedienbar)

---

## 5. Zielgruppen

### 👤 Kunden (Customer)
| Segment | Bedürfnis | Schmerzpunkt |
|---|---|---|
| **Eigenheimbesitzer** | Zuverlässige Handwerker finden | Intransparenz, lange Wartezeiten, kein Vertrauen |
| **Mieter** | Kleine Reparaturen schnell erledigen | Vermieter reagiert nicht, keinen eigenen Handwerker |
| **WEG-Verwaltungen** | Handwerker zentral verwalten | Dokumentation, Rechnungs-Chaos |
| **Kleingewerbe** | Wartung & Instandhaltung | Budget-Unsicherheit, Ausfallzeiten |

### 🔧 Handwerker (Pro)
| Segment | Bedürfnis | Schmerzpunkt |
|---|---|---|
| **Einzelunternehmer** | Auftragsfluss sichern | Akquise kostet Zeit, unzuverlässige Kunden |
| **Kleine Betriebe (2-10)** | Auslastung optimieren | Leerlaufzeiten, Zahlungsausfälle |
| **Spezialisierte Profis** | Premium-Kunden erreichen | Auf MyHammer wird nur nach Preis verglichen |

---

## 6. Wettbewerbsanalyse

| Feature | MyHammer | Check24 Handwerker | **HelpMe** |
|---|---|---|---|
| KI-Bildanalyse | ❌ | ❌ | ✅ |
| Treuhand-Zahlung | ❌ | ❌ | ✅ |
| Notfall-Button | ❌ | ❌ | ✅ |
| Materialbestellung | ❌ | ❌ | ✅ |
| Video-Besichtigung | ❌ | ❌ | ✅ |
| Digitale Abnahme | ❌ | ❌ | ✅ |
| Verifizierte Profile | ✅ (Basic) | ✅ (Basic) | ✅ (Deep: Meister + Gewerbe) |
| Realtime Chat | ✅ | ❌ | ✅ (mit Quick-Actions) |
| Bewertungssystem | ✅ | ✅ | ✅ (Dynamic Badges) |

---

## 7. Revenue Model

| Einnahmequelle | Beschreibung | Geschätzter Anteil |
|---|---|---|
| **Plattform-Provision** | 8-12% auf jede Transaktion (Handwerker-Seite) | 55% |
| **Premium-Profil** | Handwerker-Abo für Top-Platzierung, mehr Features | 20% |
| **Notfall-Zuschlag** | Erhöhte Provision bei Notfall-Aufträgen | 10% |
| **Material-Marge** | Affiliate/Provision bei Materialbestellungen | 10% |
| **Werbung** | Regionale Werbung für Baumärkte/Zulieferer | 5% |

---

## 8. Risiken & Mitigationsstrategien

| Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|---|---|---|---|
| Handwerker-Akquise zu langsam | Hoch | Hoch | Pilotregion fokussieren, persönliche Ansprache, Startguthaben |
| Regulatorische Hürden (Treuhand) | Mittel | Hoch | Frühzeitig Rechtsberatung, Stripe's Compliance nutzen |
| KI-Analyse unzuverlässig | Mittel | Mittel | Als „Vorschlag" framen, nicht als Garantie – Handwerker korrigiert |
| Zahlungsstreitigkeiten | Mittel | Hoch | Klares Abnahme-Protokoll, Mediation-Prozess, AGB |
| Markteinführung Timing | Niedrig | Mittel | Lean MVP, schnelle Iteration |
