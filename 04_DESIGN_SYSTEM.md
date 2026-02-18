# 🎨 HelpMe – Design System

> Farben, Typografie, Komponenten-Bibliothek und UI-Richtlinien.
> **Implementiert als Flutter ThemeData** – konsistent auf iOS & Android.

---

## 1. Farbpalette

### Primärfarben (Dark Mode First)

| Name | Hex | Dart Konstante | Einsatz |
|---|---|---|---|
| `bgPrimary` | `#1A1A2E` | `Color(0xFF1A1A2E)` | Haupt-Hintergrund (Scaffold) |
| `bgSecondary` | `#16213E` | `Color(0xFF16213E)` | Cards, Sections |
| `bgElevated` | `#1F2B47` | `Color(0xFF1F2B47)` | Bottom Sheets, Dialoge |
| `bgSurface` | `#253350` | `Color(0xFF253350)` | Input-Felder, Pressed-States |

### Akzentfarben

| Name | Hex | Dart Konstante | Einsatz |
|---|---|---|---|
| `accentPrimary` | `#FFB800` | `Color(0xFFFFB800)` | Headlines, CTAs, Marker-Effekt |
| `accentSecondary` | `#FF6B35` | `Color(0xFFFF6B35)` | Badges, Highlights |
| Gradient | `#FFB800 → #FF6B35` | `LinearGradient(...)` | Premium-Buttons, Card-Header |

### Semantische Farben

| Name | Hex | Dart Konstante | Einsatz |
|---|---|---|---|
| `success` | `#00D09C` | `Color(0xFF00D09C)` | Bestätigungen, Verifiziert-Badge |
| `danger` | `#FF3B5C` | `Color(0xFFFF3B5C)` | Fehler, Notfall-Button |
| `warning` | `#FFB800` | `Color(0xFFFFB800)` | Warnungen |
| `info` | `#3B82F6` | `Color(0xFF3B82F6)` | Info-Badges |

### Text-Farben

| Name | Hex | Einsatz |
|---|---|---|
| `textPrimary` | `#FFFFFF` | Haupttext |
| `textSecondary` | `#A0A3BD` | Subtitel, Hints |
| `textMuted` | `#6B7280` | Disabled, Placeholder |
| `textInverse` | `#1A1A2E` | Text auf hellem Hintergrund |

### Dart-Implementierung (`app_colors.dart`)
```dart
abstract class AppColors {
  // Backgrounds
  static const bgPrimary = Color(0xFF1A1A2E);
  static const bgSecondary = Color(0xFF16213E);
  static const bgElevated = Color(0xFF1F2B47);
  static const bgSurface = Color(0xFF253350);

  // Accents
  static const accentPrimary = Color(0xFFFFB800);
  static const accentSecondary = Color(0xFFFF6B35);
  static const accentGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic
  static const success = Color(0xFF00D09C);
  static const danger = Color(0xFFFF3B5C);
  static const info = Color(0xFF3B82F6);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A3BD);
  static const textMuted = Color(0xFF6B7280);
  static const textInverse = Color(0xFF1A1A2E);
}
```

---

## 2. Typografie

### Google Fonts
- **Display / Headlines**: `Outfit` (Bold/Black)
- **Body / UI**: `Inter` (Regular/Medium/SemiBold)
- **Preise / Zahlen**: `JetBrains Mono` (monospace Touch)

### Skala
| TextStyle | Größe | Gewicht | Einsatz |
|---|---|---|---|
| `displayLarge` | 48px | w900 (Black) | Onboarding Headlines |
| `headlineLarge` | 32px | w800 (ExtraBold) | Screen-Titel |
| `headlineMedium` | 24px | w700 (Bold) | Abschnitts-Titel |
| `titleLarge` | 20px | w600 (SemiBold) | Card-Titel |
| `bodyLarge` | 16px | w400 (Regular) | Fließtext |
| `bodyMedium` | 14px | w400 | Labels, Hints |
| `labelSmall` | 12px | w500 (Medium) | Badges, Tags, Captions |
| `priceStyle` | 28px | w700 (Mono) | Preisanzeigen |

