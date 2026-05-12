// Coproduct.swift
// The n-ary coproduct type — the missing fourth corner of the typed-composition
// cohort (`Pair` / `Either` / `Product` / `Coproduct`).
//
// EVERGREEN-SPECULATIVE. The body of this file is gated on
// `#if hasFeature(VariadicEnum)`. Today's Swift compilers do not define
// `VariadicEnum`; `hasFeature(VariadicEnum)` returns `false` and this file's
// body is skipped at parse time. The target compiles to zero public symbols,
// the package builds clean, and consumers can pre-wire the dependency without
// committing to a today-feasible workaround.
//
// When upstream Swift admits parameter-pack enum cases (Blocker 1) AND lifts
// pack-element suppression (Blocker 2), this file's body activates and the
// package ships its first public API. The gate name is the research doc's
// hypothetical canary (`swift/include/swift/Basic/Features.def`); if upstream
// names the feature differently, the gate identifier is the only thing that
// needs to change.
//
// Speculative components (likely to need adjustment at unblock time):
//   1. Case spelling for pack-position injection (`case at(each Element)` —
//      the natural-shape best guess; actual syntax follows shipping evolution).
//   2. Pack-position dispatch inside eliminators (`fold`, `map`, `flatMap`)
//      depends on however the compiler exposes "active arm's position".
//   3. The `~Copyable & ~Escapable` suppressions on `each Element` (Blocker 2)
//      may need to be removed if only Blocker 1 lifts first; in that case the
//      package ships in Stage 1 shape (Copyable & Escapable arms only) until
//      Blocker 2 also clears.
//
// See `Research/coproduct-primitive-design-and-blockers.md` for the full
// blocker survey and the rationale for shipping evergreen sources behind a
// feature gate rather than shipping a today-feasible workaround.

#if hasFeature(VariadicEnum)

@_exported public import Comparison_Primitives
@_exported public import Equation_Primitives
@_exported public import Hash_Primitives

/// A value of one of N types — the n-ary coproduct.
///
/// `Coproduct<each Element>` represents the categorical n-ary coproduct
/// `Element₀ + Element₁ + … + Elementₙ₋₁`, the dual of the n-ary product
/// `Product<each Element>` (which holds *all* values). `Coproduct` holds
/// *exactly one*.
///
/// Generalises `Either<Left, Right>` (binary coproduct) to arbitrary arity in
/// the same way `Product<each Element>` generalises `Pair<First, Second>` to
/// arbitrary arity. The injection `.at(value)` at pack position `k` builds a
/// `Coproduct` carrying `Element_k`; the eliminator
/// ``fold(_:)`` collapses it to a single result by dispatching to the
/// position-matched handler.
///
/// ## Example
///
/// ```swift
/// // arity-3 coproduct over three error domains
/// let result: Coproduct<Lex.Error, Parse.Error, Validation.Error> =
///     .at(Parse.Error.unexpectedToken)   // injection at arm 1
///
/// result.fold(
///     { lex in "lex: \(lex)" },
///     { parse in "parse: \(parse)" },
///     { validation in "validation: \(validation)" }
/// )
/// // "parse: ..." — only the arm-1 handler runs
/// ```
///
/// Five concrete consumer shapes motivate the n-ary case: multi-cause typed
/// throws on the input side (`throws(Coproduct<E1, E2, E3>)`), parser
/// combinator alternatives, state-machine output types, pipeline stage
/// dispatch, and DSL AST node sums. See `<doc:Coproduct-and-Nested-Either>`
/// for the trade-off discussion.
///
/// ## Type-level constraints
///
/// `Coproduct` suppresses `Copyable` and `Escapable` on every pack element,
/// mirroring `Either`:
///
/// ```swift
/// public enum Coproduct<each Element: ~Copyable & ~Escapable>: ~Copyable, ~Escapable
/// ```
///
/// Every arm may hold non-copyable resources or non-escapable views. The
/// conformance ladder mirrors stdlib `Result.swift` extended over the pack:
///
/// | Conformance              | Constraint                                                              |
/// |--------------------------|-------------------------------------------------------------------------|
/// | `Copyable`               | `repeat each Element: Copyable & ~Escapable`                            |
/// | `Escapable`              | `repeat each Element: Escapable & ~Copyable`                            |
/// | `Sendable`               | `repeat each Element: Sendable & ~Copyable & ~Escapable`                |
/// | `BitwiseCopyable`        | `repeat each Element: BitwiseCopyable`                                  |
/// | `Equatable`              | `repeat each Element: Equatable` (admits `~Copyable` arms via SE-0499) |
/// | `Hashable`               | `repeat each Element: Hashable` (admits `~Copyable` arms via SE-0499)  |
/// | `Codable`                | `repeat each Element: Codable` (gated on `!hasFeature(Embedded)`)       |
/// | `Swift.Error`            | `repeat each Element: Swift.Error`                                      |
/// | `Equation.Protocol`      | `repeat each Element: Equation.Protocol & ~Copyable & ~Escapable`       |
/// | `Hash.Protocol`          | `repeat each Element: Hash.Protocol & ~Copyable & ~Escapable`           |
/// | `Comparison.Protocol`    | `repeat each Element: Comparison.Protocol & ~Copyable & ~Escapable`     |
@frozen
public enum Coproduct<each Element: ~Copyable & ~Escapable>: ~Copyable, ~Escapable {
    /// Injection at the active pack position.
    ///
    /// `.at(value)` builds a `Coproduct` whose active arm is the pack position
    /// matching `value`'s type. Pattern-matching on `.at(let value)` binds
    /// `value` to the inhabited arm.
    ///
    /// The pack-expanded case syntax is the natural-shape best guess pending
    /// the eventual Swift Evolution proposal for variadic enum cases. The
    /// `case at(each Element)` form mirrors the existing pack-tuple parameter
    /// syntax — one syntactic case-declaration generates one case per pack
    /// position. Pattern-binding `case .at(let value)` binds `value` to a
    /// value of the active position's element type.
    case at(each Element)
}

// MARK: - Conditional conformances
//
// The where-clauses mirror Either's ladder, extended pack-wise. Each pack
// element carries the same suppression/conformance pattern; conformance
// holds when every pack element satisfies the per-element constraint.

extension Coproduct: Copyable
where repeat each Element: Copyable & ~Escapable {}

extension Coproduct: Escapable
where repeat each Element: Escapable & ~Copyable {}

extension Coproduct: Sendable
where repeat each Element: Sendable & ~Copyable & ~Escapable {}

extension Coproduct: BitwiseCopyable
where repeat each Element: BitwiseCopyable {}

// Stdlib Equatable / Hashable conformances are gated `#if swift(<6.4)` only.
// On Swift 6.4+ each institute `*.Protocol` is a typealias to its stdlib
// counterpart per SE-0499, so the unconditional institute conformance in
// `Coproduct+Equation.Protocol.swift` / `Coproduct+Hash.Protocol.swift` IS
// the stdlib conformance — declaring an additional stdlib extension here
// would trigger duplicate-conformance. Pattern matches swift-pair-primitives /
// swift-either-primitives / swift-product-primitives.
#if swift(<6.4)
    extension Coproduct: Equatable where repeat each Element: Equatable {}

    extension Coproduct: Hashable where repeat each Element: Hashable {}
#endif

#if !hasFeature(Embedded)
    extension Coproduct: Codable where repeat each Element: Codable {}
#endif

extension Coproduct: Swift.Error where repeat each Element: Swift.Error {}

#endif  // hasFeature(VariadicEnum)
