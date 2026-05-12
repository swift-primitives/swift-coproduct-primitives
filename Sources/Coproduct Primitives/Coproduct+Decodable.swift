// Coproduct+Decodable.swift
// Decodable conformance — reads `[position, payload]` from an unkeyed
// container and injects the payload at the matching pack position.
//
// Wire format mirrors `Coproduct+Encodable.swift`: position-first,
// payload-second unkeyed pair.
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.

#if hasFeature(VariadicEnum)
    #if !hasFeature(Embedded)
        // swiftlint:disable no_any_protocol_existential
        // reason: stdlib protocol witness — Decodable.init(from:) signature mandates the existential
        // shape; the untyped throws clause mirrors the protocol requirement. [API-ERR-006] exception.
        extension Coproduct: Decodable where repeat each Element: Decodable {

            /// Decodes a `Coproduct` from a `[position, payload]` unkeyed container.
            ///
            /// The discriminator selects which pack position's element type
            /// to decode the payload as, then injects at that position.
            ///
            /// The error type is the stdlib's open `Swift.Error` because
            /// the protocol requirement `Decodable.init(from:) throws` is
            /// itself untyped; downstream errors propagate from
            /// `UnkeyedDecodingContainer.decode(_:)`.
            @inlinable
            public init(from decoder: any Decoder) throws(any Swift.Error) {
                var container = try decoder.unkeyedContainer()
                let position = try container.decode(UInt.self)

                // Placeholder body. Contract: dispatch on `position`,
                // decode the payload at the matching pack position's
                // element type, inject at that position. The pack-
                // position-aware injection follows the shipped pack-
                // eliminator syntax. Indicative shipped form:
                //
                //   try self = .at(at: position, container.decode(...))
                _ = position
                fatalError("Pack-position decoding pending the shipped pack-eliminator syntax")
            }
        }
    // swiftlint:enable no_any_protocol_existential
    #endif
#endif  // hasFeature(VariadicEnum)
