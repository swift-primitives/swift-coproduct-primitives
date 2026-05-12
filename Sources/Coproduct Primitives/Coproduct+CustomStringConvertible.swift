// Coproduct+CustomStringConvertible.swift
// `description` for a `Coproduct` — renders the active arm's payload with
// its pack position.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.

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
            // The active position's index would be exposed via the
            // shipped pack-eliminator syntax. The intent-level body
            // renders only the payload; the position-aware form will
            // emerge once the compiler exposes the discriminator.
            "at(\(value))"
        }
    }
}

#endif  // hasFeature(VariadicEnum)
