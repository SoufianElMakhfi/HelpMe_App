# 🏗️ HelpMe – Technische Architektur

> Systemarchitektur, Tech-Stack, Datenmodell und Infrastruktur.
> **Mobile-First mit Flutter** – eine Codebase für iOS & Android (optional später: Flutter Web).

---

## 1. System-Übersicht

```
Mobile App (Flutter 3.x + Dart │ iOS & Android)
        │
        ▼
Backend (Supabase: PostgreSQL + PostGIS, Auth, Realtime, Storage, Edge Functions)
        │
        ▼
Externe Services: Stripe Connect │ Gemini/OpenAI │ Mapbox │ Agora/Daily │ FCM
```

> **Warum Flutter?**
> - Eine Codebase → iOS + Android (+ optional Web/Desktop in Zukunft)
> - Native Performance durch Dart AOT-Kompilierung
> - Exzellente Supabase-Integration (`supabase_flutter`)
> - Hervorragendes Widget-System für individuelle UI (Marker-Effekte, Animationen)
> - Hot Reload für schnelle Entwicklung

---

## 2. Tech-Stack

| Schicht | Technologie | Begründung |
|---|---|---|
| **Framework** | Flutter 3.x | Cross-Platform (iOS + Android), native Performance |
| **Sprache** | Dart 3.x | Null Safety, Type Safety, AOT |
| **State Management** | Riverpod 2.0 | Compile-safe, testbar, skalierbar |
| **Navigation** | GoRouter | Deklarativ, Deep Linking, Guards |
| **Datenbank** | PostgreSQL + PostGIS (Supabase) | Relational, Geo-Queries |
| **Auth** | Supabase Auth (`supabase_flutter`) | JWT, Social Login, RLS |
| **Realtime** | Supabase Realtime | WebSocket, native Postgres |
| **Storage** | Supabase Storage | S3-kompatibel, Bilder & Dokumente |
| **Serverless** | Supabase Edge Functions (Deno) | Low Latency, Business Logic |
| **Zahlung** | Stripe (`flutter_stripe`) | Marktplatz-Standard, Escrow |
| **KI** | Gemini Pro Vision / GPT-4 Vision | Bildanalyse (via Edge Function) |
| **Karten** | Mapbox (`mapbox_maps_flutter`) | Performant, customizable |
| **Video** | Agora / Daily.co | WebRTC, In-App Video-Calls |
| **Push** | Firebase Cloud Messaging | Native iOS & Android Support |
| **Kamera** | `camera` + `image_picker` | Foto-/Video-Aufnahme |
| **Lokale DB** | Isar / Drift | Offline-Cache, schnelle Queries |
| **Monitoring** | Sentry (`sentry_flutter`) + PostHog | Errors + Product Analytics |
| **CI/CD** | GitHub Actions + Fastlane | Automatisierte Builds, Store-Uploads |
| **Distribution** | App Store + Google Play | Store-Releases, TestFlight/Internal Testing |

### Wichtige Flutter Packages

```yaml
dependencies:
  # Core
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  freezed_annotation: ^2.4.0

  # Supabase
  supabase_flutter: ^2.5.0

  # UI
  flutter_animate: ^4.5.0      # Micro-Animations
  cached_network_image: ^3.3.0  # Bild-Caching
  shimmer: ^3.0.0               # Loading-Effekte
  flutter_svg: ^2.0.0           # SVG Icons & Illustrationen
  signature_pad: ^5.0.0         # Digitale Unterschrift

  # Funktionalität
  flutter_stripe: ^10.0.0       # Stripe Integration
  mapbox_maps_flutter: ^2.0.0   # Karten
  camera: ^0.11.0               # Kamera
  image_picker: ^1.0.0          # Galerie
  geolocator: ^12.0.0           # GPS Location
  firebase_messaging: ^15.0.0   # Push Notifications
  video_compress: ^3.1.0        # Video-Komprimierung

  # Offline & Storage
  isar: ^4.0.0                  # Lokale Datenbank
  path_provider: ^2.1.0         # Dateisystem
  connectivity_plus: ^6.0.0     # Netzwerk-Status
```

---

## 3. Datenmodell

### Kern-Tabellen

**profiles** – Basis-Nutzerprofil
- `id` (uuid, PK), `email`, `full_name`, `role` (customer/pro), `avatar_url`, `phone`, `location` (point), `is_verified`, `created_at`

**pro_profiles** – Erweitertes Handwerker-Profil
- `id` (PK), `profile_id` (FK→profiles), `company_name`, `trades[]`, `radius_km`, `emergency_ready`, `documents[]`, `verification_status`, `rating_avg`, `rating_count`, `badges` (jsonb), `stripe_account_id`

