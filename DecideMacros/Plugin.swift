#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DecideCompilerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnvironmentObservableMacro.self,
    ]
}
#endif
