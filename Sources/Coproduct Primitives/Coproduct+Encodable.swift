// Coproduct+Encodable.swift
// Encodable conformance — encodes the active arm's payload alongside its
// pack-position discriminator into a keyed container.
//
// EVERGREEN-SPECULATIVE. See `Coproduct.swift` for the top-level gate.

#if hasFeature(VariadicEnum)
    #if !hasFeature(Embedded)
        // swiftlint:disable no_any_protocol_existential
        // reason: stdlib protocol witness — Encodable.encode(to:) signature mandates the existential
        // shape; the untyped throws clause mirrors the protocol requirement. [API-ERR-006] exception.
        extension Coproduct: Encodable where repeat each Element: Encodable {

            /// Encodes the active arm into a keyed container: a `position`
            /// discriminator key (UInt) plus a `payload` key carrying the
            /// active arm's encoded value.
            ///
            /// Format mirrors stdlib `Result.encode(to:)`'s discriminator
            /// approach, extended over the n-ary case.
            ///
            /// The error type is the stdlib's open `Swift.Error` because
            /// the protocol requirement `Encodable.encode(to:) throws` is
            /// itself untyped; downstream errors propagate from
            /// `KeyedEncodingContainer.encode(_:forKey:)`.
            @inlinable
            public func encode(to encoder: any Encoder) throws(any Swift.Error) {
                // The body sketches the intent: tag the active position,
                // encode the payload. Pack-position retrieval is gated on
                // shipped pack-eliminator syntax.
                var container = encoder.container(keyedBy: CodingKeys.self)
                switch self {
                case .at(let value):
                    // Plausible shipped form:
                    //   try container.encode(self.activePosition, forKey: .position)
                    try container.encode(value, forKey: .payload)
                }
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
