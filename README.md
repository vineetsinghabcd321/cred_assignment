# Job Hive

Job Hive is a cross-platform Flutter application that presents a credit-card
dashboard from a structured mock response. The app combines a card-stack
interface, statement information, payment actions, card details, payment
activity, and an authentication screen backed by Firebase Authentication.

The home experience is intentionally data-driven: the UI does not hard-code
individual cards or activity rows. Instead, it loads
[`assets/mock/home_response.json`](assets/mock/home_response.json), converts
the response into typed Dart models, and renders the resulting sections.

## What the app does

The application currently provides:

- A credit-card dashboard as the default screen.
- A top bar with remote image assets, statement information, and tab buttons.
- A vertically scrollable stack of credit cards.
- Card rendering with front and back faces.
- Horizontal card swipes that reveal available actions.
- A `Pay now` flow for cards with a pending action.
- Upward swipes and long presses that open card details.
- A Hero animation between a card in the stack and its details sheet.
- Card details including quick actions, card metadata, and activity history.
- Login and sign-up routes.
- Firebase email/password login through `FirebaseAuth`.
- Responsive sizing based on a 375 x 812 design reference.

The home dashboard does not call a live backend. Its card and statement data
comes from the bundled JSON response, which makes the project runnable without
an API server.

## Technology stack

- **Flutter/Dart** - Cross-platform application and UI framework.
- **GetX** - Routing, dependency injection, controllers, and reactive state.
- **flutter_screenutil** - Responsive dimensions and text scaling.
- **Firebase Authentication** - Email/password login repository integration.
- **Flutter AssetBundle** - Loading the local JSON response.
- **Material widgets** - Layout, typography, gestures, icons, and theming.
- **Custom painting and animations** - Card effects, dotted dividers, shimmer
  effects, and the 3D Hero transition.

Dependencies are declared in [`pubspec.yaml`](pubspec.yaml):

- `get`
- `flutter_screenutil`
- `firebase_auth`
- `flutter_lints` for development analysis

## Project structure

```text
job_hive/
├── assets/
│   └── mock/
│       └── home_response.json       # Bundled dashboard response
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_text_style.dart # Shared text styles
│   │   └── routes/
│   │       ├── app_pages.dart       # GetX route registrations and bindings
│   │       └── app_routes.dart      # Route name constants
│   ├── features/
│   │   ├── auth/
│   │   │   ├── binding/
│   │   │   │   └── auth_binding.dart
│   │   │   ├── controllers/
│   │   │   │   └── auth_controller.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── views/
│   │   │       ├── login_view.dart
│   │   │       └── sign_up_view.dart
│   │   └── home/
│   │       ├── binding/
│   │       │   └── home_binding.dart
│   │       ├── controllers/
│   │       │   ├── card_details_controller.dart
│   │       │   └── home_controller.dart
│   │       ├── models/
│   │       │   ├── card_action_model.dart
│   │       │   ├── card_model.dart
│   │       │   ├── cred_model.dart
│   │       │   └── credit_card_model.dart
│   │       ├── service/
│   │       │   └── home_service.dart
│   │       └── views/
│   │           ├── home_view.dart
│   │           └── widget/
│   │               ├── card_details_sheet.dart
│   │               ├── card_stack_widget.dart
│   │               ├── card_widget.dart
│   │               ├── credit_card_item.dart
│   │               └── top_bar_widget.dart
│   ├── widgets/
│   │   ├── custom_elevated_button.dart
│   │   ├── custom_text_field.dart
│   │   └── custom_widget_text.dart
│   └── main.dart                    # Application entry point
├── test/
│   ├── home_service_test.dart       # Data and widget behavior tests
│   └── route_structure_test.dart    # Route registration tests
├── android/                         # Android runner and Firebase config
├── ios/                             # iOS runner and Firebase config
├── macos/                           # macOS runner and Firebase config
├── linux/                           # Linux runner
├── windows/                         # Windows runner
└── web/                             # Web runner
```

## Application startup

The entry point is [`lib/main.dart`](lib/main.dart). It:

1. Ensures Flutter bindings are initialized.
2. Configures a light status bar with a white background.
3. Starts `ScreenUtilInit` using a 375 x 812 design size.
4. Creates a `GetMaterialApp`.
5. Registers the application routes from `AppPages`.
6. Starts at `/home`.
7. Keeps the status-bar area opaque while the dashboard scrolls underneath it.

The route setup is defined in
[`lib/core/routes/app_pages.dart`](lib/core/routes/app_pages.dart) and uses
the constants from [`lib/core/routes/app_routes.dart`](lib/core/routes/app_routes.dart):

| Route | Screen | Binding |
|---|---|---|
| `/home` | `HomeView` | `HomeBinding` |
| `/login` | `LoginView` | `AuthBinding` |
| `/signUp` | `SignUpView` | None |

`/home` is currently the initial route. The login screen is registered and can
be navigated to, but the current startup configuration does not force users
through authentication before showing the dashboard.

## Architecture and data flow

The project follows a small feature-oriented architecture:

- **Views** render the UI and forward user interactions.
- **Controllers** own reactive state and screen-level behavior.
- **Services/repositories** load data or communicate with external services.
- **Models** convert raw data into typed objects.
- **Bindings** register dependencies when a route is created.

### Home dashboard flow

