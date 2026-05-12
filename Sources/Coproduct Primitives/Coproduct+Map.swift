// Coproduct+Map.swift
// Functor surface — per-arm transformation.
//
// `map(_:transforms:)` takes one transform per pack position. Exactly one
// transform runs — the one matching the active arm — and produces the
// corresponding new pack element. The result is a `Coproduct<repeat each
// NewElement>` with the active arm transformed and inactive arms vacuously
// re-typed.
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate. The body's pack-position dispatch is placeholder; the
// actual mechanism follows the shipped pack-eliminator syntax, with the
// same contract as `Coproduct+Fold.swift`.

#if hasFeature(VariadicEnum)

    // MARK: - Static layer (canonical implementation)

    extension Coproduct where repeat each Element: ~Copyable {

        /// Transforms every arm, consuming `coproduct`.
        ///
        /// Takes one transform per pack position. Only the transform matching
        /// the active arm runs; the other transforms are discarded.
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
                // Placeholder body. Invokes `(each transforms)` at the same
                // pack position as `value`, then injects the result at the
                // matching position of the new pack.
                try .at((each transforms)(consume value))
            }
        }
    }

    // The equal-arm convenience (`Coproduct<T, T, …>.map(transform) →
    // Coproduct<U, U, …>` with same-arity, single-replacement-type) is not
    // exposed at the n-ary case: the return-type shape requires pack-
    // replicate syntax that current Swift does not provide. The n-ary form
    // above covers the case with one closure per position; `Either` remains
    // the right tool for arity-2.

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
