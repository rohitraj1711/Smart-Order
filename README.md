# SmartOrder

A dynamic pricing order management application built with Flutter. SmartOrder provides a streamlined interface for managing product orders with dual-pricing tiers (Dealer and Retailer), barcode scanning, minimum order quantity enforcement, and real-time order totals.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Services and Components](#services-and-components)
- [Screens](#screens)
- [Business Logic](#business-logic)
- [Build and Size Optimizations](#build-and-size-optimizations)
- [Getting Started](#getting-started)
- [Releases](#releases)
- [Dependencies](#dependencies)
- [License](#license)

---

## Features

- **Dual Pricing Tiers** -- Switch between Dealer and Retailer customer types to display tier-specific pricing. Dealer pricing reflects bulk discounts; Retailer pricing reflects standard market rates.

- **Barcode Scanning** -- Scan product barcodes using the device camera powered by Google ML Kit via the `mobile_scanner` package. Supports torch toggle, camera flip, and real-time barcode detection.

- **Manual Barcode Entry** -- Enter barcodes manually through a dedicated input field with real-time format validation feedback.

- **Barcode Validation** -- Barcodes are validated using a last-digit-even rule. Only barcodes whose final digit is even (0, 2, 4, 6, 8) are accepted as valid.

- **Minimum Order Quantity (MOQ) Enforcement** -- Each product defines a minimum order quantity. The application validates all order items against their respective MOQ before allowing order placement, displaying specific error messages for items that do not meet the threshold.

- **Real-Time Order Totals** -- A persistent bottom summary bar displays the current item count and grand total, updating in real time as quantities change.

- **Order Confirmation** -- A dedicated summary screen presents all order items with line-by-line pricing breakdowns and a grand total before final submission.

- **Product Catalog** -- Products are loaded from a local JSON asset with support for name, description, category, image, dual pricing, MOQ, unit, and barcode fields.

- **Indian Currency Formatting** -- All prices are formatted using the Indian numbering system with the Rupee symbol.

---

## Architecture

The application follows **Clean Architecture** principles with a clear separation of concerns across three layers:

```
lib/
  core/          -- Shared constants, enums, theme, and utility functions
  domain/        -- Business entities, repository contracts, and use cases
  data/          -- Data models, repository implementations, and data services
  presentation/  -- UI screens, widgets, and state management (Provider)
```

### Layer Responsibilities

| Layer | Responsibility | Dependencies |
|---|---|---|
| **Domain** | Defines business entities, repository interfaces, and use cases. Contains no framework imports. | None (pure Dart) |
| **Data** | Implements repository contracts, handles JSON deserialization, and manages data fetching from local assets. | Domain |
| **Presentation** | Manages UI rendering, user interaction, and application state via `ChangeNotifier` (Provider). | Domain, Core |
| **Core** | Provides shared utilities, theme configuration, enums, and constants used across all layers. | None |

### Dependency Flow

```
Presentation --> Domain <-- Data
         \         |         /
          \------> Core <---/
```

The domain layer has zero outward dependencies. The data layer depends only on domain contracts. The presentation layer consumes domain entities and use cases, never accessing the data layer directly.

---

## Project Structure

```
lib/
|-- main.dart                                  -- Application entry point and DI wiring
|
|-- core/
|   |-- constants/
|   |   |-- app_constants.dart                 -- App name, asset paths, currency symbol
|   |-- enums/
|   |   |-- customer_type.dart                 -- Dealer/Retailer enum with display labels
|   |-- theme/
|   |   |-- app_theme.dart                     -- Material 3 theme with brand colors
|   |-- utils/
|       |-- helpers.dart                       -- Barcode validation, MOQ checks, currency formatting
|
|-- domain/
|   |-- entities/
|   |   |-- product.dart                       -- Product entity (immutable, value equality by ID)
|   |   |-- order_item.dart                    -- Order line item with quantity and line total
|   |-- repositories/
|   |   |-- product_repository.dart            -- Abstract repository contract
|   |-- usecases/
|       |-- get_products_usecase.dart           -- Fetch all products
|       |-- get_product_by_barcode_usecase.dart -- Look up product by barcode string
|
|-- data/
|   |-- models/
|   |   |-- product_model.dart                 -- JSON-serializable model extending Product entity
|   |-- repositories/
|   |   |-- product_repository_impl.dart       -- Repository with in-memory caching
|   |-- services/
|       |-- product_service.dart               -- Asset-based data fetching service
|
|-- presentation/
    |-- providers/
    |   |-- order_provider.dart                -- Centralized state: products, cart, scan results
    |-- screens/
    |   |-- home_screen.dart                   -- Main product listing with order controls
    |   |-- barcode_scanner_screen.dart         -- Camera-based barcode scanner with manual entry
    |   |-- order_confirmation_screen.dart      -- Order summary and confirmation
    |-- widgets/
        |-- product_card.dart                  -- Product display with pricing, MOQ, and quantity stepper
        |-- customer_type_selector.dart        -- Animated Dealer/Retailer toggle
        |-- order_summary_bar.dart             -- Sticky bottom bar with total and Place Order button
        |-- empty_state_widget.dart            -- Reusable empty/error state illustration

assets/
|-- data/
|   |-- products.json                          -- Product catalog (10 items)
|-- icon/
    |-- app_icon.png                           -- Source icon for launcher icon generation
```

---

## Services and Components

### Data Layer

**ProductService** (`data/services/product_service.dart`)
- Reads and decodes the `products.json` asset file.
- Returns a list of `ProductModel` instances.
- Designed as a swappable service; replacing this single class with an HTTP client is the only change required to move from local to remote data.

**ProductRepositoryImpl** (`data/repositories/product_repository_impl.dart`)
- Implements the `ProductRepository` contract from the domain layer.
- Maintains an in-memory cache after the first fetch to avoid repeated asset reads.
- Provides `getProducts()` for full catalog and `getProductByBarcode()` for barcode lookup.
- Exposes `invalidateCache()` for cache clearing when needed.

**ProductModel** (`data/models/product_model.dart`)
- Extends the domain `Product` entity, adding `fromJson()` and `toJson()` methods.
- The presentation layer never interacts with this class directly; it sees only `Product` entities.

### Domain Layer

**Product** (`domain/entities/product.dart`)
- Immutable entity with fields: `id`, `name`, `description`, `imageUrl`, `dealerPrice`, `retailerPrice`, `moq`, `unit`, `category`, `barcode`.
- Value equality based on `id`.

**OrderItem** (`domain/entities/order_item.dart`)
- Pairs a `Product` with a mutable `quantity`.
- Provides `lineTotal(CustomerType)` to compute the price for the given customer tier.
- Provides `isMoqSatisfied` to check quantity against the product MOQ.

**ProductRepository** (`domain/repositories/product_repository.dart`)
- Abstract interface defining `getProducts()` and `getProductByBarcode(String)`.

**Use Cases**
- `GetProductsUseCase` -- Callable class wrapping `ProductRepository.getProducts()`.
- `GetProductByBarcodeUseCase` -- Callable class wrapping `ProductRepository.getProductByBarcode()`.

### Presentation Layer

**OrderProvider** (`presentation/providers/order_provider.dart`)
- Central `ChangeNotifier` managing all application state.
- Holds the product list, order items map, selected customer type, loading/error states, and scan result messages.
- Computed properties: `grandTotal`, `totalItemsInCart`, `activeOrderItems`.
- Actions: `loadProducts()`, `setCustomerType()`, `updateQuantity()`, `incrementQuantity()`, `decrementQuantity()`, `processScanResult()`, `validateOrder()`, `resetOrder()`, `clearScanMessage()`.

### Core Utilities

**Helpers** (`core/utils/helpers.dart`)
- `isBarcodeValid(String)` -- Returns true if the last digit of the barcode is even.
- `isMoqSatisfied(int, int)` -- Returns true if quantity meets or exceeds MOQ.
- `moqErrorMessage(String, int, String)` -- Generates human-readable MOQ error strings.
- `unitPrice(...)` -- Returns the correct price based on customer type.
- `lineTotal(...)` -- Computes quantity multiplied by unit price.
- `formatCurrency(double, {String})` -- Formats numbers using the Indian numbering system with comma separators.

**AppTheme** (`core/theme/app_theme.dart`)
- Material 3 light theme built from a deep blue seed color (`#1565C0`).
- Brand colors: deep blue (primary), teal (secondary), green (dealer), orange (retailer).
- Custom styling for AppBar, Cards, Buttons, Input fields, SnackBars, and Chips.

---

## Screens

### Home Screen
The main product listing screen. Displays all products in a scrollable list with quantity steppers. Includes a customer type toggle at the top, an info banner showing the active pricing tier, a barcode scanner shortcut in the app bar, and a sticky order summary bar at the bottom. Validates MOQ compliance before allowing navigation to the order confirmation screen.

### Barcode Scanner Screen
Full-screen camera-based barcode scanner. Features include torch toggle, camera flip, real-time barcode detection, and a bottom sheet for manual barcode entry. On successful scan, the product is added to the order and the user is returned to the home screen. On failure (invalid barcode or product not found), a dialog offers "Try Again" (restarts the camera) or "Cancel" (returns to home).

### Order Confirmation Screen
Displays a line-by-line breakdown of all active order items with quantity, unit price, and line total. Shows the customer type badge, subtotal, and grand total. The "Confirm Order" button triggers a success dialog and resets the order upon completion.

---

## Business Logic

### Barcode Validation
A barcode is considered valid if and only if its last character is a digit and that digit is even (0, 2, 4, 6, 8). Empty or null barcodes are rejected. Non-numeric trailing characters are rejected.

### Pricing
Each product has two prices: `dealerPrice` and `retailerPrice`. The active price is determined by the currently selected `CustomerType`. All totals are computed dynamically when the customer type changes.

### MOQ Validation
Before placing an order, each active item (quantity greater than zero) is checked against its product MOQ. If any item fails, a dialog lists all violations with the product name, required MOQ, and unit.

### State Management
The application uses the Provider pattern with a single `OrderProvider` instance created at the root of the widget tree. All state mutations occur through provider methods. The UI is rebuilt reactively via `Consumer` and `context.read` / `context.watch`.

### Dependency Injection
Manual dependency injection is performed in `main.dart`. The wiring sequence is:
1. `ProductService` (data source)
2. `ProductRepositoryImpl` (wraps service, adds caching)
3. `GetProductsUseCase` and `GetProductByBarcodeUseCase` (wrap repository)
4. `OrderProvider` (receives use cases)

---

## Build and Size Optimizations

The following measures were applied to minimize the release APK size:

| Optimization | Detail |
|---|---|
| Unused dependency removal | Removed `cupertino_icons` and `intl` (neither was imported in any source file) |
| R8 code shrinking | Enabled `isMinifyEnabled` in the Android release build to strip unused Java/Kotlin code |
| Resource shrinking | Enabled `isShrinkResources` to remove unused Android resources from the APK |
| Material Icons tree-shaking | Flutter automatically reduced the Material Icons font from 1.6 MB to 4.6 KB (99.7% reduction) |
| Split-per-ABI builds | Build produces separate APKs for armeabi-v7a, arm64-v8a, and x86_64 instead of a single fat binary |
| App Bundle splitting | Configured language, density, and ABI splits for Play Store delivery |
| ProGuard rules | Custom keep rules for CameraX, ML Kit, and Play Core to prevent R8 from breaking reflection-dependent classes |
| Artificial delay removal | Removed a simulated 800ms network delay from the local asset loader |

### Release APK Sizes

| ABI | Size |
|---|---|
| armeabi-v7a | 19.5 MB |
| arm64-v8a | 21 MB |
| x86_64 | 25.7 MB |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or later
- Android SDK with API level 21 or higher
- A physical device or emulator with camera access (for barcode scanning)

### Installation

```bash
git clone https://github.com/rohitraj1711/Smart-Order.git
cd Smart-Order
flutter pub get
```

### Running in Debug Mode

```bash
flutter run
```

### Building a Release APK

```bash
# Split-per-ABI (recommended for direct distribution)
flutter build apk --split-per-abi --release

# App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### Regenerating Launcher Icons

```bash
dart run flutter_launcher_icons
```

---

## Releases

### v1.0.0

Download the pre-built release APK from the [Releases](https://github.com/rohitraj1711/Smart-Order/releases) page.

| Asset | Architecture | Size |
|---|---|---|
| `app-arm64-v8a-release.apk` | arm64-v8a | 21 MB |

---

## Dependencies

### Runtime

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | UI framework |
| `provider` | ^6.1.2 | State management via ChangeNotifier |
| `mobile_scanner` | ^6.0.2 | Camera-based barcode scanning (Google ML Kit) |

### Development Only

| Package | Version | Purpose |
|---|---|---|
| `flutter_test` | SDK | Widget and unit testing |
| `flutter_lints` | ^6.0.0 | Static analysis and lint rules |
| `flutter_launcher_icons` | ^0.14.3 | Automated launcher icon generation for all platforms |

---

## License

This project is provided as-is for educational and demonstration purposes.