1. `HomeBinding` creates `HomeService` and registers `HomeController`.
2. `HomeController.onInit()` calls `fetchHomeData()`.
3. `HomeService` loads `assets/mock/home_response.json` with `AssetBundle`.
4. The JSON is decoded into `RegisterRequestModel`.
5. `HomeController` stores the response items and card actions in observable
   GetX lists.
6. The controller identifies dashboard sections by their
   `template_name` values, including:
   - `cm_top_bar`
   - `unbilled_statement_info_section_v2`
   - `cm_card_instrument`
7. The views map those items into `CardModel` and `CreditCardModel` objects.
8. `Obx` rebuilds the relevant widgets when loading, error, tab, or card data
   changes.

`HomeService` accepts an optional `AssetBundle`. This keeps the service
testable because tests can provide a controlled bundle instead of reading from
the real application bundle.

### Authentication flow

Authentication is separated into three layers:

1. `LoginView` collects email and password values.
2. `AuthController` owns the text controllers and calls the repository.
3. `AuthRepository` calls
   `FirebaseAuth.instance.signInWithEmailAndPassword`.

On success, the controller displays a GetX success snackbar. On failure, it
displays the Firebase error text in an error snackbar. The repository currently
implements login only; sign-up UI exists as a route, but account creation is
not implemented in the current code.

## Mock response format

The bundled response contains an `items` collection and card-level action
definitions. Each item includes a template name and template properties. The
model layer extracts the fields needed by the UI, such as:

- Header and top-bar assets.
- Statement amount and payment labels.
- Card name, number, expiry, and visual theme.
- Pending action information.
- Card action IDs, labels, icons, and action types.
- Card detail rows.
- Activity date and activity rows.

To add or modify dashboard content during development, update
[`home_response.json`](assets/mock/home_response.json) while preserving the
fields expected by the model factories. Because the file is registered under
`assets/mock/` in `pubspec.yaml`, it is packaged with the application.

## Home screen behavior

### Card stack

`CardStackWidget` displays up to four visible cards. It calculates each card's
vertical and horizontal offset to create the stacked appearance. The
`HomeController` tracks the stack's scroll progress and controls when the
front card collapses while the page scrolls.

### Card gestures

`CreditCardItem` manages the interaction state for each card:

- Dragging horizontally opens or closes the action panel.
- A horizontal release settles the card using a spring animation.
- Swiping upward opens the details sheet.
- A long press opens the details sheet.
- The card action grid displays the actions supplied by the response.
- The card can trigger the pending payment action.

### Card details

`CardDetailsSheet` is a modal-style details view that:

- Uses a Hero transition from the selected card.
- Shows the card face and can toggle to a back/chip-only view.
- Displays quick actions such as mark-paid and payment-history.
- Renders typed detail rows and activity history.
- Scrolls to the history section when the history action is selected.
- Uses `CardDetailsController` to map action names to icons and parse the
  card's theme color.

The Hero flight uses perspective, rotation, and positional movement to make the
card appear to lift out of the stack. Tapping outside the details view returns
the card to its original position.

## Running the project

### Requirements

- Flutter SDK compatible with Dart `^3.12.2`.
- A configured Flutter device, emulator, or browser.
- Firebase configuration if testing authentication.

### Install dependencies

```bash
flutter pub get
```

### Run the application

```bash
flutter run
```

You can select a target platform with the normal Flutter options, for example:

```bash
flutter run -d chrome
flutter run -d ios
flutter run -d android
```

### Analyze the project

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

The test suite includes:

- JSON loading and model parsing.
- Header and statement values.
- Pending-action and view-details labels.
- Card action count and card model mapping.
- Horizontal action-panel behavior.
- Upward-swipe navigation to card details.
- Login and sign-up route registration.

## Firebase configuration

The native Firebase configuration files are stored in the platform projects:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `macos/Runner/GoogleService-Info.plist`

Before testing login on a new Firebase project, replace those files with the
configuration generated for that project. Ensure Email/Password sign-in is
enabled in the Firebase console and that a test user exists.

The current authentication integration uses `firebase_auth`. Firebase Core
initialization is not currently active in `main.dart`, so a production version
should explicitly initialize Firebase before using authentication and should
add a proper authenticated/unauthenticated navigation flow.

## Current limitations and next steps

This repository is a UI-focused assignment/demo rather than a complete
production banking application. Important follow-up work includes:

- Make authentication the gate for the home route if required.
- Initialize Firebase explicitly during application startup.
- Implement account creation for the sign-up screen.
- Add logout and authenticated-session persistence.
- Replace the local mock service with a production API client.
- Add loading, retry, and empty-state UI to the dashboard.
- Replace remote image URLs with validated or bundled assets where appropriate.
- Add accessibility labels and semantic descriptions for card actions.
- Add more controller and interaction tests for error states and edge cases.
- Resolve any test expectations that differ from the current initial route or
  test viewport configuration.

## Design and implementation notes

- The design reference uses a 375 x 812 mobile frame.
- `flutter_screenutil` is initialized once at the application root.
- GetX is used at feature boundaries rather than for every local widget state.
- Short-lived visual state remains local to widgets, such as the card-face
  toggle and swipe animation.
- The response model is intentionally kept separate from UI models so the
  presentation layer does not depend on every raw response field.
- Errors from home-data loading are stored in `HomeController.errorMessage`;
  authentication errors are surfaced through GetX snackbars.

