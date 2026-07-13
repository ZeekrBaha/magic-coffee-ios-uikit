# Magic Coffee iOS

A coffee-ordering app built in **programmatic UIKit** for iOS 16+, implementing the *Magic Coffee App iOS UI Kit* Figma design across **26 screens** — from onboarding and local auth through a deep coffee-customization (“assemblage”) flow, checkout with QR pickup, order history, a loyalty/rewards program, and a post-order review.

No backend: authentication, catalog, orders, and rewards all run locally on **Core Data**, with product/store/barista data seeded on first launch.

---

## Screenshots

Captured on iPhone 16 Pro (iOS 16) by the `ScreenshotCaptureTests` UI test, which walks the entire flow end to end.

### Auth

| Splash | Sign In | Sign Up |
|--------|---------|---------|
| ![Splash](docs/screenshots/00_splash.png) | ![Sign In](docs/screenshots/01_signin.png) | ![Sign Up](docs/screenshots/02_signup.png) |

| Forgot Password | Verification (OTP) | |
|-----------------|--------------------|---|
| ![Forgot](docs/screenshots/03_forgot_password.png) | ![Verification](docs/screenshots/04_verification.png) | |

### Store Selection & Catalog

| Store List | Map | Catalog |
|------------|-----|---------|
| ![Store List](docs/screenshots/05_store_list.png) | ![Map](docs/screenshots/06_map.png) | ![Catalog](docs/screenshots/07_catalog.png) |

| Product Detail | | |
|----------------|---|---|
| ![Product Detail](docs/screenshots/08_product_detail.png) | | |

### Coffee Assemblage

| Milk | Syrup | Barista |
|------|-------|---------|
| ![Milk](docs/screenshots/09_milk_selection.png) | ![Syrup](docs/screenshots/10_syrup_selection.png) | ![Barista](docs/screenshots/11_barista_selection.png) |

| Country | Coffee Sort | Additives |
|---------|-------------|-----------|
| ![Country](docs/screenshots/12_country_selection.png) | ![Sort](docs/screenshots/13_coffee_sort.png) | ![Additives](docs/screenshots/14_additives.png) |

| Encyclopedia | Summary | |
|--------------|---------|---|
| ![Encyclopedia](docs/screenshots/15_encyclopedia.png) | ![Summary](docs/screenshots/16_assemblage_summary.png) | |

### Checkout & Review

| Pre-Payment | Payment | Confirmation (QR) |
|-------------|---------|-------------------|
| ![Pre-Payment](docs/screenshots/17_prepayment.png) | ![Payment](docs/screenshots/18_payment.png) | ![Confirmation](docs/screenshots/19_confirmation.png) |

| Review Modal | | |
|--------------|---|---|
| ![Review](docs/screenshots/20_review_modal.png) | | |

### Orders, Rewards & Profile

| Orders — Ongoing | Orders — History | Rewards |
|------------------|------------------|---------|
| ![Ongoing](docs/screenshots/21_orders_ongoing.png) | ![History](docs/screenshots/22_orders_history.png) | ![Rewards](docs/screenshots/23_rewards.png) |

| Redeem | Profile | |
|--------|---------|---|
| ![Redeem](docs/screenshots/24_redeem.png) | ![Profile](docs/screenshots/25_profile.png) | |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | UIKit — 100% programmatic (no Storyboards / XIBs), Auto Layout via `NSLayoutConstraint` |
| Architecture | MVVM + Coordinator |
| Bindings | Combine (`@Published` → `.sink`) |
| Async | `async`/`await` over Core Data background contexts |
| Persistence | Core Data (`NSPersistentContainer`) |
| Maps | MapKit (store map + pin) |
| QR | Core Image (`CIQRCodeGenerator`) |
| Dependencies | **None** — pure Apple frameworks, no SPM / CocoaPods |
| Project | Hand-maintained `MagicCoffee.xcodeproj` (no XcodeGen) |
| Tests | XCTest (unit) + XCUITest (UI) |

