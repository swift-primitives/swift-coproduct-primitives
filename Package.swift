// swift-tools-version: 6.3.3

import PackageDescription

// swift-coproduct-primitives — n-ary coproduct primitive.
//
// All source declarations are guarded `#if hasFeature(VariadicEnum)`.
// Swift 6.3.1 and Swift 6.4-dev do not define the feature; the target
// emits zero public symbols on these toolchains.
//
// Two compiler constraints block activation, documented in
// `Research/coproduct-primitive-design-and-blockers.md`:
//
//   1. Parameter-pack enum cases are rejected by the `enum_with_pack`
//      diagnostic. See `swift/test/Generics/variadic_generic_types.swift`.
//
//   2. Parameter packs do not admit `~Copyable` / `~Escapable`
//      requirements on `each` constraints. See
//      `swift/test/Generics/inverse_copyable_requirement_errors.swift`
//      (`packingUniqueHeat_*`). The same blocker gates
//      `swift-product-primitives` from move-only arms.

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
        .testTarget(
            name: "Coproduct Primitives Tests",
            dependencies: [
                "Coproduct Primitives",
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
