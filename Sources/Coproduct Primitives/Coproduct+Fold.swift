// Coproduct+Fold.swift
// Catamorphism — eliminates the `Coproduct` by handling every arm.
// The universal property of the n-ary coproduct (the n-ary copairing).
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.
//
// The eliminator body depends on the eventual compiler mechanism for
// dispatching to the handler at the active pack position. Contract:
// exactly one handler in `handlers` runs — the one whose pack position
// matches the active arm of `coproduct`.

#if hasFeature(VariadicEnum)

    // MARK: - Static layer (canonical implementation)

    extension Coproduct where repeat each Element: ~Copyable & ~Escapable {

        /// Eliminates the `Coproduct` by handling every arm, consuming `coproduct`.
        ///
        /// Takes one handler per pack position. Exactly one handler runs — the
        /// one matching the active arm — and produces the `Result`.
        ///
        /// ```swift
        /// let c: Coproduct<Int, String, Bool> = .at("hi")
        /// let described = Coproduct.fold(
        ///     c,
        ///     { i in "int: \(i)" },
        ///     { s in "str: \(s)" },
        ///     { b in "bool: \(b)" }
        /// )
        /// // "str: hi"
        /// ```
        @inlinable
        public static func fold<Result: ~Copyable, E: Swift.Error>(
            _ coproduct: consuming Coproduct,
            _ handlers: repeat (consuming each Element) throws(E) -> Result
        ) throws(E) -> Result {
            switch consume coproduct {
            case .at(let value):
                // Placeholder body. Invokes the handler at the same pack
                // position as `value`; the actual mechanism depends on the
                // shipped pack-eliminator syntax. Exactly one handler in
                // `handlers` runs.
                try (each handlers)(consume value)
            }
        }
    }

    // MARK: - Instance layer (delegates to static)

    extension Coproduct where repeat each Element: ~Copyable & ~Escapable {

        /// Eliminates the `Coproduct` by handling every arm, consuming `self`.
        @inlinable
        public consuming func fold<Result: ~Copyable, E: Swift.Error>(
            _ handlers: repeat (consuming each Element) throws(E) -> Result
        ) throws(E) -> Result {
            try Self.fold(self, repeat each handlers)
        }
    }

// fold is Escapable-only on the handler-result side because each handler
// consumes its arm and produces `Result`. The Result's lifetime is whatever
// the active handler decides, which is independent of `coproduct` — same
// Gap A limitation that constrains the Either / Pair flatMap path.

#endif  // hasFeature(VariadicEnum)