### Marker-Effekt (Signature Style) – Flutter Widget
```dart
class MarkerHighlight extends StatelessWidget {
  final String text;
  final bool strong;

  const MarkerHighlight(this.text, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: strong ? 6 : 4, vertical: strong ? 2 : 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.transparent,
            strong ? AppColors.accentPrimary : AppColors.accentPrimary.withOpacity(0.3),
          ],
          stops: [0.0, strong ? 0.5 : 0.6, strong ? 0.5 : 0.6],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(text, style: Theme.of(context).textTheme.headlineLarge?.copyWith(
        color: strong ? AppColors.textInverse : null,
      )),
    );
  }
}
```

---

## 3. Spacing & Layout

### Spacing-System (8px Grid)
| Konstante | Wert | Einsatz |
|---|---|---|
| `AppSpacing.xs` | 4px | Minimaler Abstand |
| `AppSpacing.sm` | 8px | Inline-Elemente |
| `AppSpacing.md` | 12px | Label zu Input |
| `AppSpacing.lg` | 16px | Standard-Padding |
| `AppSpacing.xl` | 24px | Card-Padding |
| `AppSpacing.xxl` | 32px | Section-Gap |
| `AppSpacing.xxxl` | 48px | Page-Sections |

### Border Radius
| Konstante | Wert | Einsatz |
|---|---|---|
| `AppRadius.sm` | 6px | Buttons, Inputs |
| `AppRadius.md` | 12px | Cards |
| `AppRadius.lg` | 16px | Bottom Sheets |
| `AppRadius.xl` | 24px | Große Cards |
| `AppRadius.full` | 999px | Avatare, Pills |

---

## 4. Kernkomponenten (Flutter Widgets)

### Button-Varianten

| Widget | Hintergrund | Text | Einsatz |
|---|---|---|---|
| `HmPrimaryButton` | Accent Gradient | `textInverse` | Hauptaktion (CTA) |
| `HmSecondaryButton` | `bgElevated` + Border | `textPrimary` | Sekundäre Aktionen |
| `HmGhostButton` | Transparent | `accentPrimary` | Tertiäre Aktionen |
| `HmDangerButton` | `danger` | `textPrimary` | Löschen, Abbrechen |
| `HmEmergencyButton` | Pulsierender `danger` Gradient | `textPrimary` | Notfall-Button |

### Card-Typen

| Widget | Beschreibung |
|---|---|
| `HmCard` | `bgSecondary`, `radius.md`, Padding `xl`, subtle Border |
| `HmElevatedCard` | Wie Base + BoxShadow + Tap-Feedback |
| `HmProjectCard` | Kategorie-Badge, Thumbnail, Status-Indicator |
| `HmOfferCard` | Preis, Handwerker-Info, Accept/Reject-Buttons |
| `HmChatBubble` | Rounded, farblich unterschieden (eigene/fremde) |
| `HmBadge` | Kompakt, Icon + Label, farbcodiert |

### Badge-Styling (Dart)
```dart
enum BadgeType { verified, master, emergency, top }

class HmBadge extends StatelessWidget {
  final BadgeType type;
  final String label;
  final IconData icon;

  static final _styles = {
    BadgeType.verified:  (AppColors.success, AppColors.success.withOpacity(0.12)),
    BadgeType.master:    (AppColors.accentPrimary, AppColors.accentPrimary.withOpacity(0.12)),
    BadgeType.emergency: (AppColors.danger, AppColors.danger.withOpacity(0.12)),
    BadgeType.top:       (AppColors.info, AppColors.info.withOpacity(0.12)),
  };
  // ... build method mit Container, Row, Icon, Text
}
```

---

## 5. Animationen & Micro-Interactions

### Standard-Durations
```dart
abstract class AppAnimations {
  static const fast = Duration(milliseconds: 150);     // Tap-Feedback
  static const normal = Duration(milliseconds: 250);   // UI-Änderungen
  static const slow = Duration(milliseconds: 400);     // Page-Transitions
  static const spring = Duration(milliseconds: 500);   // Bounce-Effekte

  static const springCurve = Curves.elasticOut;
  static const defaultCurve = Curves.easeInOut;
}
```

