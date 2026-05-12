// Coproduct+Swap.swift
// Component swap on a binary Coproduct (arity-2 only) — exchanges the two arms.
//
// For arity-2 work, prefer `Either` directly: it carries `.left` / `.right`
// ergonomic spellings, a richer accessor surface, and tested institute-
// protocol conformances. The `Coproduct<First, Second>.swapped()` form
// exists for cohort symmetry — to mirror `Product`'s `swapped(_:)` free
// function for binary cases — and for code that has already committed to
// the `Coproduct` vocabulary and wants to permute arms.
//
// General arity-N permutation (full pack rotation) is deferred. Its utility
// is genuinely low at general n-ary: pack reordering is rarely the right
// shape; consumers usually want to project a sub-pack or convert into a
// different sum. See `Research/coproduct-primitive-design-and-blockers.md`
// § "Perfect-future shape" for the rationale.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.

#if hasFeature(VariadicEnum)

// MARK: - Free function (arity-2)

/// Returns a binary `Coproduct` with arms swapped, consuming `coproduct`.
///
/// Free-function form: arity-2 only. For arity-2 work prefer `Either`,
/// which carries `.left` / `.right` accessors and an `.swapped()` instance
/// method.
///
/// Free-function shape (rather than a static on `Coproduct`) mirrors the
/// `swapped(_:)` precedent on `swift-product-primitives`: Swift's pack
/// inference does not bind the enclosing `each Element` from a method's
/// non-pack `<First, Second>` generics, so a static
/// `Coproduct.swapped<First, Second>(_:)` on `Coproduct<repeat each Element>`
/// fails inference at nested call sites.
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
    // Pack-position dispatch on the arity-2 pack:
    //   - active arm First → re-inject at the second position of <Second, First>
    //   - active arm Second → re-inject at the first position of <Second, First>
    //
    // The body sketch is intent-level; the actual mechanism depends on
    // shipped pack-position-aware reinjection syntax.
    switch consume coproduct {
    case .at(let value):
        .at(consume value)
    }
}

#endif  // hasFeature(VariadicEnum)
