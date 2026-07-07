// Coproduct+Comparison.Protocol.swift
// Conformance of Coproduct to Comparison.Protocol.
//
// The institute protocol handles Swift version differences internally:
// under Swift <6.4 Comparison.Protocol is its own protocol fork; under
// Swift 6.4+ it is a typealias to Swift.Comparable per SE-0499. The
// `borrowing Self` operator works in both worlds.
//
// Comparison.Protocol refines Equation.Protocol; the sibling Equation
// conformance in this same target supplies the inherited conformance.
//
// Ordering convention (extending Either's Haskell-derived `Ord (Either a b)`
// to n-ary): lower pack positions sort before higher pack positions
// regardless of payload; within the same active position, payloads are
// compared.
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.

#if hasFeature(VariadicEnum)

    #if swift(<6.4)
        extension Coproduct: Comparison.`Protocol`
        where repeat each Element: Comparison.`Protocol` & ~Copyable & ~Escapable {
            /// Returns whether the left-hand side coproduct is less than the
            /// right-hand side under the lexicographic ordering: an earlier active
            /// pack position sorts before a later one; within a matching position,
            /// payloads are compared.
            ///
            /// - Note: Uses `@_disfavoredOverload` so the stdlib `Swift.Comparable`
            ///   conformance is preferred when every arm is Copyable.
            @inlinable
            @_disfavoredOverload
            public static func < (lhs: borrowing Coproduct, rhs: borrowing Coproduct) -> Bool {
                // Placeholder body. Contract: lexicographic compare — first by
                // active position, then by payload at matching positions. The
                // active-position retrieval follows the shipped pack-eliminator
                // syntax.
                switch (lhs, rhs) {
                case (.at(let l), .at(let r)):
                    l < r
                }
            }
        }
    #else
        // Swift 6.4+: Comparison.Protocol = Swift.Comparable. Drops ~Escapable.
        extension Coproduct: Comparison.`Protocol`
        where repeat each Element: Comparison.`Protocol` & ~Copyable {
            /// Returns whether the left-hand side coproduct is less than the
            /// right-hand side under the lexicographic ordering: an earlier active
            /// pack position sorts before a later one; within a matching position,
            /// payloads are compared.
            ///
            /// - Note: Uses `@_disfavoredOverload` so the stdlib `Swift.Comparable`
            ///   conformance is preferred when every arm is Copyable.
            @inlinable
            @_disfavoredOverload
            public static func < (lhs: borrowing Coproduct, rhs: borrowing Coproduct) -> Bool {
                // Placeholder body. Contract: lexicographic compare — first by
                // active position, then by payload at matching positions. The
                // active-position retrieval follows the shipped pack-eliminator
                // syntax.
                switch (lhs, rhs) {
                case (.at(let l), .at(let r)):
                    l < r
                }
            }
        }
    #endif

#endif  // hasFeature(VariadicEnum)
