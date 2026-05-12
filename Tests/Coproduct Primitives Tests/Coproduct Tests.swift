// Coproduct Tests.swift
//
// Coverage is minimal on current toolchains. The `Coproduct<each Element>`
// API surface is guarded `#if hasFeature(VariadicEnum)` and emits no
// public symbols on Swift 6.3.1 or Swift 6.4-dev; the single test below
// confirms the module imports — i.e., the gated sources parse cleanly and
// the target emits a valid swiftmodule.

import Coproduct_Primitives
import Testing

@Suite
struct `Coproduct Tests` {
    @Suite struct ModuleImport {}
}

extension `Coproduct Tests`.ModuleImport {
    @Test
    func `module imports cleanly`() {
        // Intentional no-op. The `import Coproduct_Primitives` above is
        // the assertion — it resolves only when the target builds and
        // emits a swiftmodule.
    }
}
