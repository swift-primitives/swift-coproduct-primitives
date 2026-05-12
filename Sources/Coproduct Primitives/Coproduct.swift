// Coproduct.swift
// The n-ary coproduct type.
//
// All declarations in this file are guarded `#if hasFeature(VariadicEnum)`.
// On toolchains that do not define the feature (Swift 6.3.1 and Swift
// 6.4-dev as of authoring), `hasFeature(VariadicEnum)` returns `false`
// and the body emits no public symbols — the package builds clean.
//
// Maintainer notes:
//   - The case spelling `case at(each Element)` and the pack-position
//     dispatch inside `fold` / `map` / `flatMap` follow the eventual
//     Swift Evolution proposal for variadic enum cases; this file holds
//     placeholder bodies until that lands.
//   - The `~Copyable & ~Escapable` suppressions on `each Element` are
//     rejected by the current parser at semantic-check time (see
//     `swift/test/Generics/inverse_copyable_requirement_errors.swift`).
//     Activation requires both the variadic-enum admission and the pack-
//     element suppression admission.
//
// See `Research/coproduct-primitive-design-and-blockers.md` for the
// blocker survey.

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
    /// ## Type-level constraints
    ///
    /// Each pack element is `~Copyable & ~Escapable`:
    ///
    /// ```swift
    /// public enum Coproduct<each Element: ~Copyable & ~Escapable>: ~Copyable, ~Escapable
    /// ```
    ///
    /// Every arm may hold non-copyable resources or non-escapable views.
    /// Conformance ladder:
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
        /// `.at(value)` builds a `Coproduct` whose active arm is the pack
        /// position matching `value`'s type. Pattern-matching on
        /// `case .at(let value)` binds `value` to the inhabited arm.
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
