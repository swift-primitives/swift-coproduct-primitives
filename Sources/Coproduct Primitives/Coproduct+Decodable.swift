// Coproduct+Decodable.swift
// Decodable conformance — reads a `position` discriminator and a `payload`
// key, decoding the payload at the matching pack position.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.

#if hasFeature(VariadicEnum)
    #if !hasFeature(Embedded)
        // swiftlint:disable no_any_protocol_existential
        // reason: stdlib protocol witness — Decodable.init(from:) signature mandates the existential
        // shape; the untyped throws clause mirrors the protocol requirement. [API-ERR-006] exception.
        extension Coproduct: Decodable where repeat each Element: Decodable {

            /// Decodes a `Coproduct` from a keyed container with `position`
            /// + `payload` keys. The discriminator selects which pack
            /// position's element type to decode the payload as, then
            /// injects at that position.
            ///
            /// The error type is the stdlib's open `Swift.Error` because
            /// the protocol requirement `Decodable.init(from:) throws` is
            /// itself untyped; downstream errors propagate from
            /// `KeyedDecodingContainer.decode(_:forKey:)`.
            @inlinable
            public init(from decoder: any Decoder) throws(any Swift.Error) {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let position = try container.decode(UInt.self, forKey: .position)

                // Pack-position dispatch on the decoded `position`:
                // decode the payload at the matching pack position's
                // element type and inject. The mechanism for selecting
                // "(each Element).self at the position" is speculative —
                // a plausible shipped form:
                //
                //   try self = .at(at: position, container.decode(...))
                //
                // The actual constructor follows the eventual pack-
                // position-aware injection syntax.
                _ = position
                fatalError("Pack-position decoding pending Swift Evolution")
            }

            @usableFromInline
            enum CodingKeys: String, CodingKey {
                case position
                case payload
            }
        }
        // swiftlint:enable no_any_protocol_existential
    #endif
#endif  // hasFeature(VariadicEnum)
