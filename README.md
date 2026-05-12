# Coproduct Primitives

![Development Status](https://img.shields.io/badge/status-experimental-red.svg)

`Coproduct<each Element>` — the n-ary coproduct type, a generic sum that holds exactly one value out of an arbitrary list of types. Where `Either` is the binary coproduct, `Coproduct` is its variadic generalization; the dual of `Product`'s n-ary cartesian product.

**Evergreen-gated experiment.** The natural Swift shape of `Coproduct<each Element>` requires two language features that have not yet shipped: parameter-pack enum cases (Blocker 1) and pack-element `~Copyable` / `~Escapable` admission (Blocker 2). Rather than ship a today-feasible workaround whose vocabulary consumers would later have to migrate off of, this package commits the full natural-shape source files behind `#if hasFeature(VariadicEnum)`. Today's compilers do not define `VariadicEnum`; the gate evaluates to `false`, the target compiles to zero public symbols, and the package builds clean. When upstream Swift lands the missing pieces, the gate flips and the API ships. See `Research/coproduct-primitive-design-and-blockers.md` for the blocker survey.

---

## Quick Start

The API surface below is the **perfect-future shape** captured today as evergreen source. The code does not compile until the upstream feature gate lands; the snippets serve as a publication contract for the API consumers will see once it ships.

```swift
import Coproduct_Primitives

// arity-3 coproduct over three error domains
let result: Coproduct<Lex.Error, Parse.Error, Validation.Error> =
    .at(Parse.Error.unexpectedToken)

// catamorphism — exactly one handler runs
let message = result.fold(
    { lex in "lex: \(lex)" },
    { parse in "parse: \(parse)" },
    { validation in "validation: \(validation)" }
)
// "parse: ..."
```

### Multi-cause typed throws on the input side

```swift
enum Lex        { struct Error: Swift.Error {} }
enum Parse      { struct Error: Swift.Error {} }
enum Validation { struct Error: Swift.Error {} }

// Throws one of three error types — dual of Product's multi-cause aggregation.
func parse(_ s: String) throws(Coproduct<Lex.Error, Parse.Error, Validation.Error>) -> AST {
    // ... throw .at(Parse.Error.unexpectedToken) ...
}
```

### Transforming the active arm

```swift
let c: Coproduct<Int, String, Bool> = .at("hi")

let transformed = try c.map(
    { $0 + 1 },             // arm 0
    { $0.uppercased() },    // arm 1 — runs, only this position is active
    { !$0 }                 // arm 2
)
// Coproduct<Int, String, Bool> = .at("HI")
```

### Never elimination

When every arm but one is `Never`, the inhabited value extracts unconditionally:

```swift
let c: Coproduct<Never, Int, Never> = .at(42)
let v = value(of: c)   // 42 — every other arm is uninhabited
```

### Lifecycle and ~Escapable arms

`Coproduct` is a *movement vehicle* — it transports one of N alternative values. It does not close, unlock, or otherwise act on its arm on drop; lifecycle decisions belong to the consumer, typically via `fold` or `value(of:)` extraction.

Every arm may be `~Copyable` and `~Escapable` once Blocker 2 lifts — mirroring `Either`'s move-only-arm contract. Non-closure operations (`.at(...)` injection, binary `swapped(_:)`, `value(of:)` for single-arm-inhabited packs, institute-protocol conformances) admit `~Escapable` arms; closure-bearing methods (`map`, `fold`, `flatMap`) admit `~Escapable` on the un-transformed arms only, mirroring `Either`'s Gap-A closure constraint.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-primitives/swift-coproduct-primitives.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Coproduct Primitives", package: "swift-coproduct-primitives"),
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the matching Linux / Windows toolchain). **Today, importing `Coproduct_Primitives` yields zero public symbols** — the gate is `false` everywhere. Consumers can pre-wire the dependency without committing to the today-feasible workarounds; the import becomes load-bearing automatically when the gate fires upstream.

---

## Architecture

One library product, one target.

| Product | Target | Contents |
|---------|--------|----------|
| `Coproduct Primitives` | `Sources/Coproduct Primitives/` | `Coproduct<each Element>` (variadic over parameter packs) + n-ary `fold` / `map` / `flatMap` instance + static methods + free `swapped(_:)` for n=2 + free `value(of:)` for single-arm-inhabited packs + conditional `Sendable` / `Equatable` / `Hashable` / `Comparable` / `CustomStringConvertible` / `Encodable` / `Decodable` / `Swift.Error` conformances. **All gated `#if hasFeature(VariadicEnum)`.** |

Conditional `Equation.Protocol`, `Hash.Protocol`, and `Comparison.Protocol` conformances are gated `#if swift(<6.4)` per SE-0499; under Swift 6.4+, those institute protocols are typealiases to the stdlib counterparts and the existing stdlib conformances satisfy them automatically.

Dependencies: `swift-equation-primitives`, `swift-hash-primitives`, `swift-comparison-primitives`. Foundation-free.

### Speculative anchors

Each speculative bit is a one-identifier patch at unblock time. See `Research/coproduct-primitive-design-and-blockers.md` § "Evergreen-sources path" for the full table.

| What | Today's spelling | Mechanism on unblock |
|---|---|---|
| Gate name | `#if hasFeature(VariadicEnum)` | Whatever `Features.def` names the flag |
| Case spelling | `case at(each Element)` | The natural-shape best guess |
| Pack-eliminator dispatch | `(each handlers)(consume value)` | Awaits shipped pack-position-aware dispatch syntax |
| Pack equality | `repeat each Element == FirstElement` / `repeat each Other == Never` | Parses today; semantics follow Evolution |

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |
| Swift Embedded | Supported (`Codable` is `#if !hasFeature(Embedded)` gated) |

The feature gate is uniform across platforms; the package builds clean everywhere today and activates the API surface everywhere simultaneously when upstream lands the missing language pieces.

---

## Related Packages

### Dependencies

- [swift-equation-primitives](https://github.com/swift-primitives/swift-equation-primitives) — institute `Equation.Protocol`.
- [swift-hash-primitives](https://github.com/swift-primitives/swift-hash-primitives) — institute `Hash.Protocol`.
- [swift-comparison-primitives](https://github.com/swift-primitives/swift-comparison-primitives) — institute `Comparison.Protocol`.

### Cohort siblings

- [swift-pair-primitives](https://github.com/swift-primitives/swift-pair-primitives) — binary product.
- [swift-either-primitives](https://github.com/swift-primitives/swift-either-primitives) — binary coproduct.
- [swift-product-primitives](https://github.com/swift-primitives/swift-product-primitives) — n-ary product.

---

## Community

<!-- BEGIN: discussion -->
Discuss this package: [swift-institute/discussions/26](https://github.com/orgs/swift-institute/discussions/26)
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
