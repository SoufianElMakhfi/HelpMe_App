# 🛠️ HelpMe – Entwicklungsumgebung Setup (Windows)

> Schritt-für-Schritt Anleitung um auf Windows mit Flutter + Android + Supabase loszulegen.

---

## Übersicht

```
Schritt 1: Flutter SDK installieren          (~15 Min)
Schritt 2: Android Studio + Emulator         (~20 Min)
Schritt 3: VS Code Extensions               (~5 Min)
Schritt 4: Supabase Projekt erstellen        (~10 Min)
Schritt 5: Flutter-Projekt erstellen         (~5 Min)
Schritt 6: Alles testen                      (~5 Min)
────────────────────────────────────────────
Gesamt:                                      ~60 Min
```

---

## Schritt 1: Flutter SDK installieren

### 1.1 Voraussetzungen prüfen
- **Windows 10 oder höher** (64-bit)
- **Git** muss installiert sein → [git-scm.com](https://git-scm.com/download/win)
  - Prüfen: `git --version` im Terminal

### 1.2 Flutter SDK herunterladen
1. Gehe zu **[flutter.dev/docs/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows/mobile?tab=download)**
2. Lade die neueste **stable** Version herunter (ZIP-Datei)
3. Entpacke die ZIP nach `C:\dev\flutter` (nicht in `Program Files` – Berechtigungsprobleme!)

### 1.3 PATH setzen
1. Windows-Suche → „Umgebungsvariablen"
2. „Umgebungsvariablen bearbeiten" → Systemvariablen → `Path` → Bearbeiten
3. **Neu** → `C:\dev\flutter\bin` hinzufügen
4. OK → OK → Terminal NEU STARTEN

### 1.4 Prüfen
```powershell
flutter --version
```
Sollte etwas wie `Flutter 3.x.x • channel stable` anzeigen.

---

## Schritt 2: Android Studio + Emulator

### 2.1 Android Studio installieren
1. Herunterladen: **[developer.android.com/studio](https://developer.android.com/studio)**
2. Installieren und starten
3. Beim Setup-Wizard: **Standard** wählen (installiert Android SDK automatisch)

### 2.2 Android SDK prüfen
- Android Studio → **Settings** → `Languages & Frameworks` → `Android SDK`
- Sicherstellen, dass mindestens **Android 14 (API 34)** installiert ist
- Tab **SDK Tools** → sicherstellen, dass folgendes installiert ist:
  - ✅ Android SDK Build-Tools
  - ✅ Android SDK Command-line Tools
  - ✅ Android Emulator
  - ✅ Android SDK Platform-Tools

### 2.3 Emulator erstellen
1. Android Studio → **Device Manager** (rechte Seitenleiste oder Tools → Device Manager)
2. **Create Virtual Device**
3. Gerät wählen: **Pixel 7** oder **Pixel 8** (empfohlen)
4. System Image: **API 34** (Tiramisu) → Download falls nötig
5. Finish → Emulator starten mit ▶️

### 2.4 Flutter Android-Lizenzen akzeptieren
```powershell
flutter doctor --android-licenses
```
→ Alle mit `y` bestätigen.

---

## Schritt 3: VS Code Extensions

Falls du in VS Code arbeitest (empfohlen neben Android Studio):

1. **Flutter** Extension → erzwingt auch die **Dart** Extension
2. **Flutter Riverpod Snippets** → Riverpod Code-Generierung
3. **Error Lens** → Fehler direkt im Code anzeigen

VS Code → Extensions (Ctrl+Shift+X) → Suchen & Installieren.

---

## Schritt 4: Supabase Projekt erstellen

### 4.1 Account anlegen
1. Gehe zu **[supabase.com](https://supabase.com)**
2. **Start your project** → Login mit GitHub (empfohlen)
3. **New Project** erstellen:
   - **Name**: `helpme`
   - **Database Password**: Sicheres Passwort generieren und **SPEICHERN!**
   - **Region**: `Central EU (Frankfurt)` ← nächstgelegen
4. Warten bis das Projekt bereit ist (~2 Min)

### 4.2 Keys notieren
Gehe zu **Settings** → **API** und notiere dir:
- **Project URL**: `https://xxxx.supabase.co`
- **anon public Key**: `eyJhbGciOiJI...` (öffentlich, kommt in die App)
- **service_role Key**: `eyJhbGciOiJI...` (GEHEIM, nur für Admin/Backend)

> ⚠️ Diese Keys brauchst du gleich in der `.env` Datei des Flutter-Projekts.

### 4.3 Auth konfigurieren
1. **Authentication** → **Providers**
2. **Email** ist standardmäßig aktiviert ✅
3. Optional: **Google** und **Apple** Provider für Social Login einrichten (kann auch später)

---

## Schritt 5: Flutter Doctor Check

Bevor wir das Projekt erstellen, alle Dependencies prüfen:

```powershell
flutter doctor -v
```

### Erwartetes Ergebnis:
```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Windows Version
[✓] Android toolchain
[✓] Android Studio
[✓] VS Code
[✓] Connected device (oder Emulator)
[!] Network resources        ← OK, das ist nur ein Hinweis
```

> **Wichtig:** `Flutter`, `Android toolchain` und `Android Studio` müssen alle ✓ sein!
> Falls etwas fehlt, zeigt `flutter doctor` genau an, was zu tun ist.

---

## Schritt 6: Projekt erstellen & testen

Sobald `flutter doctor` alles grün zeigt, startest du das Emulator-Gerät in Android Studio und führst dann aus:

```powershell
# Projekt erstellen
flutter create --org com.helpme --project-name helpme C:\Users\Anwender\Desktop\HelpMe\app

# In den Projektordner wechseln
cd C:\Users\Anwender\Desktop\HelpMe\app

# App starten (Emulator muss laufen!)
flutter run
```

Wenn du die Flutter-Demo-App auf dem Emulator siehst → **alles funktioniert!** 🎉

---

## Checkliste

| # | Schritt | Status |
|---|---|---|
| 1 | Git installiert | ⬜ |
| 2 | Flutter SDK installiert & im PATH | ⬜ |
| 3 | Android Studio installiert | ⬜ |
| 4 | Android SDK + Emulator eingerichtet | ⬜ |
| 5 | Flutter Android-Lizenzen akzeptiert | ⬜ |
| 6 | VS Code Flutter Extension installiert | ⬜ |
| 7 | Supabase Projekt erstellt | ⬜ |
| 8 | Supabase Keys notiert | ⬜ |
| 9 | `flutter doctor` alles grün | ⬜ |
| 10 | Demo-App läuft auf Emulator | ⬜ |

---

## Nächster Schritt

Sobald die Checkliste ✅ ist, melde dich bei mir und wir:
1. Bauen die **Ordnerstruktur** nach Clean Architecture auf
2. Implementieren das **Design System** (AppColors, AppTheme, Widgets)
3. Erstellen die **Supabase-Tabellen** mit SQL Migrations
4. Bauen den **Onboarding Screen** mit Marker-Effekt
