// Coproduct+CustomStringConvertible.swift
// `description` for a `Coproduct` — renders the active arm's payload with
// its pack position.
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.

#if hasFeature(VariadicEnum)

    extension Coproduct: CustomStringConvertible
    where repeat each Element: CustomStringConvertible {

        /// A rendering of the active arm's `description` tagged with its pack
        /// position.
        ///
        /// Renders as `at(<position>: <payload>)`, e.g. `at(1: "hi")` for a
        /// `Coproduct<Int, String, Bool>` inhabited at position 1 with the
        /// string `"hi"`. The position numbering is zero-based.
        @inlinable
        public var description: String {
            switch self {
            case .at(let value):
                // Placeholder body. Renders the payload only; the
                // position-aware form follows the shipped pack-eliminator
                // syntax that exposes the active discriminator.
                "at(\(value))"
            }
        }
    }

#endif  // hasFeature(VariadicEnum)
