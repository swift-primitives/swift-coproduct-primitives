# ``Coproduct_Primitives``

@Metadata {
    @DisplayName("Coproduct Primitives")
    @TitleHeading("Swift Institute — Primitives Layer")
}

The n-ary coproduct type — the missing fourth corner of the typed-composition cohort.

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
and conforms to `Swift.Error` when every arm is itself an `Error` — useful
for typed multi-cause errors on the input side of a throw (the dual of
`Product`'s multi-cause aggregation). Under Swift < 6.4 it additionally
conforms to `Equation.Protocol`, `Hash.Protocol`, and `Comparison.Protocol`
per SE-0499 (under Swift 6.4+ those are typealiases to the stdlib protocols).

## Status: evergreen-speculative

The natural Swift shape of `Coproduct<each Element>` is gated on two
upstream Swift Evolution items that have not landed yet:

1. **Parameter-pack enum cases**: enums declaring `case at(each Element)`
   pack-expansion. Today the compiler rejects with `enum_with_pack`
   ("enums cannot declare a type pack").
2. **Pack-element suppression**: `each T: ~Copyable` / `each T: ~Escapable`
   constraints on pack parameters. Today the compiler rejects with
   "cannot suppress '~Copyable' on type 'each T'".

This package ships its source files behind a `#if hasFeature(VariadicEnum)`
gate. Today the gate is `false` and the target exports zero public symbols.
When upstream defines the feature (or an equivalently-named gate), the
files activate and the package ships its API. See
`Research/coproduct-primitive-design-and-blockers.md` for the full survey.

## Lifecycle: movement, not management

`Coproduct` is a *movement vehicle* — it transports one of N alternative
values. It does NOT close, unlock, or otherwise act on its arm on drop.
Lifecycle decisions belong to the consumer, typically via `fold` or
`value(of:)` extraction.

## ~Escapable arms

Every arm may be `~Copyable` and `~Escapable`. Non-closure operations —
construction (`.at(...)`), the binary `swapped(_:)` free function, the
`value(of:)` free function for one-arm-inhabited packs, and the institute-
protocol conformances (`Equation.Protocol`, `Hash.Protocol`,
`Comparison.Protocol`) — admit `~Escapable` arms when the secondary
blocker lifts. Closure-bearing methods (`map`, `fold`, `flatMap`) admit
`~Escapable` on the un-transformed arms only, mirroring `Either`'s closure
constraint.

## Topics

### The Coproduct

- ``Coproduct_Primitives/Coproduct``

### Cohort

- ``Either_Primitives/Either`` — binary coproduct
- ``Pair_Primitives/Pair`` — binary product
- ``Product_Primitives/Product`` — n-ary product
