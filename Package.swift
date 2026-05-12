// swift-tools-version: 6.3.1

import PackageDescription

// swift-coproduct-primitives ships EVERGREEN-SPECULATIVE sources guarded by
// `#if hasFeature(VariadicEnum)`. The package occupies the missing-fourth-
// corner of the institute composition matrix:
//
//                binary       n-ary
//   product   →  Pair      ·  Product
//   coproduct →  Either    ·  Coproduct  ← this package, evergreen-gated
//
// Today's Swift compilers do not define `VariadicEnum`; the gate evaluates
// to `false` and the target's source files contribute zero public symbols.
// The library product still exists so consumers can pre-wire the dependency
// without committing to a today-feasible workaround.
//
// Implementation is blocked by two Swift-language constraints documented in
// `Research/coproduct-primitive-design-and-blockers.md`:
//
//   1. Parameter-pack enum cases are not supported (no
//      `enum E<each T> { case at(each T) }` form). The natural shape of
//      an n-ary coproduct is a parameter-pack-variadic enum; today's Swift
//      cannot express it.
//
//   2. Parameter packs do not admit `~Copyable` / `~Escapable` requirements
//      on `each` constraints. The package inherits the same cohort blocker
//      that gates `swift-product-primitives` from move-only arms
//      (cross-reference: `swift-product-primitives/Research/escapable-blocked.md`).
//
// When upstream lifts either blocker, this file's gate name and source
// files may need a small adjustment to match shipped feature flags and
// pattern-match syntax. The evergreen contract: one identifier to update
// per gate, no API redesign required.

let package = Package(
    name: "swift-coproduct-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Coproduct Primitives",
            targets: ["Coproduct Primitives"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-equation-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-hash-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-comparison-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Coproduct Primitives",
            dependencies: [
                .product(name: "Equation Primitives", package: "swift-equation-primitives"),
                .product(name: "Hash Primitives", package: "swift-hash-primitives"),
                .product(name: "Comparison Primitives", package: "swift-comparison-primitives"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