---

## Architecture

### Coordinator tree

Navigation is owned entirely by coordinators; view controllers never push/present each other directly.

```
AppCoordinator (owns UIWindow, routes on launch)
├── AuthCoordinator              ← no active CDUser
│   ├── SplashViewController
│   ├── SignInViewController
│   ├── SignUpViewController
│   ├── ForgotPasswordViewController
│   └── VerificationViewController          (OTP — hardcoded "1234")
├── StoreSelectionCoordinator    ← user exists, no store chosen
│   ├── StoreListViewController             (dark photo bg, 3 stores)
│   └── MapViewController                   (MapKit pin + Select)
└── MainTabCoordinator           ← normal app state (UITabBarController)
    ├── CatalogCoordinator (tab 0)
    │   ├── CatalogViewController           (2×3 UICollectionView)
    │   ├── ProductDetailViewController
    │   └── AssemblageCoordinator           (8-screen flow, shared AssemblageState)
    │       ├── MilkSelection / SyrupSelection      (pageSheet bottom sheets)
    │       ├── BaristaSelection / CountrySelection
    │       ├── CoffeeSortSelection / AdditivesSelection
    │       ├── Encyclopedia / AssemblageSummary
    │       └── CheckoutCoordinator
    │           ├── PrePaymentListViewController
    │           ├── PaymentViewController            (OrderService.placeOrder)
    │           └── ConfirmationViewController       (QR) → Review modal
    ├── RewardsCoordinator (tab 1)
    │   ├── RewardsViewController            (loyalty stamp card, points)
    │   └── RedeemViewController
    ├── MyOrdersCoordinator (tab 2)
    │   └── MyOrdersViewController           (UIPageViewController: Ongoing | History)
    └── ProfileCoordinator (tab 3)
        └── ProfileViewController            (editable name / phone / email / address)
```

### MVVM per feature

```
ViewController  ──Combine .sink──▶  ViewModel (@Published state, : BaseViewModel)
                                          │  async/await
                                     Service layer
                  ┌───────────────────────┼───────────────────────┐
              AuthService   ProductService / StoreService / BaristaService
              OrderService                 LoyaltyService
                              │
                        CoreDataStack
                  (NSPersistentContainer, single shared NSManagedObjectModel)
```

### Routing on launch

```
AppCoordinator.route()
    │
    ├─ active CDUser?  ── no ──▶ AuthCoordinator (Splash → SignIn/SignUp → OTP)
    │                                   │ login/register sets isActive = true
    │                                   ▼
    ├─ "mc_store_selected" flag set? ── no ──▶ StoreSelectionCoordinator
    │                                   │ Select sets the UserDefaults flag
    │                                   ▼
    └─ else ──────────────────────────────▶ MainTabCoordinator
```

### Order flow (catalog → review)

```
Catalog ─tap cell─▶ ProductDetail ─"Assemblage"/"Next"─▶ AssemblageCoordinator
   Milk ▸ Syrup ▸ Barista ▸ Country ▸ Sort ▸ Additives ▸ Encyclopedia ▸ Summary
        (selections accumulate in a shared AssemblageState reference type)
                              │  "Proceed"
                              ▼
   CheckoutCoordinator:  PrePaymentList ▸ Payment
                              │  OrderService.placeOrder()  → writes CDOrder + CDOrderItem
                              │  LoyaltyService adds a stamp / points
                              ▼
                         Confirmation (renders QR from order ID)
                              │  after 1s
                              ▼
                         Review modal (5-star tap · Remind me later · No thanks)
```

### Core Data model (`MagicCoffee.xcdatamodeld`)

```
CDUser ──┬──< CDOrder >──┬──< CDOrderItem >── CDProduct
         │               ├── CDStore
         │               └── CDBarista (optional)
         ├──── CDLoyaltyCard   (stamps / maxStamps=8 / totalPoints)
         └──< CDRewardHistory  (date / points / productName)

CDProduct   (name, imagePath, price, sortOrder)
CDStore     (name, address, latitude, longitude)
CDBarista   (name, specialty?, isAvailable, imagePath?)
```