**projects** – Kundenprojekte
- `id` (PK), `customer_id` (FK→profiles), `title`, `description`, `category`, `status` (open/matched/in_progress/completed/cancelled), `location` (point), `address`, `photo_urls[]`, `video_urls[]`, `ai_analysis` (jsonb), `urgency`, `desired_timeframe`

**offers** – Handwerker-Angebote
- `id` (PK), `project_id` (FK), `pro_id` (FK), `line_items` (jsonb), `total_amount`, `material_cost`, `labor_cost`, `status` (pending/accepted/rejected/expired), `valid_until`

**bookings** – Buchungen
- `id` (PK), `project_id` (FK), `offer_id` (FK), `customer_id` (FK), `pro_id` (FK), `status` (confirmed/in_progress/completed/disputed), `amount`, `stripe_payment_intent_id`, `scheduled_at`, `completed_at`

**chat_channels** & **messages** – Kommunikation
- Channel: `id`, `project_id`, `customer_id`, `pro_id`, `last_message_at`
- Message: `id`, `channel_id`, `sender_id`, `content`, `type` (text/image/action/system), `metadata`, `is_read`

**reviews** – Bewertungen
- `id`, `booking_id`, `reviewer_id`, `reviewed_id`, `rating_overall/quality/punctuality/communication/value` (1-5), `comment`, `photo_urls[]`, `pro_response`

**acceptance_protocols** – Digitale Abnahme
- `id`, `booking_id`, `before_photos[]`, `after_photos[]`, `checklist` (jsonb), `signature_url`, `signed_at`, `pdf_url`

**emergency_requests** – Notfall-Anfragen
- `id`, `customer_id`, `category`, `location`, `status`, `matched_pro_id`, `matched_at`

**material_orders** – Materialbestellungen
- `id`, `booking_id`, `pro_id`, `items` (jsonb), `total_amount`, `delivery_address`, `status`, `tracking_url`

### Beziehungen
- Profile → n Projects, Profile → 1 Pro_Profile
- Project → n Offers → 1 Booking
- Booking → 1 Review, 1 Acceptance_Protocol, n Material_Orders
- Project → 1 Chat_Channel → n Messages

---

## 4. API-Endpoints (Edge Functions)

| Endpoint | Beschreibung |
|---|---|
| `/functions/analyze-image` | KI-Bildanalyse via Gemini/OpenAI |
| `/functions/create-payment-intent` | Stripe Payment Intent |
| `/functions/handle-stripe-webhook` | Stripe Event-Handler |
| `/functions/send-notification` | Push-Notification senden |
| `/functions/match-professionals` | Geo-Matching |
| `/functions/generate-protocol-pdf` | Abnahme-PDF generieren |
| `/functions/order-material` | Materialbestellung weiterleiten |

### Realtime Channels

| Channel | Zweck |
|---|---|
| `chat:{channel_id}` | Nachrichten |
| `project:{project_id}` | Projekt-Status-Updates |
| `location:{booking_id}` | Live-Tracking |
| `emergency:{region}` | Notfall-Broadcast |
| `notifications:{user_id}` | Persönliche Alerts |

---

## 5. Flutter Projekt-Struktur

