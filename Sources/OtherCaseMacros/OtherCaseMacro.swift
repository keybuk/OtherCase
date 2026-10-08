//
//  OtherCaseMacro.swift
//  OtherCaseMacros
//
//  Created by Scott James Remnant on 10/7/26.
//

import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct OtherCaseMacro {}

extension OtherCaseMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingMembersOf declaration: some DeclGroupSyntax,
                                 conformingTo _: [TypeSyntax],
                                 in context: some MacroExpansionContext)
        throws -> [DeclSyntax]
    {
        // Make sure that @OtherCase is applied to an enum.
        guard declaration.is(EnumDeclSyntax.self) else {
            context.diagnose(Diagnostic(node: node, message: OtherCaseDiagnostic.onlyApplicableToEnum))
            return []
        }

        // Find the first enum member.
        let enumDecl = declaration.memberBlock.members
            .compactMap { $0.decl.as(EnumDeclSyntax.self) }
            .first
        guard let enumDecl else {
            context.diagnose(Diagnostic(node: node, message: OtherCaseDiagnostic.requiresMemberEnum))
            return []
        }

        // Extract RawValue type.
        guard let rawValueType = enumDecl.inheritanceClause?.inheritedTypes.first?.type else {
            context.diagnose(Diagnostic(node: node, message: OtherCaseDiagnostic.requiresEnumRawValueType))
            return []
        }

        // Extract all the enum elements.
        let enumCaseDecls = enumDecl.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap(\.elements)

        // Copy enum cases, add other case.
        let enumCaseDecl = EnumCaseDeclSyntax {
            for enumCaseDecl in enumCaseDecls {
                EnumCaseElementSyntax(name: enumCaseDecl.name.trimmed)
            }

            EnumCaseElementSyntax(
                name: .identifier("other"),
                parameterClause: EnumCaseParameterClauseSyntax(
                    parameters: [
                        EnumCaseParameterSyntax(type: IdentifierTypeSyntax(name: .identifier("RawValue"))),
                    ],
                ),
            )
        }

        // Extract greater-than-internal access modifier.
        let access = declaration.modifiers
            .first {
                switch $0.name.tokenKind {
                case .keyword(.open): true
                case .keyword(.public): true
                case .keyword(.package): true
                default: false
                }
            }

        // RawValue typealias.
        let rawValueTypeAliasDecl = try TypeAliasDeclSyntax("\(access)typealias RawValue = \(rawValueType)")

        // RawRepresentable initalizer.
        let rawRepresentableInitDecl = try InitializerDeclSyntax("\(access)init(rawValue: RawValue)") {
            try SwitchExprSyntax("switch \(enumDecl.name.trimmed)(rawValue: rawValue)") {
                for enumCaseDecl in enumCaseDecls {
                    SwitchCaseSyntax("case .\(enumCaseDecl.name.trimmed): self = .\(enumCaseDecl.name.trimmed)")
                }

                SwitchCaseSyntax("default: self = .other(rawValue)")
            }
        }

        // rawValue property.
        let rawValuePropertyDecl = try VariableDeclSyntax(
            modifiers: DeclModifierListSyntax([access].compactMap(\.self)),
            bindingSpecifier: .keyword(.var),
        ) {
            try PatternBindingListSyntax {
                try PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: .identifier("rawValue")),
                    typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("RawValue"))),
                    accessorBlock: AccessorBlockSyntax(
                        accessors: .getter(CodeBlockItemListSyntax {
                            try CodeBlockItemSyntax(
                                item: .expr(ExprSyntax(SwitchExprSyntax("switch self") {
                                    for enumCaseDecl in enumCaseDecls {
                                        SwitchCaseSyntax(
                                            "case .\(enumCaseDecl.name.trimmed): return \(enumDecl.name.trimmed).\(enumCaseDecl.name.trimmed).rawValue",
                                        )
                                    }

                                    SwitchCaseSyntax("case .other(let rawValue): return rawValue")
                                })),
                            )
                        }),
                    ),
                )
            }
        }

        // Synthesize allCases if requested and not already provided.

        let isCaseIterable = declaration.inheritanceClause?.inheritedTypes
            .contains { $0.type.trimmedDescription == "CaseIterable" } ?? false
        let hasAllCases = declaration.memberBlock.members
            .contains { memberBlockItem in
                if let variableDecl = memberBlockItem.decl.as(VariableDeclSyntax.self),
                   variableDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }),
                   variableDecl.bindings.contains(where: {
                       $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.trimmedDescription == "allCases"
                   })
                {
                    true
                } else {
                    false
                }
            }

        let allCases = enumCaseDecls
            .map { ".\($0.name.trimmed)" }
            .joined(separator: ", ")
        let allCasesDecl: DeclSyntax? = if isCaseIterable, !hasAllCases {
            "\(access)static let allCases: [Self] = [\(raw: allCases)]"
        } else {
            nil
        }

        return [
            DeclSyntax(enumCaseDecl),
            DeclSyntax(rawValueTypeAliasDecl),
            DeclSyntax(rawRepresentableInitDecl),
            DeclSyntax(rawValuePropertyDecl),
            allCasesDecl,
        ].compactMap(\.self)
    }
}

extension OtherCaseMacro: ExtensionMacro {
    public static func expansion(of _: AttributeSyntax,
                                 attachedTo _: some DeclGroupSyntax,
                                 providingExtensionsOf type: some TypeSyntaxProtocol,
                                 conformingTo _: [TypeSyntax],
                                 in _: some MacroExpansionContext)
        throws -> [ExtensionDeclSyntax]
    {
        // Add RawRepresentable conformance.
        let rawRepresentableExtensionDecl = try ExtensionDeclSyntax("extension \(type.trimmed): RawRepresentable") {}
        return [
            rawRepresentableExtensionDecl,
        ]
    }
}

@main
struct OtherCasePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        OtherCaseMacro.self,
    ]
}
