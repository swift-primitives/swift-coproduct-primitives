// Coproduct+Swap.swift
// Component swap on a binary Coproduct (arity-2 only) — exchanges the two arms.
//
// For arity-2 work, prefer `Either` directly: it carries `.left` / `.right`
// spellings, a richer accessor surface, and tested institute-protocol
// conformances. The `swapped(_:)` form here exists for cohort symmetry with
// `Product`'s `swapped(_:)` free function.
//
// Free-function shape (rather than a static on `Coproduct`) mirrors the
// `swapped(_:)` precedent on `swift-product-primitives`: Swift's pack
// inference does not bind the enclosing `each Element` from a method's
// non-pack `<First, Second>` generics, so a static
// `Coproduct.swapped<First, Second>(_:)` on `Coproduct<repeat each Element>`
// fails inference at nested call sites.
//
// General arity-N permutation (full pack rotation) is not exposed: pack
// reordering is rarely the right shape; consumers usually want to project
// a sub-pack or convert into a different sum.
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.

#if hasFeature(VariadicEnum)

    // MARK: - Free function (arity-2)

    /// Returns a binary `Coproduct` with arms swapped, consuming `coproduct`.
    ///
    /// Arity-2 only. For arity-2 work prefer `Either`, which carries
    /// `.left` / `.right` accessors and an `.swapped()` instance method.
    ///
    /// ```swift
    /// let c: Coproduct<Int, String> = .at("hi")
    /// let flipped = swapped(c)   // Coproduct<String, Int> = .at("hi")
    /// ```
    @inlinable
    @_lifetime(copy coproduct)
    public func swapped<First: ~Copyable & ~Escapable, Second: ~Copyable & ~Escapable>(
        _ coproduct: consuming Coproduct<First, Second>
    ) -> Coproduct<Second, First> {
        // Placeholder body. Pack-position-aware reinjection follows the
        // shipped pack-eliminator syntax: an active arm at position k of
        // <First, Second> is re-injected at the matching position of
        // <Second, First>.
        switch consume coproduct {
        case .at(let value):
            .at(consume value)
        }
    }

#endif  // hasFeature(VariadicEnum)
