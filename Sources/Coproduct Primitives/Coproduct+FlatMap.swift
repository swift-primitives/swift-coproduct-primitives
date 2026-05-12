// Coproduct+FlatMap.swift
// Monadic bind — chains a Coproduct-returning operation per arm.
//
// `flatMap(_:transforms:)` takes one Coproduct-returning transform per
// pack position. Exactly one transform runs — the one matching the active
// arm — and its returned `Coproduct<repeat each NewElement>` is the
// result. The n-ary generalisation of `Either.flatMap(left:)` /
// `Either.flatMap(right:)`.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.
// The body's pack-position dispatch is intent-level.

#if hasFeature(VariadicEnum)

// MARK: - Static layer (canonical implementation)

extension Coproduct where repeat each Element: ~Copyable {

    /// Chains a `Coproduct`-returning operation on every arm, consuming `coproduct`.
    ///
    /// ```swift
    /// let c: Coproduct<Int, String> = .at(7)
    /// let chained = try Coproduct.flatMap(
    ///     c,
    ///     { i -> Coproduct<Bool, [Int]> in
    ///         i > 0 ? .at(true) : .at([i])
    ///     },
    ///     { s -> Coproduct<Bool, [Int]> in
    ///         .at(s.isEmpty)
    ///     }
    /// )
    /// // Coproduct<Bool, [Int]> = .at(true)
    /// ```
    @inlinable
    public static func flatMap<each NewElement: ~Copyable, E: Swift.Error>(
        _ coproduct: consuming Coproduct,
        _ transforms:
            repeat (consuming each Element) throws(E) -> Coproduct<repeat each NewElement>
    ) throws(E) -> Coproduct<repeat each NewElement> {
        switch consume coproduct {
        case .at(let value):
            // Pack-position dispatch: invoke `(each transforms)` at the
            // matching pack position. The returned Coproduct is the
            // final result — no further injection wrapping.
            try (each transforms)(consume value)
        }
    }
}

// MARK: - Equal-arm convenience (canonical static)

extension Coproduct where repeat each Element == FirstElement, FirstElement: ~Copyable {

    /// Chains a single `Coproduct`-returning operation across all arms,
    /// consuming `coproduct`. Available when every pack position shares a
    /// single type.
    @inlinable
    public static func flatMap<each NewElement: ~Copyable, E: Swift.Error>(
        _ coproduct: consuming Coproduct,
        _ transform:
            (consuming FirstElement) throws(E) -> Coproduct<repeat each NewElement>
    ) throws(E) -> Coproduct<repeat each NewElement> {
        switch consume coproduct {
        case .at(let value):
            try transform(consume value)
        }
    }
}

// MARK: - Instance layer (delegates to static)

extension Coproduct where repeat each Element: ~Copyable {

    /// Chains a `Coproduct`-returning operation on every arm, consuming `self`.
    @inlinable
    public consuming func flatMap<each NewElement: ~Copyable, E: Swift.Error>(
        _ transforms:
            repeat (consuming each Element) throws(E) -> Coproduct<repeat each NewElement>
    ) throws(E) -> Coproduct<repeat each NewElement> {
        try Self.flatMap(self, repeat each transforms)
    }
}

// flatMap is Escapable-only on the closure-result side because the new
// Coproduct's lifetime is independent of `coproduct` — same Gap A
// limitation that constrains Either.flatMap.

#endif  // hasFeature(VariadicEnum)