### Animationen (via `flutter_animate` Package)
| Name | Beschreibung | Einsatz |
|---|---|---|
| `fadeIn` + `slideY` | Einblenden mit Hochschieben | Screen-Übergang, Card-Erscheinen |
| `slideY(1→0)` | Von unten einschieben | Bottom Sheets, Modals |
| `scale(1↔1.05)` | Pulsieren | Notfall-Button, Live-Indicator |
| `shimmer` | Gold-Schimmer | Badge-Vergabe, Premium |
| `custom painter` | Marker von links nach rechts | Marker-Headlines (Signature) |

### Notfall-Button (Flutter)
```dart
class EmergencyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFF3B5C), Color(0xFFFF1744)]),
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [BoxShadow(color: Color(0x99FF3B5C), blurRadius: 20, spreadRadius: 0)],
      ),
      child: /* ... */,
    )
    .animate(onPlay: (c) => c.repeat())
    .scale(begin: Offset(1, 1), end: Offset(1.02, 1.02), duration: 1.seconds)
    .then()
    .scale(begin: Offset(1.02, 1.02), end: Offset(1, 1), duration: 1.seconds);
  }
}
```

### Lottie/Rive Animationen
- **Loading States**: Benutzerdefinierte Lade-Animationen (kein Standard-Spinner)
- **Success / Check**: Animiertes Häkchen nach Abschluss
- **Onboarding**: Illustrierte Schritte mit Rive-Animationen
- **Empty States**: Animierte Platzhalter statt statischer Bilder

---

## 6. Icons & Illustrationen

### Icon-System
- **Library:** `lucide_icons` Flutter Package (konsistent, clean)
- **Größen:** 16px (inline), 20px (BottomNav), 24px (AppBar), 32px (Features)
- **Stil:** Outline (Standard), Filled (aktiver Tab/Zustand)
- **Fallback:** `flutter_svg` für Custom-Icons

### Illustrations-Stil
- **Minimalistische Linien-Illustrationen** mit Construction Accent
- Optional: Rive/Lottie für animierte Illustrationen
- Keine fotorealistischen Bilder, keine Stock-Fotos
- **Farbgebung:** Anthrazit-Linien + Signalgelb/Orange Akzente

---

## 7. Mobile Navigation & Patterns

### Bottom Navigation
```
[ 🏠 Home ] [ 📋 Projekte ] [ ➕ Neu ] [ 💬 Chat ] [ 👤 Profil ]
```
- **Aktiver Tab:** Filled Icon + AccentPrimary
- **Inaktiver Tab:** Outline Icon + TextMuted
- **FAB „Neu":** Runder Button mit Gradient, leicht erhöht

### Plattform-Patterns
- **Touch Targets:** Minimum 48×48dp (Material) / 44×44pt (iOS)
- **Bottom Sheets:** Für Auswahl, Filter, Quick-Actions
- **Swipe Gestures:** Swipe-to-dismiss, Pull-to-refresh
- **Safe Areas:** `SafeArea` Widget – Notch, Dynamic Island, Rounded Corners
- **Haptic Feedback:** Bei wichtigen Aktionen (Beauftragen, Notfall, Abnahme)
- **Platform-adaptive:** `CupertinoAlertDialog` auf iOS, `AlertDialog` auf Android

---

## 8. Dark/Light Mode

| Element | Dark Mode (Default) | Light Mode |
|---|---|---|
| Scaffold | `#1A1A2E` | `#F5F5F7` |
| Cards | `#16213E` | `#FFFFFF` |
| Text Primary | `#FFFFFF` | `#1A1A2E` |
| Text Secondary | `#A0A3BD` | `#6B7280` |
| Accent | `#FFB800` (bleibt) | `#FF8C00` (etwas dunkler) |
| Shadows | Subtle glow | Standard elevation |

> **Hinweis:** Light-Mode ist optional für Phase 1. Dark-Mode ist der primäre Modus.
> Implementiert via `ThemeData.dark()` als Basis mit Custom-Extensions.
