import SwiftSyntax
import SwiftSyntaxMacros

public struct EnvironmentObservableMacro: MemberMacro, MemberAttributeMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingAttributesFor member: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AttributeSyntax] {
        return [
            AttributeSyntax(
                attributeName: IdentifierTypeSyntax(
                    name: .identifier("ObservableValue")
                )
            )
        ]
    }

    // MARK: - MemberMacro
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let _ = declaration.asProtocol(NamedDeclSyntax.self) else {
            return []
        }

        let environment: DeclSyntax =
      """
      public unowned let environment: Decide.SharedEnvironment
      public init(environment: Decide.SharedEnvironment) {
        self.environment = environment
      }
      """

        return [environment]
    }
}


extension EnvironmentObservableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        [try ExtensionDeclSyntax("extension \(type): Decide.StateRoot {}")]
    }
}