> **Single shared model.** `CoreDataStack.managedObjectModel` is a process-wide `static let` reused by both the production container and every in-memory test container. Loading the `.momd` more than once registers the same `NSManagedObject` subclasses against multiple models, which makes `+entity` ambiguous and crashes `init(context:)` nondeterministically. One model instance avoids it entirely.

### Test strategy

```
Unit tests (73)                         UI tests (6)
──────────────────────────────────     ─────────────────────────────
AuthServiceTests          (7)          AuthFlowUITests            (5)
ProductServiceTests       (6)            splash → signin → signup
StoreServiceTests         (7)            → OTP valid / invalid
BaristaServiceTests       (5)          MagicCoffeeUITests         (1)
OrderServiceTests         (7)            app launches
LoyaltyServiceTests       (8)
MyOrdersTests             (5)                    ↑
DataSeederTests           (5)          -uitest-reset-auth launch arg
CoreDataStackTests        (3)          forces a logged-out start at Splash
AssemblageStateTests      (6)
VerificationViewModelTests(2)
ProfileViewModelTests     (6)
ReviewViewModelTests      (6)
        ↑
in-memory CoreDataStack (TestCoreDataSupport),
sharing CoreDataStack.managedObjectModel
```

**79 tests total — all passing.**

---

## Project Structure

```
MagicCoffee/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift          ← UI-test reset hook, kicks off seeding
│   └── AppCoordinator.swift         ← launch routing (auth / store / main)
├── Core/
│   ├── CoreData/                    CoreDataStack, MagicCoffee.xcdatamodeld
│   ├── Coordinator/                 Coordinator protocol
│   ├── Base/                        BaseViewModel (cancellables, weak coordinator)
│   ├── Extensions/                  UIColor+/UIFont+ design system, UIViewController+Add
│   ├── Seeding/                     DataSeeder (first-launch products/stores/baristas)
│   ├── Storage/                     ImageFileManager
│   └── UI/                          AuthUI, MCButton, MCTextField (shared components)
├── Features/
│   ├── Auth/                        AuthCoordinator + Splash, SignIn, SignUp,
│   │                                ForgotPassword, Verification (VC + VM each)
│   ├── StoreSelection/              StoreSelectionCoordinator + StoreList, Map
│   ├── Main/                        MainTabCoordinator
│   ├── Catalog/                     CatalogCoordinator + Home, ProductDetail
│   ├── Assemblage/                  AssemblageCoordinator + AssemblageState +
│   │                                Milk, Syrup, Barista, Country, CoffeeSort,
│   │                                Additives, Encyclopedia, Summary, PrePaymentList
│   ├── Checkout/                    CheckoutCoordinator + Payment, Confirmation
│   ├── MyOrders/                    MyOrdersCoordinator + MyOrders host, Ongoing, History
│   ├── Rewards/                     RewardsCoordinator + Rewards, Redeem
│   ├── Profile/                     ProfileCoordinator + Profile
│   └── Review/                      ReviewViewController + ReviewViewModel (post-order)
├── Services/
│   ├── AuthService.swift            register / login / currentUser / logout (SHA-256)
│   ├── AuthError.swift
│   ├── ProductService.swift
│   ├── StoreService.swift
│   ├── BaristaService.swift
│   ├── OrderService.swift           placeOrder → CDOrder + items + loyalty
│   └── LoyaltyService.swift         stamps, points, redeem, history
└── Resources/
    ├── Assets.xcassets              product images (americano, cappuccino, latte, …)
    ├── Fonts/                       Poppins-*.ttf, DMSans-*.ttf
    └── Info.plist                   UIAppFonts registration

MagicCoffeeTests/                    unit tests + TestCoreDataSupport
MagicCoffeeUITests/                  XCUITest flows
```