```
helpme/
├── lib/
│   ├── main.dart                    # App Entry Point
│   ├── app.dart                     # MaterialApp + GoRouter Setup
│   │
│   ├── core/                        # Gemeinsame Basis
│   │   ├── config/
│   │   │   ├── app_config.dart      # Environment-Variablen
│   │   │   ├── supabase_config.dart
│   │   │   └── stripe_config.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # ThemeData (Dark & Light)
│   │   │   ├── app_colors.dart      # Farbkonstanten
│   │   │   ├── app_typography.dart  # TextStyles
│   │   │   └── app_spacing.dart     # Spacing-Konstanten
│   │   ├── router/
│   │   │   ├── app_router.dart      # GoRouter-Konfiguration
│   │   │   └── auth_guard.dart      # Route Guards
│   │   ├── widgets/                 # Wiederverwendbare Widgets
│   │   │   ├── buttons/
│   │   │   ├── cards/
│   │   │   ├── badges/
│   │   │   ├── inputs/
│   │   │   └── loading/
│   │   └── utils/
│   │       ├── extensions.dart
│   │       └── formatters.dart
│   │
│   ├── features/                    # Feature-basierte Module
│   │   ├── auth/
│   │   │   ├── data/               # Repositories, DTOs
│   │   │   ├── domain/             # Entities, Use Cases
│   │   │   └── presentation/       # Screens, Widgets, Providers
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_screen.dart
│   │   │       │   └── onboarding_screen.dart
│   │   │       ├── widgets/
│   │   │       └── providers/
│   │   │
│   │   ├── customer/               # Kunden-Features
│   │   │   ├── dashboard/
│   │   │   ├── project_creation/   # Projekt anlegen (Wizard)
│   │   │   ├── offers/             # Angebote vergleichen
│   │   │   ├── emergency/          # Notfall-Flow
│   │   │   └── tracking/           # Live-Tracking
│   │   │
│   │   ├── pro/                    # Handwerker-Features
│   │   │   ├── dashboard/
│   │   │   ├── jobs/               # Verfügbare Jobs + Karte
│   │   │   ├── offers/             # Angebote erstellen
│   │   │   ├── profile/            # Profil & Verifizierung
│   │   │   └── bookings/           # Aktive Buchungen
│   │   │
│   │   ├── chat/                   # Realtime Chat
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │
│   │   ├── payment/                # Stripe & Treuhand
│   │   ├── review/                 # Bewertungssystem
│   │   ├── acceptance/             # Digitale Abnahme
│   │   └── material/               # Materialbestellung
│   │
│   └── shared/                     # Geteilte Logik
│       ├── models/                 # Freezed Models
│       ├── providers/              # Globale Riverpod Providers
│       └── services/               # Supabase, Stripe, etc.
│
├── supabase/
│   ├── migrations/                 # SQL Migrations (001-007)
│   └── functions/                  # Edge Functions (Deno/TypeScript)
│
├── assets/
│   ├── icons/
│   ├── illustrations/
│   ├── fonts/
│   └── animations/                 # Lottie/Rive Dateien
│
├── test/                           # Unit & Widget Tests
├── integration_test/               # Integration Tests
├── android/                        # Android-spezifisch
├── ios/                            # iOS-spezifisch
├── pubspec.yaml
├── analysis_options.yaml
└── .env                            # Supabase URL, Keys, etc.
```

### Architektur-Pattern: Feature-First + Clean Architecture

```
Feature/
├── data/           # WIE (Implementierung)
│   ├── repositories/   → SupabaseProjectRepository
│   ├── datasources/    → Remote & Local
│   └── dtos/           → JSON ↔ Model Mapping (Freezed)
├── domain/         # WAS (Business Logic)
│   ├── entities/       → Project, Offer, Booking
│   ├── repositories/   → Abstract Interfaces
│   └── usecases/       → CreateProject, MatchProfessionals
└── presentation/   # WIE ES AUSSIEHT (UI)
    ├── screens/        → ProjectCreationScreen
    ├── widgets/        → ProjectCard, StatusBadge
    └── providers/      → Riverpod StateNotifier/AsyncNotifier
```

---

## 6. Sicherheit

- **RLS Policies**: Kunden sehen nur eigene Projekte; Handwerker sehen offene Jobs im Radius
- **SSL Pinning**: Zusätzliche Absicherung der App-Server-Kommunikation
- **Secure Storage**: `flutter_secure_storage` für Tokens und sensible Daten
- **Input Validation**: Dart-seitig + Server-seitig in Edge Functions
- **Rate Limiting**: Edge Functions
- **File Upload**: Typ-, Größen-Validierung
- **Code Obfuscation**: Flutter Build mit `--obfuscate` und `--split-debug-info`
- **DSGVO**: Daten-Export, Lösch-Recht, Einwilligungen
- **PCI DSS**: Kartendaten nur bei Stripe (via `flutter_stripe` SDK)
- **App Integrity**: Play Integrity API (Android) + App Attest (iOS)

## 7. Performance

| Bereich | Strategie |
|---|---|
| Bilder | WebP, `cached_network_image`, Thumbnail-Generierung |
| Datenbank | Geo-Indexe, Pagination, Connection Pooling |
| Realtime | Channel-Isolation, Subscription-Management |
| KI | Async Queue mit Retry (serverseitig) |
| Suche | Postgres Full-Text Search |
| Offline | Isar für lokalen Cache, Optimistic UI Updates |
| App-Start | Lazy Loading von Features, Tree Shaking |
| Animationen | Rive/Lottie statt programmatischer Animationen für Komplexes |

## 8. Zukunft: Flutter Web

> Falls die App später auch im Browser verfügbar sein soll:
> - Flutter Web Build kann aus derselben Codebase generiert werden
> - Responsive Breakpoints in der App bereits berücksichtigen
> - Platform-Checks (`kIsWeb`) für plattformspezifische Features (Kamera, GPS)
> - Web-Hosting dann via Firebase Hosting oder Vercel
