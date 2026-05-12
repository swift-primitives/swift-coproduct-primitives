// Coproduct+Equation.Protocol.swift
// Conformance of Coproduct to Equation.Protocol — unconditional.
//
// On Swift <6.4, `Equation.Protocol` is the institute fork supporting
// `borrowing` parameters for `~Copyable` arms. On Swift 6.4+, it is a
// typealias to `Swift.Equatable` per SE-0499 — this same extension then
// satisfies the stdlib conformance directly. The stdlib `extension Coproduct:
// Equatable where repeat each Element: Equatable {}` in `Coproduct.swift`
// is therefore guarded `#if swift(<6.4)` to avoid duplicate-conformance.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.

#if hasFeature(VariadicEnum)

extension Coproduct: Equation.`Protocol`
where repeat each Element: Equation.`Protocol` & ~Copyable & ~Escapable {

    /// Returns whether two `Coproduct` values are equal.
    ///
    /// Two coproducts are equal when their active arms match in position
    /// *and* their payloads compare equal under `Equation.Protocol`. A
    /// `.at(L)` at position `i` and a `.at(R)` at position `j` with `i ≠ j`
    /// are never equal regardless of payload.
    ///
    /// - Note: Uses `@_disfavoredOverload` so the stdlib `Swift.Equatable`
    ///   synthesized conformance is preferred for Copyable arms on Swift
    ///   <6.4; the move-only borrowing path is selected when at least one
    ///   arm is `~Copyable`.
    @inlinable
    @_disfavoredOverload
    public static func == (lhs: borrowing Coproduct, rhs: borrowing Coproduct) -> Bool {
        // Pack-position comparison: lhs and rhs must inhabit the same pack
        // position; their payloads must compare equal. The pack-position
        // comparison is the speculative bit — the eventual compiler
        // mechanism for "are these two coproducts at the same active
        // position" depends on the shipped pack-eliminator syntax.
        switch (lhs, rhs) {
        case (.at(let l), .at(let r)):
            // Pack-position dispatch: equality holds when both `l` and
            // `r` inhabit the same pack position AND `l == r` under
            // `Equation.Protocol`.
            l == r
        }
    }
}

#endif  // hasFeature(VariadicEnum)
