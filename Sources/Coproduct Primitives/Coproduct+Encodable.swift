// Coproduct+Encodable.swift
// Encodable conformance — encodes the active arm's pack position as the
// first element of an unkeyed container, followed by the payload.
//
// Wire format: `[position: UInt, payload: each Element]`. Mirrors stdlib
// `Result.encode(to:)`'s discriminator approach extended over the n-ary
// case, and matches `Product`'s unkeyed-container pattern.
//
// Gated `#if hasFeature(VariadicEnum)`. See `Coproduct.swift` for the
// top-level gate.

#if hasFeature(VariadicEnum)
    #if !hasFeature(Embedded)
        // swiftlint:disable no_any_protocol_existential
        // reason: stdlib protocol witness — Encodable.encode(to:) signature mandates the existential
        // shape; the untyped throws clause mirrors the protocol requirement. [API-ERR-006] exception.
        extension Coproduct: Encodable where repeat each Element: Encodable {

            /// Encodes the active arm into an unkeyed container.
            ///
            /// The container holds `[position, payload]`: a `UInt`
            /// discriminator giving the active pack index, followed by the
            /// active arm's encoded value.
            ///
            /// The error type is the stdlib's open `Swift.Error` because
            /// the protocol requirement `Encodable.encode(to:) throws` is
            /// itself untyped; downstream errors propagate from
            /// `UnkeyedEncodingContainer.encode(_:)`.
            @inlinable
            public func encode(to encoder: any Encoder) throws(any Swift.Error) {
                // Placeholder body. Contract: tag the active position,
                // encode the payload. Pack-position retrieval follows the
                // shipped pack-eliminator syntax. Indicative shipped form:
                //
                //   try container.encode(self.activePosition as UInt)
                //   try container.encode(value)
                var container = encoder.unkeyedContainer()
                switch self {
                case .at(let value):
                    try container.encode(value)
                }
            }
        }
    // swiftlint:enable no_any_protocol_existential
    #endif
#endif  // hasFeature(VariadicEnum)
