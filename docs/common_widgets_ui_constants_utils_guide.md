# Common widgets, UI constants, and utils — guide for large Flutter apps

This document suggests what you can add under `lib/core/common_widgets`, `lib/core/ui_constants`, and `lib/core/utils` in a **generic, reusable** way. It also covers **foundation topics** for a large app: performance, **`StatefulWidget` / `State` lifecycle**, **`lib/network/`** (Dio, errors, cancellation, **`RequestBloc` + automatic retry via `RequestRetryConfig`**), **mobile-first offline / no-internet UX**, **catchy data-refresh patterns** (beyond pull-to-refresh), concurrency, async/streams, animations, navigation arguments, local persistence, and how those pieces fit together.

Prefer **composition** over one-off mega-widgets, and keep widgets **theme-aware** (read from `Theme.of(context)` / extensions) instead of hard-coding colors everywhere.

### How to use this doc

- Use the early sections for **folder content** (`common_widgets`, `ui_constants`, `utils`).
- Use the later sections for **architecture and platform behavior** (isolates, routing, storage, jank, **widget lifecycle**, **network layer**).

---

## Table of contents

1. Principles (before you add files)
2. `core/common_widgets` — what to add
3. `core/ui_constants` — what to add
4. `core/utils` — what to add
5. Suggested folder shape (evolution)
6. Performance & avoiding lag (UI thread & profiling)
7. Concurrency: isolates, `compute`, & heavy work
8. Async: `Future`, `async`/`await`, & cancellation
9. Streams & reactive UI (custom builders)
10. State management: API response vs UI state
11. StatefulWidget and State lifecycle (smooth, leak-free UI)
12. `lib/network/` — API layer, Dio, `RequestBloc`, & `RequestRetryConfig` (redundancy-free)
13. Mobile-first UX and offline / no-internet experience
14. Catchy & effective data-update patterns (beyond pull-to-refresh)
15. Animations & motion
16. Routing & passing data between screens
17. Local persistence: SharedPreferences → SQLite / Drift
18. Staying current with Flutter (scope & habits)
19. Checklists (widget + performance / architecture)

---

## Principles (before you add files)

1. **Theme first** — Put semantic colors and text styles in `ThemeData` / `ColorScheme` / `TextTheme` where possible; use `ui_constants` for tokens that feed into the theme or for one-off design specs.
2. **Accessibility** — Minimum tap targets (~48×48 logical pixels), contrast (WCAG), `Semantics`, screen reader labels, scalable text (`MediaQuery.textScaler` / `TextScaler`).
3. **Responsiveness** — Breakpoints (mobile / tablet / desktop), `LayoutBuilder`, optional `flutter_screenutil`-style scaling only if you accept its trade-offs.
4. **Empty / error / loading** — Standardize placeholders so every screen feels consistent.
5. **Testability** — Widgets with fewer hidden globals; inject `VoidCallback`s and data; avoid static singletons inside UI where a parameter works.
6. **Performance** — Prefer `const` constructors, avoid rebuilding heavy subtrees (split widgets, `RepaintBoundary` where profiling shows benefit).
7. **Lifecycle discipline** — Anything with a listener, subscription, or native handle must have a matching **dispose** (or cancel); after `async` gaps, guard with **`mounted`** before updating UI (see **StatefulWidget and State lifecycle** below).
8. **i18n / l10n** — User-facing strings should eventually live in ARB / `intl`, not in `ui_constants` text style files (styles yes, copy no).

---

## `core/common_widgets` — what to add

Group by **behavior**, not by screen. Each item can be one file or a small folder if it grows (e.g. `buttons/primary_button.dart`).

### Layout & scaffolding

- **App scaffold** — Consistent `Scaffold` + `AppBar` pattern (titles, actions slot, `SafeArea` policy).
- **Responsive shell** — Navigation rail vs bottom bar vs drawer based on width.
- **Max width container** — Center content with `maxWidth` on large screens.
- **Sliver helpers** — Reusable header / pinned bar patterns if you use custom scroll views.
- **Spacers / gaps** — Thin wrappers around fixed gaps using your spacing tokens (optional; many teams use `SizedBox` + constants only).

### Buttons & controls

- **Primary / secondary / text / icon buttons** — Single API: `onPressed`, `label`, `isLoading`, `isEnabled`.
- **Async button** — Disables and shows inline loader while `Future` runs (guards double-tap).
- **Segmented control / toggle chips** — For filters and mode switches.
- **Icon + label row** — Settings-style rows with trailing chevron.

### Forms & inputs

- **Text field** — Unified decoration, error text, `TextInputAction`, focus behavior, clear button optional.
- **Password field** — Visibility toggle built in.
- **Search field** — Debounced `onChanged` callback (or expose controller + document debounce in utils).
- **Dropdown / bottom sheet picker** — Same look for “select one” flows.
- **Checkbox / switch row** — Label + subtitle + control aligned to design system.

### Feedback & state

- **Loading overlay / full-screen loader** — Optional; use sparingly vs inline skeletons.
- **Linear / circular progress** — Sized and colored from theme.
- **Snackbar / toast wrapper** — One function or widget so messaging is consistent (still call from a single place if you use GetX / another API).
- **Dialog & bottom sheet templates** — Title, body, actions; `showAppDialog` helpers.
- **Empty state** — Illustration/icon + title + subtitle + optional CTA.
- **Error state** — Message + retry; map `ApiException` / `RequestFailure` to copy in one place if you want.
- **Offline / no internet** — Dedicated, **beautiful full-screen or inline** states (see **Mobile-first UX and offline / no-internet experience** below); do not reuse a generic “Error” with scary red copy for “airplane mode” cases.
- **Refresh affordances** — Besides **`RefreshIndicator`**, consider **AppBar refresh** (with rotation while loading), **“Updated · tap to refresh”** chips, **resume** / **tab-focus** refresh — see **Catchy & effective data-update patterns** below.

### Lists & grids

- **Paged list / infinite scroll** — With pull-to-refresh and footer loader.
- **List section header** — Sticky or simple section titles.
- **Shimmer / skeleton tiles** — For cards, list rows, profile header.
- **Swipe actions** — Optional wrapper for dismiss / archive patterns.

### Media & content

- **Cached image** — Wrapper around `cached_network_image` if you add the dependency; placeholder + error.
- **Avatar** — Initials fallback, border, size tokens.
- **Badge** — Count or dot on icons / tabs.

### Navigation-aware (optional)

