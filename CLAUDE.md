# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

XCoordinator is a Swift navigation framework implementing the **Coordinator pattern** for iOS/tvOS/visionOS. It provides type-safe route-based navigation with support for UIKit container controllers (Navigation, TabBar, Split, Page). This is a **fork** of [QuickBirdEng/XCoordinator](https://github.com/QuickBirdEng/XCoordinator) with automatic upstream sync.

## Build & Test Commands

```sh
# Build (SPM)
swift build 2>&1 | xcsift

# Run all tests
swift test 2>&1 | xcsift

# Build script (targets iOS 13 simulator)
bash Scripts/build.sh
```

Platform targets: iOS 13+, tvOS 13+, visionOS 1+ (defined in Package.swift, swift-tools-version 5.9).

## Package Structure

Three library products (all in `Sources/`):
- **XCoordinator** — Core library, zero external dependencies
- **XCoordinatorRx** — RxSwift extensions (`Router+Rx.swift`), depends on RxSwift 6.x
- **XCoordinatorCombine** — Combine extensions (`Router+Combine.swift`), system framework only

Test target: `XCoordinatorTests` (depends on XCoordinator + XCoordinatorRx).

## Architecture

### Protocol Hierarchy

```
Presentable              → Has a viewController, lifecycle hooks
  └─ Router<RouteType>   → trigger(_:) / contextTrigger(_:with:completion:)
       └─ TransitionPerformer<TransitionType>  → performTransition(_:with:completion:)
            └─ Coordinator<RouteType, TransitionType>  → prepareTransition(for:) + completeTransition(for:)
```

The core contract: a `Coordinator` maps `Route` enums to `Transition` structs via `prepareTransition(for:)`.

### Coordinator Class Hierarchy

`BaseCoordinator<RouteType, TransitionType>` is the open base class. Specialized subclasses bind the `TransitionType` to specific UIKit containers:

| Class | TransitionType | Root ViewController |
|---|---|---|
| `NavigationCoordinator<R>` | `NavigationTransition` | `UINavigationController` |
| `TabBarCoordinator<R>` | `TabBarTransition` | `UITabBarController` |
| `SplitCoordinator<R>` | `SplitTransition` | `UISplitViewController` |
| `PageCoordinator<R>` | `PageTransition` | `UIPageViewController` |
| `ViewCoordinator<R>` | `ViewTransition` | `UIViewController` |

`BasicCoordinator` allows closure-based coordinator creation without subclassing. `RedirectionRouter` redirects child routes to a parent router.

### Transition System

`Transition<RootViewController>` is a struct wrapping a perform closure. Transitions are built using **`@TransitionBuilder`** (a result builder) or composed from `TransitionComponent` structs:

- **Navigation**: `Push`, `Pop`, `SetAll` (setViewControllers)
- **View**: `Present`, `Embed`, `Show`, `ShowDetail`, `Dismiss`, `Perform`, `Redirect`, `Trigger`, `RegisterPeek`
- **Tab**: `SelectTab`, `SetTabs`
- **Split**: `SplitSetAll`, `SplitSetColumn`
- **Page**: `PageSet`
- **Composition**: `TransitionGroup` (multiple transitions)

Each component lives in its own file under `Transitions/Components/View/` or the relevant coordinator subdirectory.

### Router Abstractions

- `StrongRouter<RouteType>` — Retains the coordinator (use in AppDelegate or for child coordinator references)
- `UnownedRouter<RouteType>` — Unowned reference (use in ViewModels/ViewControllers to avoid retain cycles)

### Deep Linking

`DeepLinking.swift` provides `DeepLink<RootViewController, CoordinatorType>` — a `TransitionComponent` that chains routes across coordinator boundaries by traversing the presentable hierarchy.

### Async Support

`Router` has `async` extensions (Swift 5.5.2+/iOS 13+) for `trigger` and `contextTrigger`, marked `@MainActor`.

### Conditional Compilation

All UIKit-dependent code is wrapped in `#if canImport(UIKit)` for visionOS compatibility. This guard is required for any new source files.

## Key Conventions

- **Route**: Always an `enum` conforming to the empty `Route` protocol
- **One coordinator per navigation container**: Create a new Route/Coordinator when introducing a new root view controller
- **`@MainActor`**: Core protocols (`Coordinator`, `Router`, `TransitionPerformer`, `Presentable`) and `TransitionBuilder` are `@MainActor`-annotated
- **File organization**: Each `TransitionComponent` gets its own file; coordinator specializations are grouped by UIKit container type (Navigation/, Tab/, Split/, Page/)
