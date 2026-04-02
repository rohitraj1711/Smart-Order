# SmartOrder

A dynamic pricing order management application built with Flutter. Supports dual-pricing tiers (Dealer/Retailer), barcode scanning, MOQ enforcement, and real-time order totals.

---

## Features

- **Dual Pricing** -- Toggle between Dealer (bulk discount) and Retailer (standard) pricing tiers with instant total recalculation.
- **Barcode Scanning** -- Camera-based scanning via Google ML Kit with torch toggle, camera flip, and real-time detection.
- **Manual Barcode Entry** -- Keyboard input with live format validation (last digit must be even).
- **MOQ Enforcement** -- Per-product minimum order quantity checks before order placement.
- **Order Summary and Confirmation** -- Sticky bottom bar with live totals; dedicated confirmation screen with line-by-line breakdown.
- **Indian Currency Formatting** -- All prices rendered in the Indian numbering system with Rupee symbol.

---

## Architecture

Clean Architecture with three layers and a shared core:

```
lib/
  core/          -- Constants, enums, theme, utilities
  domain/        -- Entities, repository contracts, use cases (pure Dart, no framework imports)
  data/          -- JSON models, repository implementation with caching, asset data service
  presentation/  -- Screens, widgets, OrderProvider (ChangeNotifier via Provider)
```

**Dependency flow:** Presentation --> Domain <-- Data. The domain layer has zero outward dependencies.

**State management:** Single `OrderProvider` (ChangeNotifier) at the widget tree root. All state mutations go through provider methods; UI rebuilds reactively via `Consumer`.

**DI:** Manual wiring in `main.dart` -- ProductService -> ProductRepositoryImpl -> UseCases -> OrderProvider.

---

## Project Structure

| Layer | Key Files | Responsibility |
|---|---|---|
| **Core** | `app_constants.dart`, `customer_type.dart`, `app_theme.dart`, `helpers.dart` | Shared config, validation, formatting, Material 3 theme |
| **Domain** | `product.dart`, `order_item.dart`, `product_repository.dart`, 2 use cases | Business entities and contracts |
| **Data** | `product_model.dart`, `product_repository_impl.dart`, `product_service.dart` | JSON parsing, in-memory caching, asset loading |
| **Presentation** | `order_provider.dart`, 3 screens, 4 widgets | UI, state, user interaction |

**Screens:** HomeScreen (product list + order controls), BarcodeScannerScreen (camera + manual entry), OrderConfirmationScreen (summary + confirm).

**Widgets:** ProductCard, CustomerTypeSelector, OrderSummaryBar, EmptyStateWidget.

---

## Build Optimizations

| Optimization | Impact |
|---|---|
| Removed unused `cupertino_icons` and `intl` | Eliminated dead dependency weight |
| R8 shrinking + resource shrinking | Strips unused Java/Kotlin code and Android resources |
| Material Icons tree-shaking | 1.6 MB reduced to 4.6 KB (99.7%) |
| Split-per-ABI builds | Fat APK 61 MB split into ~20 MB per architecture |
| ProGuard rules | Keeps CameraX/ML Kit/Play Core from being incorrectly stripped |

---

## Approach

- Adopted Clean Architecture from the start to keep business logic testable and independent of Flutter framework code.
- Used Provider for state management as it is lightweight and sufficient for an app of this scale, avoiding the overhead of heavier solutions like BLoC or Riverpod.
- Loaded product data from a local JSON asset behind a service interface, making it straightforward to swap in a REST API later without touching any other layer.
- Applied manual dependency injection in the app entry point rather than introducing a DI framework, keeping the dependency graph explicit and the package count minimal.
- Prioritized APK size from the start by auditing dependencies, enabling R8/resource shrinking, and building split-per-ABI releases.

## Challenges

- **Barcode scanner lifecycle** -- The `MobileScannerController` does not automatically resume after being interrupted by a dialog. Resolved by explicitly calling `stop()` before showing the result dialog and `start()` after it closes, and using the dialog's own `BuildContext` for `Navigator.pop` to avoid popping the wrong route.
- **R8 build failures** -- Enabling code shrinking caused `MissingClassException` for Play Core's `SplitInstallRequest` referenced by Flutter's engine. Required adding targeted ProGuard keep rules for `com.google.android.play.core` classes.
- **Material Icons font size** -- The full Material Icons font is 1.6 MB. Relied on Flutter's built-in tree-shaking to reduce it to only the icons actually used in the codebase.
- **APK size vs functionality trade-off** -- The `mobile_scanner` package bundles ML Kit native libraries (~15 MB across ABIs), which is the largest single contributor to APK size. This is unavoidable for camera-based barcode scanning and was mitigated through split-per-ABI builds.

## What I Would Improve

- **Remote data source** -- Replace the local JSON asset with a REST API and add proper error handling, retry logic, and offline caching.
- **Search and filtering** -- Add product search by name and filtering by category to improve usability as the catalog grows.
- **Order persistence** -- Store placed orders locally (SQLite/Hive) or sync them to a backend so order history is preserved across sessions.
- **Authentication** -- Add user login so orders are tied to specific accounts and pricing tiers can be server-controlled.
- **Automated testing** -- Add unit tests for the domain layer (validation, pricing calculations) and widget tests for critical UI flows.
- **Theming** -- Add dark mode support using the existing Material 3 color scheme infrastructure.

---

## Getting Started

```bash
git clone https://github.com/rohitraj1711/Smart-Order.git
cd Smart-Order
flutter pub get
flutter run
```

**Build release APK:**
```bash
flutter build apk --split-per-abi --release
```

**Regenerate launcher icons:**
```bash
dart run flutter_launcher_icons
```

**Requirements:** Flutter SDK 3.10.7+, Android SDK API 21+, physical device or emulator with camera.

---

## Releases

### v1.0.0

Download from the [Releases](https://github.com/rohitraj1711/Smart-Order/releases) page.

| Asset | Architecture | Size |
|---|---|---|
| `app-arm64-v8a-release.apk` | arm64-v8a | 21 MB |

---

## Dependencies

| Package | Purpose |
|---|---|
| `provider` ^6.1.2 | State management |
| `mobile_scanner` ^6.0.2 | Camera-based barcode scanning (ML Kit) |
| `flutter_lints` ^6.0.0 | Static analysis (dev) |
| `flutter_launcher_icons` ^0.14.3 | Icon generation (dev) |
