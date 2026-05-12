# ``Coproduct_Primitives``

@Metadata {
    @DisplayName("Coproduct Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

The n-ary coproduct type for typed sum values across an arbitrary number of arms.

## Overview

`Coproduct Primitives` ships ``Coproduct_Primitives/Coproduct``, a generic
enum representing the categorical n-ary coproduct
`Element₀ + Element₁ + … + Elementₙ₋₁`, the dual of
``Product_Primitives/Product``. Where `Product` holds *all* values,
`Coproduct` holds *exactly one*. Generalises
``Either_Primitives/Either`` (binary coproduct) to arbitrary arity over a
parameter pack.

`Coproduct` is conditionally `Sendable`, `Equatable`, `Hashable`,
`Comparable`, `CustomStringConvertible`, `Encodable`, and `Decodable`,
and conforms to `Swift.Error` when every arm is itself an `Error` —
useful for typed multi-cause errors on the input side of a throw (the
dual of `Product`'s multi-cause aggregation). Under Swift < 6.4 it
additionally conforms to `Equation.Protocol`, `Hash.Protocol`, and
`Comparison.Protocol` per SE-0499 (under Swift 6.4+ those are typealiases
to the stdlib protocols).

## Source gating

All declarations in this target are inside `#if hasFeature(VariadicEnum)`.
Swift 6.3.1 and Swift 6.4-dev reject parameter-pack enum cases with the
`enum_with_pack` diagnostic ("enums cannot declare a type pack" — see
`swift/test/Generics/variadic_generic_types.swift`); on these toolchains,
importing `Coproduct_Primitives` resolves to zero public symbols and the
package builds clean. The API documented in these pages activates only
when an upstream toolchain defines `VariadicEnum` (or an equivalently-named
gate).

## Lifecycle: movement, not management

`Coproduct` is a *movement vehicle* — it transports one of N alternative
values. It does NOT close, unlock, or otherwise act on its arm on drop.
Lifecycle decisions belong to the consumer, typically via `fold` or
`value(of:)` extraction.

## ~Escapable arms

Each arm carries `~Copyable & ~Escapable` suppressions on the pack
constraint. Parameter packs do not yet admit `each T: ~Copyable` or
`each T: ~Escapable` in Swift 6.3.1 or 6.4-dev; the same cohort blocker
gates ``Product_Primitives/Product`` from move-only arms. Closure-bearing
methods (`map`, `fold`, `flatMap`) admit `~Escapable` on the
un-transformed arms only.

## Topics

### The Coproduct

- ``Coproduct_Primitives/Coproduct``

### Cohort

- ``Either_Primitives/Either`` — binary coproduct
- ``Pair_Primitives/Pair`` — binary product
- ``Product_Primitives/Product`` — n-ary product