---

## Design System

`Core/Extensions/UIColor+DesignSystem.swift` · `UIFont+DesignSystem.swift`

| Token | Value | Use |
|-------|-------|-----|
| `mcPrimary` | `#314B59` | dark navy/teal — text, nav |
| `mcAccent` | `#4ECDC4` | teal — buttons, selections |
| `mcCardBg` | `#F7F8FB` | light gray cards |
| `mcTextPrimary` | `#001833` | primary text |
| `mcTextSecondary` | `#D8D8D8` | secondary text |
| `mcStar` | `#FF9500` | orange rating stars |
| `mcSurface` | white | surfaces |

Fonts: **Poppins** (Regular / Medium / Bold) and **DM Sans** (Regular / Medium), registered via `UIAppFonts` and exposed as `.poppins(_:size:)` / `.dmSans(_:size:)`.

---

## Setup

### Prerequisites

- Xcode 16+, an iOS 16+ simulator (CI uses iPhone 16 Pro)
- No package manager, no credentials, no codegen — everything needed is in the repo.

### Steps

```bash
git clone <repo>
cd magic-coffee-ios
open MagicCoffee.xcodeproj
# Select the MagicCoffee scheme + an iOS 16+ simulator, then Run.
```

On first launch `DataSeeder` populates Core Data with 6 products, 3 stores, and 3 baristas (guarded by the `mc_seeded` UserDefaults flag, so it runs once).

### Launch arguments

| Argument | Effect |
|----------|--------|
| `-uitest-reset-auth` | Clears the active user and `mc_store_selected` so the app starts clean at Splash (used by UI tests) |

---

## Running Tests

```bash
# Full suite (unit + UI)
xcodebuild test \
  -scheme MagicCoffee \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# Tip: trim the output to just the summary lines
xcodebuild test -scheme MagicCoffee \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' 2>&1 \
  | grep -E "Executed [0-9]+ test|error:|BUILD (SUCCEEDED|FAILED)"
```

All **82 tests pass (74 unit + 8 UI)** — verified with a real `xcodebuild test` run on a
booted iOS Simulator, and enforced in CI (`.github/workflows/ci.yml`: `xcodegen generate` →
`swiftlint` → `xcodebuild test`, run fresh from `project.yml` on every push/PR).

---

## Notes & Conventions

- **No Storyboards/XIBs** — every screen is built in code with Auto Layout.
- **No external dependencies** — UIKit, Combine, Core Data, MapKit, Core Image only.
- **Local-only auth** — passwords are SHA-256 hashed into `CDUser.passwordHash`; the OTP screen accepts the hardcoded code **`1234`** (no SMS).
- **Payment is UI-only** — “Pay Now” calls `OrderService.placeOrder()` locally; there is no real payment SDK.
- **Coordinators own navigation** — view models talk to their coordinator through the weak `coordinator` reference on `BaseViewModel`.
- **Project is XcodeGen-generated** — `MagicCoffee.xcodeproj` is generated from `project.yml` (`xcodegen generate`, tracked in git for convenience); new `.swift` files under `MagicCoffee/` are picked up automatically on the next `xcodegen generate`, nothing to register manually.

## Limitations / Next steps

- **Unsalted single-round SHA-256 password hashing** (`AuthService.swift`) — fine for an
  offline local-only demo with zero network surface, but not a production password scheme
  (no salt, no KDF). Would need to change before any real backend appears.
- **OTP verification accepts a hardcoded code (`1234`)** — no real SMS/OTP delivery; this
  is a UI-flow demo, not a real verification system.
- **All data is local Core Data** — no sync across devices, no backend, no real payment
  processing ("Pay Now" is UI-only).
- **7-commit history** — features landed in large increments rather than small reviewable
  ones; no red/green TDD evidence recoverable from git history, though the test suite
  itself (82 tests, service + view-model layer) is real and passing.
