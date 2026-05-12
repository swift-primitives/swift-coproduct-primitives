// Coproduct+Map.swift
// Functor surface — per-arm transformation.
//
// `map(_:transforms:)` takes one transform per pack position. Exactly one
// transform runs — the one matching the active arm — and produces the
// corresponding new pack element. The result is a `Coproduct<repeat each
// NewElement>` with the active arm transformed and inactive arms vacuously
// re-typed.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.
// The body's pack-position dispatch is intent-level; actual mechanism
// follows shipped pack-eliminator syntax. Same speculative contract as
// `Coproduct+Fold.swift`.

#if hasFeature(VariadicEnum)

// MARK: - Static layer (canonical implementation)

extension Coproduct where repeat each Element: ~Copyable {

    /// Transforms every arm, consuming `coproduct`.
    ///
    /// Pack-position dispatch: only the transform matching the active arm
    /// runs. The other transforms are discarded. The n-ary generalisation
    /// of `Either.map(left:right:)` and the dual of `Product.map(_:)`.
    ///
    /// ```swift
    /// let c: Coproduct<Int, String, Bool> = .at("hi")
    /// let transformed = try Coproduct.map(
    ///     c,
    ///     { $0 + 1 },
    ///     { $0.uppercased() },
    ///     { !$0 }
    /// )
    /// // Coproduct<Int, String, Bool> = .at("HI")
    /// ```
    @inlinable
    public static func map<each NewElement: ~Copyable, E: Swift.Error>(
        _ coproduct: consuming Coproduct,
        _ transforms: repeat (consuming each Element) throws(E) -> each NewElement
    ) throws(E) -> Coproduct<repeat each NewElement> {
        switch consume coproduct {
        case .at(let value):
            // Pack-position dispatch: invoke `(each transforms)` at the
            // same pack position as `value`, then inject the result at the
            // matching position of the new pack.
            try .at((each transforms)(consume value))
        }
    }
}

// Equal-arm convenience (Either's unlabeled `map { ... }` form when both
// arms share a type) is intentionally NOT exposed at the n-ary case. The
// natural shape — "Coproduct<T, T, ..., T>.map(transform) → Coproduct<U,
// U, ..., U>" with same-arity, single-replacement-type — requires pack-
// replicate syntax that does not exist in Swift today (you cannot say
// "for each position in the input pack, produce one U"). The n-ary form
// above covers the case at the cost of one closure-per-position:
// `c.map(repeat (transform))` once pack-of-handlers-from-single-source
// syntax exists, or `c.map(transform, transform, transform)` literally.
// Either's `Left == Right` form remains the right tool for arity-2.

// MARK: - Instance layer (delegates to static)

extension Coproduct where repeat each Element: ~Copyable {

    /// Transforms every arm, consuming `self`.
    @inlinable
    public consuming func map<each NewElement: ~Copyable, E: Swift.Error>(
        _ transforms: repeat (consuming each Element) throws(E) -> each NewElement
    ) throws(E) -> Coproduct<repeat each NewElement> {
        try Self.map(self, repeat each transforms)
    }
}

// `map` is Escapable-only on the closure-result side because each transform
// produces a `NewElement` whose lifetime is independent of `coproduct` —
// same Gap A limitation that constrains Either's labeled-map overloads.

#endif  // hasFeature(VariadicEnum)
