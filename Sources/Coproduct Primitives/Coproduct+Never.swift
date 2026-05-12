// Coproduct+Never.swift
// Never elimination — extract the inhabited arm unconditionally when every
// other arm of the coproduct is `Never`.
//
// Generalises `Either.value` (when one side is `Never`) to the n-ary case:
// an N-ary coproduct in which exactly N-1 arms are `Never` is inhabited
// only at the remaining arm; `value(of:)` returns that arm's value
// directly without exhaustive pattern matching.
//
// SE-0413 §"Alternatives Considered" anticipates an `Uninhabited` protocol
// that would generalise the constraint (`every other arm is uninhabited`);
// until that lands, the explicit `where each Other == Never` form carries
// the precondition. The pack-equality constraint syntax follows the
// shipped pack-equality form.
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.

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
