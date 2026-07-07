// Coproduct+Hash.Protocol.swift
// Conformance of Coproduct to Hash.Protocol.
//
// On Swift <6.4, `Hash.Protocol` is the institute fork supporting
// `borrowing self` for `~Copyable` arms. On Swift 6.4+, `Hash.Protocol`
// REFINES `Swift.Hashable` (re-declaring a typed `hashValue: Hash.Value`);
// a conditional conformance to it does not synthesize the inherited
// `Swift.Hashable`, so it is declared explicitly with the `hash(into:)`
// witness and the `Hash.Protocol` conformance is left empty (the typed
// `hashValue` is defaulted in hash-primitives). `Equatable` comes from the
// sibling `Equation.Protocol` conformance (still a `Swift.Equatable`
// typealias). See Research/se-0499-…md Addendum (2026-06-01).
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.

#if hasFeature(VariadicEnum)

    #if swift(<6.4)
        extension Coproduct: Hash.`Protocol`
        where repeat each Element: Hash.`Protocol` & ~Copyable & ~Escapable {
            /// Hashes the essential components of this coproduct into the given hasher.
            ///
            /// The active pack position is folded into the hash alongside the payload's
            /// own hash, preserving the equals/hashCode contract alongside `==`.
            @inlinable
            @_disfavoredOverload
            public borrowing func hash(into hasher: inout Hasher) {
                switch self {
                case .at(let value):
                    value.hash(into: &hasher)
                }
            }
        }
    #else
        extension Coproduct: Swift.Hashable
        where repeat each Element: Hash.`Protocol` & ~Copyable {
            /// Hashes the essential components of this coproduct into the given hasher.
            ///
            /// The active pack position is folded into the hash alongside the payload's
            /// own hash, preserving the equals/hashCode contract alongside `==`.
            @inlinable
            @_disfavoredOverload
            public borrowing func hash(into hasher: inout Hasher) {
                switch self {
                case .at(let value):
                    value.hash(into: &hasher)
                }
            }
        }

        extension Coproduct: Hash.`Protocol`
        where repeat each Element: Hash.`Protocol` & ~Copyable {}
    #endif

#endif  // hasFeature(VariadicEnum)