- **Back button** — Consistent with `PopScope` / `CanPop` behavior if you customize exits.
- **Tab bar** — Styled tab bar matching your theme.

### State / rebuild helpers (you already have one)

- **`ValueNotifierBuilder`** — Keep; consider a sibling **`ListenableBuilder2`** / **`MultiListenableBuilder`** if two listenables are common (or document using `AnimatedBuilder` with `Listenable.merge`).
- **`AsyncSnapshot` helpers** — Small widgets that map `ConnectionState` → loader / error / child (see [Streams](#streams--reactive-ui-custom-builders) below).

### Animations (widget-level)

- **Hero** — Shared element transitions between routes (wrap matching widgets with same `tag`; keep tags stable and unique).
- **Implicitly animated widgets** — `AnimatedOpacity`, `AnimatedSwitcher`, `AnimatedSize`, `AnimatedContainer` for simple state-driven motion without a controller.
- **`TweenAnimationBuilder`** — One-off tweens without `SingleTickerProviderStateMixin`.
- **Page / route transitions** — Custom `GetPage` transitions or a central `PageTransitionsTheme` so pushes feel consistent.
- **Lottie / Rive** — For complex authored motion; keep files small and cache controllers where the package allows.

### Developer experience

- **`AppDivider`**, **`AppCard`** — Thin themed wrappers so you do not repeat `Card` + margin + shape everywhere.

---

## `core/ui_constants` — what to add

Split into **tokens** (raw values) and **theme assembly** (how tokens map to `ThemeData`). Avoid duplicating: tokens → theme → widgets read theme.

### Suggested files / areas

| Area | Contents | Notes |
|------|-----------|--------|
| **Colors** | Primary / secondary / surface / error / success / warning / outline / scrim / shadow | Prefer semantic names (`brand`, `danger`) not only `blue500`. |
| **Color scheme builder** | `lightColorScheme`, `darkColorScheme` | Feed `ThemeData.colorScheme`. |
| **Typography** | Font family names, font weights enum or constants | Register fonts in `pubspec.yaml`. |
| **Text styles** | `display`, `headline`, `title`, `body`, `label` variants | Map to `TextTheme`; use `copyWith` for color from `ColorScheme`. |
| **Font sizes / line heights** | Numeric tokens (e.g. 12, 14, 16, 20, 24, 32, 40) | Single source of truth before `TextStyle`. |
| **Spacing** | `xs`, `sm`, `md`, `lg`, `xl`, `xxl` (and optional component-specific) | You started with `app_spacing.dart` — extend. |
| **Radii** | `sm`, `md`, `lg`, full | For `BorderRadius` / `ClipRRect`. |
| **Elevation / shadows** | Presets for cards, modals, FAB | Or use Material 3 elevation tokens. |
| **Durations** | `fast`, `normal`, `slow` for animations | |
| **Breakpoints** | `compact`, `medium`, `expanded` widths | Align with [Material window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes) if you use M3. |
| **Icons** | App-wide icon sizes (e.g. 20, 24) | Optional; or derive from theme. |
| **Illustration / asset paths** | Centralized `AppAssets` class | Typosafe references if you use const strings. |
| **Opacity / alpha** | Disabled state, overlays | e.g. `disabledOpacity = 0.38`. |

### Theme entry point

- **`app_theme.dart`** — `ThemeData lightTheme()` / `darkTheme()` composing `ColorScheme`, `TextTheme`, `AppBarTheme`, `InputDecorationTheme`, `ElevatedButtonTheme`, `CardTheme`, `DividerTheme`, `BottomNavigationBarTheme`, `ChipTheme`, `DialogTheme`, `SnackBarTheme`, `FloatingActionButtonTheme`, etc.

### What *not* to put in ui_constants

- Long user-visible strings (use l10n).
- One-off colors only used in a single feature (prefer theme extension or feature-local constant with a comment).
- Business logic.

### Optional advanced pattern

- **`ThemeExtension`** — Custom tokens (e.g. `SuccessColors`, `ChartStyles`) attached to `Theme.of(context).extension<MyColors>()!` for type-safe extras beyond `ColorScheme`.

---

## `core/utils` — what to add

Keep **pure** or **framework-light** helpers here; heavy Flutter-specific navigation helpers might live next to `router` or a `core/navigation` folder later.

### Formatting

- **Dates / times** — `formatDate`, `formatRelativeTime`, timezone-aware if needed (`intl`).
- **Numbers / currency** — Locale-aware formatting.
- **Phone / card masking** — Display-only formatters.

### Validation

- **Email, phone, password rules** — Return `String?` error or a small `ValidationResult` type.
- **URL / deep link** — Parsing helpers if you use custom schemes.

### String / collection

- **Null-safe defaults**, **truncate with ellipsis**, **capitalize**, **slugify** (if SEO or URLs).
- **Immutable list helpers** — `groupBy`, `distinctBy` (or use `collection` package).

### Async & result types

- **`AsyncResult` / `Result<T, E>`** — Algebraic result instead of throwing everywhere (optional; aligns with repositories).
- **Debounce / throttle** — For search fields and scroll listeners.
- **Cancellation** — Helpers around `CancelToken` (Dio) or documenting `Future` cancellation patterns.

### Logging & errors

- **Logger facade** — Wrap `dart:developer` / `talker` / `logger` in one API (`logDebug`, `logError`).
- **Error mapping** — `Object` → user-facing message (shared with your `ApiException`).

### Device & platform

- **`isTablet` / `screenWidthBucket`** — Based on `MediaQuery` (pass `BuildContext` or `MediaQueryData`).
- **Keyboard visibility** — `MediaQuery.viewInsets` helpers.
- **Haptic feedback** — One-liner wrappers for common actions.

### Persistence keys & env

- **SharedPreferences keys** — Centralized string constants (see [Local persistence](#local-persistence-sharedpreferences--sqlite--drift) for a typed wrapper pattern).
- **Feature flags keys** — If you use remote config later.

### Concurrency helpers (call-site documentation)

- **`compute`-friendly pure functions** — Document which JSON parsers / transforms are safe to run in an isolate (no `BuildContext`, no plugins unless isolate-safe).
- **TransferableTypedData / isolate patterns** — Only if you move large binary buffers; most apps never need this.

### Security (careful)

- **Redaction in logs** — Never log tokens; helper to mask strings.
- **Do not put secrets in utils** — Use `--dart-define`, env, or secure storage; utils only consume them.

### Testing helpers

- **Clock / time override** — Injectable “now” for tests (optional interface).

---

## Suggested folder shape (evolution)

As the app grows, you might split like this (still under `core/`):

```
core/
  common_widgets/
    buttons/
    forms/
    feedback/
    layout/
    media/
    animations/          # small reusable motion widgets if you outgrow inline Animated*
  ui_constants/
    colors.dart
    typography.dart
    spacing.dart
    radii.dart
    durations.dart
    breakpoints.dart
    assets.dart
    app_theme.dart
    theme_extensions/
  utils/
    formatters/
    validation/
    async/
    platform/
  persistence/           # optional: SharedPrefs wrapper, secure storage facade
```

**`lib/network/`** can grow without duplicating logic:

```
network/
  api_networks/
    api_client/
    interceptors/        # optional: auth header, refresh, logging, retry policy
    api_constants/
    api_endpoints/
    api_exception/
  bloc/
    request_bloc.dart
    request_events.dart
    request_retry_config.dart
    request_states.dart
```

Start small: add files when a **second** screen needs the same thing.

---

## Performance & avoiding lag (UI thread & profiling)

Flutter’s UI is **single-threaded** on the main isolate. “Lag” usually means **frame budget missed** (~16.6 ms at 60 Hz): work blocked the UI thread during build/layout/paint or during GPU work.

### Rules of thumb

- **Do not parse huge JSON, decode big images synchronously, or run O(n²) list logic on the UI isolate** during a frame — move to **`compute`** or another **isolate** (see **Concurrency** below).
- **Keep `build` cheap** — No network calls, no disk I/O, no heavy `List.where` over thousands of rows without pagination or virtualization.
- **Use list virtualization** — `ListView.builder` / `SliverList` so off-screen children are not built.
- **Prefer `const` widgets** where possible; split widgets so only the subtree that changes rebuilds.
- **Images** — Precache where it helps; use resolution-aware assets; for network images prefer a cached solution with bounded memory.
- **Shader / first-frame jank** — Warm up shaders in a controlled splash (Flutter tooling evolves; use current DevTools guidance for your SDK).
- **RepaintBoundary** — Use when profiling shows repaints spreading; not a default on every widget.

### Tooling (do this regularly)

- **DevTools → Performance** — Identify jank, shader compilation, long frames.
- **DevTools → CPU Profiler** — Find hot methods on the UI thread.
- **DevTools → Memory** — Leaks (forgotten `StreamSubscription`, `AnimationController` not disposed, `TextEditingController` not disposed).

---

## Concurrency: isolates, `compute`, & heavy work

Dart does **not** use OS threads for your app logic the way Kotlin/Java do on the UI path. You get:

- **Main isolate** — UI + most plugins.
- **Additional isolates** — True parallel CPU work; **no shared mutable memory** — messages are copied (or transferred for some types).

### When to use `compute` or a custom `Isolate`

- **Large JSON decode** or CPU-heavy parsing.
- **Image processing**, compression, cryptography (CPU-bound).
- **Big sort / filter** on large in-memory collections before rendering.

### When *not* to bother

- Tiny JSON, a few hundred list items, trivial formatting — isolate overhead can cost more than the work.

### Practical notes

- **Plugins** — Many plugins are **not** isolate-safe; assume I/O still goes through `async` APIs on the main isolate unless documented otherwise.
- **`ReceivePort` / `SendPort`** — For long-lived workers (e.g. dedicated parser isolate with a queue).
- **Threading wording** — Say **“isolates”** in Dart/Flutter; “multithreading” is misleading for app code (the engine uses threads under the hood, but you coordinate via async/isolates).

---

## Async: `Future`, `async`/`await`, & cancellation

- **`async`/`await`** — Primary style for I/O (network, disk, `shared_preferences`). Keeps call stacks readable; errors become stack traces you can log.
- **`Future` composition** — `then`, `Future.wait` for parallel independent calls; watch error handling (one failure fails the group unless you handle per-future).
- **Avoid blocking** — Never use `Future.sync` heavy work; never call `.result` style blocking APIs on UI.
- **Cancellation** — Use **Dio `CancelToken`**, or check **disposed** / **closed** flags before applying results. Pattern: repository methods accept optional `CancelToken`; UI disposes token on `dispose` or new search.
- **`unawaited`** — For fire-and-forget with explicit lint (`discarded_futures`); prefer structured error handling for anything user-visible.
- **Timeouts** — `timeout` on futures for network; pair with cancel tokens where possible.

---

## Streams & reactive UI (custom builders)

Use **streams** for **ongoing** events (Firestore snapshots, WebSockets, download progress, ticking timers). Use **`Future`** for **one-shot** loads.

### Built-in widgets

- **`StreamBuilder<T>`** — Standard; always handle `ConnectionState.waiting` and `hasError`.
- **`StreamBuilder` + `initialData`** — Avoids first-frame empty flash when you already have cached value.

### Patterns for reuse

- **Thin wrapper** — e.g. `AppStreamBuilder<T>` that maps errors to your `ErrorState` widget and loading to `SkeletonList`.
- **BLoC / Cubit** — `BlocBuilder` / `BlocListener` for stream-backed state (your API layer can still expose `Future` internally and merge into a Cubit).

### Pitfalls

- **Listen without cancel** — Subscribe in `initState`, **cancel in `dispose`** (or use managed subscriptions).
- **Broadcast vs single-subscription** — Know your stream type; accidental double subscription crashes single-subscription streams.

---

## State management: API response vs UI state

Splitting concerns keeps the app **fast to reason about** and avoids redundant rebuilds.

| Concern | Typical tools | Examples |
|--------|----------------|----------|
| **Server / one-shot API** | `RequestBloc<T>`, repository + `Future`, or feature Cubit | Load profile, submit form |
| **Ongoing remote** | `Stream` + `StreamBuilder` / Cubit | Chat, live prices |
| **Local UI only** | `ValueNotifier` + `ValueNotifierBuilder`, `TextEditingController`, `FocusNode` | Selected tab, form fields, animations toggles |
| **Cross-screen shared** | Injected repository, `BlocProvider` at subtree root, or lightweight app-level notifier | Auth session, cart (choose by complexity) |

**Guideline:** Prefer **ID + fetch** on the destination screen for details (see routing below) so you do not pass huge objects through the navigator and duplicate source of truth.

**When to use `StatefulWidget`:** Use it when you need **mutable objects tied to this element’s lifetime** — `AnimationController`, `TextEditingController`, `FocusNode`, `PageController`, `ScrollController`, `TabController`, `CancelToken` for a screen-scoped request, or a `Ticker`. Prefer **`StatelessWidget` + `ValueNotifier`** (or BLoC/Cubit) when state is simple and you already have a clear owner for `dispose`.

---

## StatefulWidget and State lifecycle (smooth, leak-free UI)

Used well, explicit `State` makes the app **predictable** and avoids jank from leaks and stale async updates.

### Lifecycle order (what to use when)

| Phase | When it runs | Typical use (do / don’t) |
|--------|----------------|---------------------------|
| **`createState`** | Once when the element is created | Return `State`; almost no logic here. |
| **`initState`** | Once, after object inserted in tree | **Do:** `addListener`, create controllers, start logic that does **not** depend on `context` for `InheritedWidget` reads if you can avoid it. **Do:** schedule one-off post-frame work via `WidgetsBinding.instance.addPostFrameCallback` if you need layout/size. **Don’t:** assume full `Theme`/`MediaQuery` dependency ordering is final for all cases — see `didChangeDependencies`. |
| **`didChangeDependencies`** | When an `InheritedWidget` this `State` depends on changes | **Do:** react to theme, locale, route `ModalRoute.of`, `MediaQuery`. **Careful:** can run **multiple times** — avoid starting duplicate network calls or duplicate listeners here; use a flag or move one-shot work to `initState` + post-frame. |
| **`didUpdateWidget`** | Parent rebuilt with **new** `StatefulWidget` configuration | **Do:** compare `oldWidget` vs `widget` and update controllers / restart animations when inputs change. |
| **`deactivate`** | Widget removed from tree (may re-enter) | Rare overrides; tabs / stack may deactivate without dispose. |
| **`dispose`** | Object removed permanently | **Must:** `dispose()` every `AnimationController`, `TextEditingController`, `FocusNode`, `ScrollController`, `TabController`, cancel **subscriptions** and **timers**, **cancel network** (`CancelToken.cancel()`), remove listeners you added. **Never** use `context` after dispose. |

### After `await` — always guard UI updates

```dart
Future<void> _load() async {
  final data = await repository.fetch();
  if (!mounted) return;
  setState(() => _data = data);
}
```

Same idea for **`ValueNotifier.value`**, **`Bloc.add`**, or showing a **`SnackBar`**: if the widget might be gone, check **`mounted`** (or cancel the work) so you do not touch disposed objects or show UI for a popped route.

### `setState` usage

- Call **`setState`** only to change **local** visual state; keep the closure **small** (update fields, not heavy work).
- Do not call `setState` from **`build`** or synchronously from a descendant’s `build`.

### App lifecycle (background / foreground)

When you must **pause timers**, **flush analytics**, or **refresh tokens** on resume, use **`WidgetsBindingObserver`** (`didChangeAppLifecycleState`) on a suitable ancestor or a dedicated binding class — and **remove the observer in `dispose`**.

### Keeping tab / pager state

- **`AutomaticKeepAliveClientMixin`** + `wantKeepAlive` — keeps scroll position and subtree state for off-screen tabs; use **sparingly** (memory cost).

### Keys

- **`ValueKey` / `ObjectKey`** — when the **same** `State` object must reset or move correctly (lists with reorder, conditional editors). Wrong keys cause **wrong state attached to wrong row** bugs.

### Smoothness takeaway

**Smooth** usually means: **no extra rebuilds**, **no work after dispose**, **no duplicate listeners**, and **lifecycle-aware async**. Prefer pushing long-lived logic into **repositories + BLoC** and keeping `State` thin.

---

## `lib/network/` — API layer, Dio, & `RequestBloc` (redundancy-free)

Your project already has a sensible split: **`api_networks/`** (client, constants, endpoints, exceptions) and **`bloc/`** (`RequestBloc`, events, states). Extend it **horizontally** (interceptors, auth) not by copying paste into every feature.

### Responsibilities (single source of truth)

| Piece | Responsibility |
|--------|------------------|
| **`api_constants`** | Base URL, timeouts, default headers — env-specific values via `--dart-define` where appropriate. |
| **`api_endpoints`** | Path strings / templates only — **no** business rules; avoids typos and duplicate literals across repositories. |
| **`api_exception`** | Normalized failure type (message, status code, cause) — map **once** from Dio (your `ApiClient` already centralizes this). |
| **`api_client` / `ApiClient`** | One configured **`Dio`** instance (inject in tests); thin **`get`/`post`** helpers; **never** instantiate a new `Dio` per request in random widgets. |
| **Repositories (feature `data/`)** | Call `ApiClient`, parse models, throw or return **`ApiException`** / domain errors — **widgets never import Dio** directly. |
| **`RequestBloc<T>`** | One-shot **loading / success / failure** UI state for a **`Future<T>`** — reuse instead of reimplementing three states per screen. |
| **`RequestRetryConfig`** | Optional **automatic retries** with backoff for `RequestLoad` / `RequestReload` — safe defaults for reads; override `shouldRetry` for mutations. |

### Smooth & clear network behavior

1. **Cancellation** — Pass **`CancelToken`** from UI/`State` **`dispose`** (or when starting a new search) into repository → `ApiClient`. Cancelled calls should not emit to a disposed `Bloc` or call `setState`.
2. **No duplicate configuration** — Auth header, base URL, and logging live in **one** place: **`InterceptorsWrapper`** on the shared `Dio` (e.g. read token from a `AuthTokenProvider` interface you inject).
3. **Logging** — In **`kDebugMode`**, optional **`LogInterceptor`** / `pretty_dio_logger`; strip or redact bodies in production; **never** log refresh tokens or passwords.
4. **Timeouts** — Keep **`connectTimeout` / `receiveTimeout`** in `ApiConstants`; align with UX (retry messaging vs fast fail).
5. **Parsing** — `response.data` → **feature models** in the **repository** or a dedicated `*Parser`**; keep **`fromJson`** on models; consider **`compute`** for huge JSON (see isolates section).
6. **Errors** — UI listens to **`RequestFailure`** / **`ApiException`** and maps to **one** shared error widget or copy helper — avoid `try/catch` + ad-hoc `SnackBar` in every screen.
7. **`RequestReload`** — Use for pull-to-refresh / manual **Retry** that should repeat the **last** loader (including the **same** `RequestRetryConfig` as the last `RequestLoad`) without duplicating the `Future` in the UI.

### Automatic retry in `RequestBloc` (`RequestRetryConfig`)

The shared **`RequestBloc`** can **re-run the same loader** automatically when a failure looks **transient**, so users see fewer dead ends on flaky mobile networks — without every screen reimplementing loops.

| Piece | Role |
|--------|------|
| **`RequestLoad(..., retry: …)`** | Attach a **`RequestRetryConfig`** next to your `loader`. Default is **`RequestRetryConfig.none`** (single attempt — backward compatible). |
| **`RequestRetryConfig.standardRead`** | Example preset: multiple attempts + **exponential backoff** between tries (tune `maxAttempts` / `baseDelay` for your API). |
| **`RequestRetryConfig` fields** | **`maxAttempts`** (total tries, including the first), **`baseDelay`**, **`exponentialBackoff`**, optional **`shouldRetry(Object error)`** to override classification. |
| **`defaultShouldRetry`** | Conservative rules for **`ApiException`**: retries when **no status** (typical network), **408**, **429**, **5xx**; does **not** retry most **4xx** (client / auth mistakes). |
| **`RequestLoading`** | Exposes **`attempt`** and **`maxAttempts`** so the UI can show subtle copy (e.g. “Still loading…” or a slim progress) when **`attempt > 1`** — feels responsive, not frozen. |

**Safety (very important):**

- **GET-style reads** — Natural fit for **`standardRead`** or similar.
- **POST / PUT / DELETE** — Default to **`RequestRetryConfig.none`** unless the backend is **idempotent** (idempotency key, server-side dedupe) **or** you pass a **`shouldRetry`** that only allows safe cases. Blind retries on payment or “create order” can **duplicate** side effects.
- **Dio interceptor retry vs BLoC retry** — Prefer **one** primary layer to avoid **double** retries. Typical split: **token refresh / 401 once** in an **interceptor**; **transient network / 503** in **`RequestBloc`** *or* in Dio — not both with aggressive defaults.

### Beautiful API flow: triggering, responses, and smooth UI

These patterns keep the app feeling **fast**, **clear**, and **intentional** — not “busy” or noisy.

#### Where each BLoC API belongs

| Tool | Use for |
|------|---------|
| **`BlocBuilder`** | **Rebuild UI** from `RequestState` (spinner, content, error view). Keep the `builder` **pure**: map state → widgets only. |
| **`BlocListener`** | **Side effects**: `SnackBar`, `Navigator.pop`, `HapticFeedback`, one-shot analytics. Runs **once per state change**, not every rebuild. Prefer **`listenWhen`** to ignore duplicate emissions. |
| **`BlocConsumer`** | Same subtree needs **both** rebuild + side effects — combine instead of nesting two widgets deeply. |

#### Triggering requests (clear mental model)

- **Initial load** — `initState` → `add(RequestLoad(...))` **or** parent drives first load; always **`mounted`**-guard after async gaps before UI updates.
- **Pull-to-refresh** — `RefreshIndicator.onRefresh` → **`RequestReload()`** or a fresh **`RequestLoad`** with the same `loader`; complete the refresh future when **`RequestSuccess`** or **`RequestFailure`** arrives (avoid infinite spinner). See also **Catchy & effective data-update patterns** below for more options.
- **User tap “Retry”** — **`RequestReload`** or **`RequestLoad`** with the same `loader`.
- **Search / debounced query** — New query → **cancel** previous **`CancelToken`**, then **`RequestLoad`**; optionally tag responses so **stale** completions do not overwrite newer results.

#### Response handling & perceived performance

- **Skeletons / shimmer** — On **`RequestLoading`**, show **layout-shaped** placeholders instead of a blank screen — users perceive **shorter waits**.
- **Stale-while-revalidate** — If you have **cached** data, show it immediately and optionally refresh in the background so the screen does not **flash empty** on return visits.
- **Optimistic UI (advanced)** — For safe actions (toggle like, delete with undo), update UI **before** the server confirms; **rollback** on failure. Often a **feature Cubit**, not only `RequestBloc`, because you need **pending / rolled-back** states.
- **Success feedback** — Short **haptic** or **SnackBar** only when it **adds clarity** (saved, copied); avoid toasting every background refresh.
- **`RequestLoading.attempt > 1`** — Optional caption (“Reconnecting…”) so **automatic** retries feel honest, not stuck.

#### Coalescing & races

- **Double `RequestLoad`** — Disable the primary button while **`RequestLoading`**, or use **`bloc_concurrency`** (`restartable`, `droppable`) on handlers where appropriate.
- **Stale responses** — For rapid-fire searches, compare **expected query / id** when the `Future` completes before applying data.

#### Errors that should not retry automatically

**401** (go login), **403**, **404**, validation **400** — user needs a **different action**, not another identical request. Override **`shouldRetry`** or handle only in UI.

### Optional upgrades (add when needed)

- **Refresh token interceptor** — On `401`, refresh once, retry request, serialize concurrent refreshes (queue) to avoid storms.
- **Connectivity** — Optional pre-check (`connectivity_plus`) for faster offline messaging; still handle real network failures in Dio.
- **Dio-level retry** — Optional for **GET** only; if enabled, **reduce** `RequestBloc` **`maxAttempts`** or use **`RequestRetryConfig.none`** there to avoid **stacked** retries.
- **Upload / download** — `FormData`, `onSendProgress` / `onReceiveProgress` → `Stream` or Cubit for progress UI.
- **Certificate pinning** — Advanced; platform-specific packages and operational overhead — only if your threat model requires it.

### Anti-patterns (redundancy & jank)

- Creating **`new Dio()`** or **`new ApiClient()`** per repository method.
- Hard-coded **`'/users/123'`** strings in widgets instead of **`ApiEndpoints`** + parameters.
- **`setState` + manual `isLoading` flags** on every screen when **`RequestBloc`** + **`BlocBuilder`** would unify behavior.
- Ignoring **`mounted`** / **`CancelToken`** so late responses update wrong UI or keep sockets busy.

### Folder reminder (your layout)

```
lib/network/
  api_networks/
    api_client/
    api_constants/
    api_endpoints/
    api_exception/
  bloc/
    request_bloc.dart
    request_events.dart
    request_retry_config.dart
    request_states.dart
```

### Offline vs API failure (map errors for the right UI)

- **No route / DNS / socket / “connection refused”** — Usually show **offline / no internet** UX (calm, actionable).
- **HTTP 4xx/5xx with response body** — Show **server / client error** copy; retry only when it makes sense.
- **Timeout** — Can feel like offline to users; message like “This is taking too long” + **Retry**; optionally distinguish from true offline if you track connectivity (see below).

---

## Mobile-first UX and offline / no-internet experience

This app is **mobile-centric first**: small screen, touch, variable networks, interruptions, and one-handed use. Offline UI should feel **intentional**, **reassuring**, and **fast to recover from** — not like a broken app.

### Mobile app theory (keep these in mind)

| Idea | What it means for your UI |
|------|---------------------------|
| **Thumb zone** | Put the **primary action** (e.g. **Retry**, **Try again**) in the **lower half** of the screen on phones; secondary actions (e.g. open Wi‑Fi / settings) as text button or smaller control **above** or beside it. |
| **Clarity over cleverness** | Short **headline** (“You’re offline”) + one line **why** (“Check your connection and try again”). Avoid jargon (“SocketException”, status codes) in the default view. |
| **Interruptibility** | Users leave for messages, calls, low battery. **Persist** scroll position where possible; **don’t lose form input** on transient offline flashes — use debounced connectivity (below). |
| **Trust & calm** | Offline is **normal** on mobile. Use **neutral / informative** colors (surface + on-surface-variant) rather than **error red** for “no network” unless it is truly a blocking failure. Reserve **red** for destructive or hard errors. |
| **One primary CTA** | One obvious **Retry** (filled button). Optional **Open settings** or **Learn more** as secondary. |
| **Feedback < 100 ms perceived** | On Retry tap, show **immediate** inline progress (button loader or small indicator), not a silent wait. |
| **Reachability** | Large phones: consider **safe padding** and **minimum 48×48** touch targets (you already noted a11y elsewhere). |

### Know what “offline” actually is (two layers)

1. **Device radio / link** — Wi‑Fi or mobile data “on” but no internet (captive portal, unpaid bill, router up but no uplink). Packages like **`connectivity_plus`** report **interface** state, not guaranteed internet.
2. **Real reachability** — Can you resolve DNS and reach your API? Sometimes checked with a **lightweight HEAD/GET** to a known URL, or packages such as **`internet_connection_checker`** / similar — understand **battery** and **data** cost; don’t ping every second.

**Practical approach:** Combine **connectivity stream** (fast UI hint) with **failed request** from Dio (ground truth when user acts). **Debounce / hysteresis** (e.g. wait 1–2 s before showing “offline” banner) reduces **flicker** on subway / elevator networks.

### When to show which UI pattern

| Scenario | Pattern |
|----------|---------|
| **First load** and no cache | **Full-screen** offline / error state — centered content, illustration, headline, subtitle, **Retry** at bottom. |
| **List had data**, then connection drops | **Persistent slim banner** under app bar or above bottom nav (“You’re offline · Showing saved data”) + optional snackbar on transition. |
| **User pulls to refresh** while offline | Inline message on refresh control; don’t spin forever — fail fast with clear copy. |
| **Form submit** while offline | Disable submit or show inline helper; **don’t** lose fields — queue or block with clear message. |

### Custom widgets to add under `core/common_widgets` (attractive & reusable)

Build **one design system** for these so every feature looks cohesive.

1. **`OfflineFullScreenView`** (or `NoConnectionView`)  
   - **Optional** `Widget? illustration` (Lottie / SVG / `Icon` from theme) — soft, on-brand, not stock-alarmist.  
   - **`title`**, **`message`** — from **l10n** later.  
   - **`onRetry`** — required; triggers reload / `RequestReload` / repository call.  
   - **`onOpenSettings`** — optional; `app_settings` / `openAppSettings()` pattern on mobile.  
   - **Layout:** vertical `Column` with `MainAxisAlignment.center` + **bottom-aligned** primary button in `SafeArea` (thumb-friendly). Use **`theme.colorScheme.surfaceContainerHighest`** or subtle gradient for depth — avoid flat gray slabs if you want “premium” feel.

2. **`ConnectivityBanner`**  
   - **Animated** show/hide (`AnimatedSlide` + `AnimatedOpacity` or `SizeTransition`) so appearance does not **jank** the layout.  
   - Tappable row: “No connection” + optional **Retry** icon.  
   - Listens to a **`Listenable`** / `Stream` from a small **`ConnectivityService`** in `core/` or injected.

3. **`NetworkErrorSwitcher`** (optional composition widget)  
   - Child = success content; if `RequestFailure` / mapped error is **offline-like**, swap to **`OfflineFullScreenView`**; if server error, swap to **`ErrorStateView`**. Centralizes **classification** once.

### Visual polish (beautiful but on-brand)

- **Typography:** `titleLarge` / `titleMedium` for headline, `bodyMedium` with **`colorScheme.onSurfaceVariant`** for subtitle — hierarchy from **M3 text roles**, not random font sizes.  
- **Spacing:** use your **`AppSpacing`** tokens; generous vertical rhythm (mobile feels “breathable”).  
- **Illustration:** single palette aligned with **`ColorScheme`**; optional **very subtle** `AnimatedOpacity` entrance (200–300 ms) on first show — no distracting loops on every screen.  
- **Dark mode:** test offline screens in **dark** — illustrations often need a **dark variant** or monochrome treatment.  
- **Semantics:** `Semantics(label: …, button: true)` on Retry; consider **`LiveRegion`** or announcement when switching to offline if critical (platform-dependent).

### Wiring to `lib/network/`

- In **`ApiClient`** / Dio mapping, preserve **`DioExceptionType.connectionError`** / **`connectionTimeout`** so repositories can classify **offline-like** failures.  
- Map those to a **domain enum** or flag (`NetworkFailureKind.offline`) in **one** place, then feed **`OfflineFullScreenView`** vs generic error.  
- **`RequestBloc`:** on failure, UI layer (or listener) checks **kind** — don’t duplicate classification in every screen.

### Suggested `core/` support (optional small modules)

- **`ConnectivityService`** — wraps `connectivity_plus` + debounce; exposes `ValueNotifier<ConnectivityUiState>` or `Stream`.  
- **`NetworkStatus`** sealed class — e.g. `online`, `offline`, `unknown` — UI only cares about this, not raw plugin types.  
- **l10n keys** — `offlineTitle`, `offlineBody`, `retry`, `openSettings`, `offlineBanner` — keep copy out of widgets.

### Pitfalls on mobile

- Showing **offline** the instant Wi‑Fi blips — **debounce**.  
- Assuming **connectivity_plus == has internet** — **it does not**; still handle Dio errors.  
- **Blocking** the whole app with a modal when a **banner** is enough if cached content exists.  
- **Retry storm** — disable **Retry** while a request is in flight or use **exponential backoff** for background retries.

---

## Catchy & effective data-update patterns (beyond pull-to-refresh)

Pull-to-refresh is familiar and good — but **mobile apps feel premium** when updates are **easy to discover**, **low-friction**, and **well-timed**. Combine a few patterns; **don’t** fire refresh from every surface at once (battery + server load).

### Native-feeling pull / overscroll

- **`RefreshIndicator.adaptive`** — Picks **Material** vs **Cupertino** style where appropriate so the gesture matches platform expectations.
- **`CupertinoSliverRefreshControl`** — When you use **sliver** scroll views, match **iOS** bounce + refresh affordance for a native feel.
- **Nested scroll views** — Ensure only **one** refresh controller “owns” the overscroll gesture; avoid fighting **inner** vs **outer** scrollables.

### Obvious, tappable “refresh” affordances

| Pattern | Why it works on mobile |
|---------|-------------------------|
| **AppBar `IconButton` (refresh)** | Discoverable; pair with a short **`RotationTransition`** while **`RequestLoading`** so the icon feels **alive**, not dead. |
| **“Updated · tap to refresh” chip** | Small **`ActionChip`** / text under the title showing **relative time** (`intl` / `timeago`) — teaches users that data can be **stale** and gives a **one-tap** refresh without scrolling. |
| **FAB / speed dial “Sync”** | For **dashboard** or **inbox** metaphors where “sync everything” is a mental model users already have. |
| **Empty / error state CTA** | **“Try again”** is a refresh trigger — same as **`RequestReload`**; make it **large** and in the **thumb zone**. |
| **`SnackBar` with `action: Text('Refresh')`** | After a **soft failure** or “couldn’t refresh” message — recovery without leaving context. |

### Lifecycle- and context-aware refresh (feels smart, not random)

- **Resume from background** — On **`AppLifecycleState.resumed`** (`WidgetsBindingObserver`), run a **light** **`RequestReload`** for the **currently visible** tab/screen only — users expect **fresh** data when returning from another app. **Debounce** (e.g. skip if resumed less than 30s ago) to save battery.
- **Tab / page focus** — When the user **lands** on a tab they have not opened in a while, **one** silent or soft refresh (optional banner “Updating…”) — feels proactive.
- **Connectivity restored** — When moving **offline → online**, auto **`RequestReload`** **once** (with debounce) or show a **single** snackbar “Back online · Refreshing” — very **catchy** when done calmly, annoying if it fires every second on flaky Wi‑Fi.

### Infinite scroll & prefetch (keeps feeds feeling “alive”)

- **Load next page near the end** — Trigger when the user is **~3–5 items** from the bottom (`ScrollController` / `NotificationListener`) — smoother than a hard “Load more” button for feeds.
- **Prefetch next screen** — When user **hovers intent** (e.g. long-press preview, or navigates with high confidence), prefetch **detail** in the background — **perceived** instant open (still show skeleton if slow).

### Visual payoff when data changes (makes updates feel intentional)

- **`AnimatedSwitcher`** — Swap summary numbers or header text when new payload arrives — subtle **delight** without distraction.
- **List diff / `AnimatedList`** — Insert or remove rows with **short** animations when items appear/disappear (keep performant; don’t animate huge lists wholesale).
- **Brief success pulse** — **HapticFeedback.lightImpact** + optional **check icon** flash on successful **manual** refresh — reinforces “it worked” (use sparingly).

### Live & push-driven updates (when product needs it)

- **WebSocket / SSE / FCM** — **Badge** or **dot** on tab bar when new data arrived in background; tap tab to see — avoids **interrupting** the current screen with a dialog.
- **“Live” or “Streaming” pill** — Small **tonal chip** when connected to a live source — sets expectations (may jitter; user accepts).

### What usually *not* to do

- **Auto full-screen refresh** every N seconds — drains battery; prefer **user gesture**, **resume**, or **push**.
- **Multiple simultaneous refresh entry points** firing the **same** heavy API without **dedupe** — coordinate in repository or bloc.
- **Spinners everywhere** — Prefer **skeleton**, **inline progress**, or **refresh icon** rotation over blocking the whole screen for small updates.

### Wiring to your stack

- Almost all triggers above still boil down to **`RequestLoad`** / **`RequestReload`** / **`RequestRetryConfig`** + optional **`CancelToken`** — keep **one** pattern in the BLoC layer and vary only **what** calls `add(...)`.

---

## Animations & motion

### Layers (pick the smallest that works)

1. **Implicit animations** — `AnimatedOpacity`, `AnimatedSwitcher`, `AnimatedSize`, `AnimatedPadding` — no `Ticker`; great for show/hide and simple transitions.
2. **`AnimationController` + `Tween`** — Full control, **must** `dispose` the controller; use `SingleTickerProviderStateMixin` / `TickerProviderStateMixin`.
3. **`TweenAnimationBuilder`** — Good middle ground for one-off animations.
4. **Hero** — Between routes; mind **nested navigators** and matching tags.
5. **Authoring tools** — **Lottie**, **Rive** for marketing-grade motion; watch asset size and initialization cost.

### Performance

- Prefer animating **cheap properties** (opacity, transform) over **layout-changing** properties every frame if possible.
- Use **`Curves`** from your `ui_constants` / theme for consistent motion.
- For lists, avoid per-item `AnimationController` explosion — stagger or animate only visible items.

### Where to centralize

- **Durations & curves** — `ui_constants` (you already planned this).
- **Shared transitions** — `PageTransitionsTheme` or your GetX `customTransition` at the router level.
- **Reusable animated widgets** — `core/common_widgets/animations/` when the same pattern appears twice.

---

## Routing & passing data between screens

You are using **GetX** (`Get.toNamed`, `arguments`, etc.). Principles below apply to **any** router (`go_router`, Navigator 2.0, etc.).

### Recommended patterns (best → acceptable)

1. **Pass an ID (or minimal key), load data on the destination**  
   - **Pros:** Single source of truth, works with deep links, less stale data, smaller route payload.  
   - **Example:** `Get.toNamed(AppRoutes.profile, arguments: userId);` then `ProfileRepository.getUser(userId)`.

2. **Pass an immutable “args” object (small)**  
   - **Pros:** Type-safe bundle of primitives / small DTO.  
   - **Cons:** If the object is large or mutable, you duplicate state and complicate back-stack restoration.  
   - **Pattern:** `class ProfileRouteArgs { final String userId; const ProfileRouteArgs({required this.userId}); }`

3. **Global / scoped service**  
   - Register a **repository** or **session holder** with GetX/`Get.put` / `Provider`; screens read from it. Good for **auth user**; avoid dumping **everything** there.

4. **Avoid** passing **mutable singletons** or **BuildContext** across routes.

### GetX specifics

- **`Get.parameters`** / **path parameters** — Good for REST-style routes (`/user/:id`) if you adopt path-based routes.
- **`Get.arguments`** — Fine for small payloads; cast safely (your `tryCast` or a typed helper).
- **Result back to previous screen** — `Get.back(result: value)` / `await Get.toNamed(...)` and read the returned value; document the contract.

### Deep linking & web

- If you later support **web** or **universal links**, **IDs in the URL** beat opaque blobs in `arguments`. Plan route names and parameters accordingly.

---

## Local persistence: SharedPreferences → SQLite / Drift

### SharedPreferences (simple key–value)

- **Use for:** flags, last-selected tab, small strings, lightweight caches.
- **Avoid for:** large structured data, relational queries, high write volume.

**Generic reusable pattern (conceptual):**

- **`AppPrefsKeys`** — `static const String onboardingDone = 'onboarding_done';`
- **`PrefsService` interface** — `Future<bool?> getBool(String key);`, `Future<void> setBool(String key, bool value);`
- **Implementation** — wraps `shared_preferences`; inject in tests with in-memory fake.
- **Typed wrappers (optional)** — `class BoolPref { BoolPref(this._prefs, this.key); ... }` to avoid repeating key strings.

For **sensitive** tokens (refresh tokens), prefer **`flutter_secure_storage`** (or platform vault), not plain prefs.

### SQLite / local database (structured data)

When you outgrow prefs:

- **[Drift](https://pub.dev/packages/drift)** (recommended by many teams) — SQL with generated queries, streams, migrations.
- **`sqflite`** — Lower level; you own SQL strings and migrations.
- **Isar** — Document/object store; great for some offline-first models; different trade-offs than SQL.

**Architecture:** Keep **DAO / local data source** behind a **repository** so UI and BLoC stay the same whether data is remote or local.

### Isolate note for DB

- Drift can use **isolates** for some work in advanced setups; start with the package’s recommended default and optimize when profiling shows DB on UI thread.

---

## Staying current with Flutter (scope & habits)

Flutter moves fast; “best” changes with the SDK. Use these habits so the codebase does not drift:

### Official sources (bookmark)

- **[Flutter release notes](https://docs.flutter.dev/release/release-notes)** — Breaking changes, new APIs.
- **[Flutter breaking changes](https://docs.flutter.dev/release/breaking-changes)** — Migration guides.
- **[Dart changelog](https://dart.dev/changelog)** — Language and core library updates.
- **Flutter / Dart YouTube & blog** — High-level announcements (verify in docs before large refactors).

### Material & rendering

- **Material 3** — `useMaterial3: true`, dynamic color (Android), component themes — align new UI with M3 where possible.
- **Impeller** — On many platforms Flutter uses **Impeller** instead of Skia for rendering; shader/jank characteristics differ — profile on **real devices**, especially iOS and mid-range Android.

### Language features (use when they simplify code)

- **Records, pattern matching, sealed classes** — Great for **states**, **events**, and **Result** types (`RequestState` style).
- **`class` modifiers** (`final class`, `interface class`) — Where you want clear extension points.
- **Dart 3 null safety** — Stay strict; avoid `!` spikes.

### Packages

- Run **`flutter pub outdated`** regularly; pin major versions in `pubspec` and read changelogs before jumping majors.
- Prefer **well-maintained** packages (issue velocity, Dart 3 support).

### Quality gates

- **`flutter analyze`** in CI (treat warnings consciously).
- **Tests** — At least smoke + critical repository logic; golden tests optional for UI stability.
- **Format** — `dart format` in CI or pre-commit.

### Web & desktop (if in scope)

- **Web:** different performance profile (canvaskit vs skwasm vs HTML renderer — follow current Flutter docs for your target).
- **Desktop:** menu shortcuts, window management, different input — plan `core/platform/` splits when you ship there.

---

## Quick checklist before adding a new common widget

- [ ] Used (or clearly will be used) in more than one feature?
- [ ] Styled from theme / tokens, not magic numbers?
- [ ] Documented parameters (what is required vs optional)?
- [ ] Handles loading / disabled / error states if it triggers async work?
- [ ] Accessible (semantics, contrast, touch target)?
- [ ] Works in light and dark mode?

## Performance & architecture checklist (periodic review)

- [ ] No heavy sync work in `build` / layout / paint?
- [ ] Lists are virtualized (`builder` / slivers)?
- [ ] **`StatefulWidget`:** every `initState` / listener has a matching **`dispose`** (controllers, focus, scroll, tab, animation, timers, subscriptions)?
- [ ] After **`await`**, UI updates guarded with **`mounted`** (or cancellation) where the widget can pop?
- [ ] **`didChangeDependencies`** does not start duplicate loads or duplicate listeners?
- [ ] Controllers, `AnimationController`, and stream subscriptions **disposed**?
- [ ] Network calls **cancellable** (`CancelToken`) or guarded after **`dispose`**?
- [ ] **Single** configured `ApiClient` / `Dio`; endpoints and error mapping **centralized** (`lib/network/`)?
- [ ] Widgets do **not** import Dio directly — only **repositories**?
- [ ] **Offline / no internet:** dedicated calm UI (banner vs full-screen), **debounced** connectivity, **Dio** failures classified — not the same as generic server error?
- [ ] **`RequestRetryConfig`:** used for **reads** where appropriate; **mutations** default **`none`** or custom **`shouldRetry`** — no **double** retry stack with Dio?
- [ ] **BLoC UI:** **`BlocBuilder`** for layout, **`BlocListener`** / **`listenWhen`** for **SnackBar** / navigation — not side effects inside `builder`?
- [ ] **Data updates:** more than pull-to-refresh where it helps (resume refresh, **Updated · tap to refresh**, infinite-scroll prefetch) — **debounced**, no duplicate storms, **adaptive** overscroll where appropriate?
- [ ] Large parsing considered for **`compute`** / isolate?
- [ ] Navigation passes **IDs** or small immutable args, not huge graphs?
- [ ] Persistence abstracted (interface + impl) for testing and future DB swap?

---

*Treat this file as a living checklist: extend it as your product, design system, and Flutter SDK evolve.*
