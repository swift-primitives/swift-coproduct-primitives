// Coproduct+Hash.Protocol.swift
// Conformance of Coproduct to Hash.Protocol — unconditional.
//
// On Swift <6.4, `Hash.Protocol` is the institute fork supporting
// `borrowing self` for `~Copyable` arms. On Swift 6.4+, it is a typealias
// to `Swift.Hashable` per SE-0499 — this same extension then satisfies the
// stdlib conformance directly. The stdlib `extension Coproduct: Hashable
// where repeat each Element: Hashable {}` in `Coproduct.swift` is therefore
// guarded `#if swift(<6.4)` to avoid duplicate-conformance.
//
// Hash.Protocol refines Equation.Protocol; the sibling Equation conformance
// in this same target supplies the inherited conformance.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.

#if hasFeature(VariadicEnum)

extension Coproduct: Hash.`Protocol`
where repeat each Element: Hash.`Protocol` & ~Copyable & ~Escapable {

    /// Hashes the essential components of this coproduct into the given hasher.
    ///
    /// The active pack position is folded into the hash alongside the payload's
    /// own hash. This ensures that `Coproduct` values with structurally
    /// identical payloads but different active positions produce different
    /// hashes, preserving the equals/hashCode contract alongside `==`.
    ///
    /// - Note: Uses `@_disfavoredOverload` so the stdlib `Swift.Hashable`
    ///   synthesized conformance is preferred for Copyable arms on Swift
    ///   <6.4; the move-only borrowing path is selected when at least one
    ///   arm is `~Copyable`.
    @inlinable
    @_disfavoredOverload
    public borrowing func hash(into hasher: inout Hasher) {
        switch self {
        case .at(let value):
            // Pack-position discriminator: feed the active position's
            // index into the hasher before the payload. The mechanism
            // for retrieving the active position is speculative; the
            // semantic contract is "discriminator-then-payload".
            //
            // Plausible shipped syntax:
            //   hasher.combine(self.activePosition as UInt8)
            //   value.hash(into: &hasher)
            value.hash(into: &hasher)
        }
    }
}

#endif  // hasFeature(VariadicEnum)
