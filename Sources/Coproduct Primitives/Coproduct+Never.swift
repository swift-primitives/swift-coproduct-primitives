// Coproduct+Never.swift
// Never elimination — extract the inhabited arm unconditionally when every
// other arm of the coproduct is `Never`.
//
// This generalises `Either.value` (when one side is `Never`) to the n-ary
// case: an `N`-ary coproduct in which exactly `N-1` arms are `Never` is
// inhabited only at the remaining arm; `value(of:)` returns that arm's
// value directly without exhaustive pattern matching.
//
// SE-0413 §"Alternatives Considered" anticipates an `Uninhabited` protocol
// that would generalise the constraint (`every other arm is uninhabited`);
// until that lands, the explicit `where each Other == Never` form is the
// canonical mechanism. The pack-equality constraint syntax is speculative;
// see `Coproduct.swift` for the top-level gate.
//
// EVERGREEN-SPECULATIVE.

#if hasFeature(VariadicEnum)

// MARK: - Free-function form (admits ~Copyable & ~Escapable arms)
//
// Free function rather than property accessor because property accessors on
// generic enums with `~Copyable` cases hit the same Swift compiler
// limitations documented in `swift-institute/Research/noncopyable-property-extract-via-underscore-owned.md`.
// The `value(of:)` free function consumes the coproduct, producing the
// inhabited arm via a direct switch.

/// Extracts the inhabited value from a single-arm-inhabited `Coproduct`,
/// consuming `coproduct`.
///
/// Available when exactly one pack element is non-`Never` (the
/// `Inhabited` arm) and every other element is `Never`. Admits
/// `~Copyable & ~Escapable` `Inhabited`.
///
/// The pack-shape constraint `repeat each Other == Never` carves out
/// the "every non-Inhabited position is uninhabited" precondition.
/// Pack-equality constraints with mixed-position predicates are
/// speculative — the actual constraint syntax follows Swift Evolution.
///
/// ```swift
/// // Three-arm coproduct with two Never arms
/// let c: Coproduct<Never, Int, Never> = .at(42)
/// let v = value(of: c)   // 42
/// ```
@inlinable
@_lifetime(copy coproduct)
public func value<each Other, Inhabited: ~Copyable & ~Escapable>(
    of coproduct: consuming Coproduct<repeat each Other, Inhabited>
) -> Inhabited
where repeat each Other == Never {
    // The pack carries `N-1` Never positions plus the Inhabited position.
    // Only the Inhabited arm can be active; pattern-binding extracts it.
    switch consume coproduct {
    case .at(let value):
        // The active arm is statically Inhabited because every other
        // position is uninhabited (Never). Pack-position-aware pattern
        // matching would let the compiler prove this exhaustively.
        consume value
    }
}

#endif  // hasFeature(VariadicEnum)
