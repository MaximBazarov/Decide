#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DecideCompilerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StorageMacro.self,
//        AtomicPropertyMacro.self,
    ]
}
#endif
