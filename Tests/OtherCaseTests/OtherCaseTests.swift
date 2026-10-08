//
//  OtherCaseTests.swift
//  OtherCase
//
//  Created by Scott James Remnant on 10/7/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling.
// Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(OtherCaseMacros)
import OtherCaseMacros

@MainActor let testMacros: [String: Macro.Type] = [
    "OtherCase": OtherCaseMacro.self,
]
#endif

@MainActor
struct OtherCaseTests {
    @Test
    func `@OtherCase wraps Options enum`() {
        #if canImport(OtherCaseMacros)
        assertMacroExpansion(
            """
            @OtherCase
            enum Test {
                private enum Options: String {
                    case frodo
                    case bilbo
                }
            }
            """,
            expandedSource: """
            enum Test {
                private enum Options: String {
                    case frodo
                    case bilbo
                }

                case frodo, bilbo, other(RawValue)

                typealias RawValue = String

                init(rawValue: RawValue) {
                    switch Options(rawValue: rawValue) {
                    case .frodo:
                        self = .frodo
                    case .bilbo:
                        self = .bilbo
                    default:
                        self = .other(rawValue)
                    }
                }

                var rawValue: RawValue {
                    switch self {
                    case .frodo:
                        return Options.frodo.rawValue
                    case .bilbo:
                        return Options.bilbo.rawValue
                    case .other(let rawValue):
                        return rawValue
                    }
                }
            }

            extension Test: RawRepresentable {
            }
            """,
            macros: testMacros,
        )
        #else
        Test.cancel("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func `@OtherCase can only be applied to an enum`() {
        #if canImport(OtherCaseMacros)
        assertMacroExpansion(
            """
            @OtherCase
            struct Test {
                private enum Options: String {
                    case frodo
                    case bilbo
                }
            }
            """,
            expandedSource: """
            struct Test {
                private enum Options: String {
                    case frodo
                    case bilbo
                }
            }

            extension Test: RawRepresentable {
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@OtherCase can only be applied to an enum", line: 1, column: 1),
            ],
            macros: testMacros,
        )
        #else
        Test.cancel("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func `@OtherCase provides CaseIterable conformance`() {
        #if canImport(OtherCaseMacros)
        assertMacroExpansion(
            """
            @OtherCase
            enum Test: CaseIterable {
                private enum Options: String {
                    case frodo
                    case bilbo
                }
            }
            """,
            expandedSource: """
            enum Test: CaseIterable {
                private enum Options: String {
                    case frodo
                    case bilbo
                }

                case frodo, bilbo, other(RawValue)

                typealias RawValue = String

                init(rawValue: RawValue) {
                    switch Options(rawValue: rawValue) {
                    case .frodo:
                        self = .frodo
                    case .bilbo:
                        self = .bilbo
                    default:
                        self = .other(rawValue)
                    }
                }

                var rawValue: RawValue {
                    switch self {
                    case .frodo:
                        return Options.frodo.rawValue
                    case .bilbo:
                        return Options.bilbo.rawValue
                    case .other(let rawValue):
                        return rawValue
                    }
                }

                static let allCases: [Self] = [.frodo, .bilbo]
            }

            extension Test: RawRepresentable {
            }
            """,
            macros: testMacros,
        )
        #else
        Test.cancel("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func `@OtherCase synthesizes members have parent access`() {
        #if canImport(OtherCaseMacros)
        assertMacroExpansion(
            """
            @OtherCase
            public enum Test: CaseIterable {
                private enum Options: String {
                    case frodo
                    case bilbo
                }
            }
            """,
            expandedSource: """
            public enum Test: CaseIterable {
                private enum Options: String {
                    case frodo
                    case bilbo
                }

                case frodo, bilbo, other(RawValue)

                public typealias RawValue = String

                public init(rawValue: RawValue) {
                    switch Options(rawValue: rawValue) {
                    case .frodo:
                        self = .frodo
                    case .bilbo:
                        self = .bilbo
                    default:
                        self = .other(rawValue)
                    }
                }

                public var rawValue: RawValue {
                    switch self {
                    case .frodo:
                        return Options.frodo.rawValue
                    case .bilbo:
                        return Options.bilbo.rawValue
                    case .other(let rawValue):
                        return rawValue
                    }
                }

                public static let allCases: [Self] = [.frodo, .bilbo]
            }

            extension Test: RawRepresentable {
            }
            """,
            macros: testMacros,
        )
        #else
        Test.cancel("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func `@OtherCase works when enum cases have associated values`() {
        #if canImport(OtherCaseMacros)
        assertMacroExpansion(
            """
            @OtherCase
            enum Test: CaseIterable {
                private enum Options: String {
                    case frodo = "Frodo Baggins"
                    case bilbo = "Bilbo Baggins"
                }
            }
            """,
            expandedSource: """
            enum Test: CaseIterable {
                private enum Options: String {
                    case frodo = "Frodo Baggins"
                    case bilbo = "Bilbo Baggins"
                }

                case frodo, bilbo, other(RawValue)

                typealias RawValue = String

                init(rawValue: RawValue) {
                    switch Options(rawValue: rawValue) {
                    case .frodo:
                        self = .frodo
                    case .bilbo:
                        self = .bilbo
                    default:
                        self = .other(rawValue)
                    }
                }

                var rawValue: RawValue {
                    switch self {
                    case .frodo:
                        return Options.frodo.rawValue
                    case .bilbo:
                        return Options.bilbo.rawValue
                    case .other(let rawValue):
                        return rawValue
                    }
                }

                static let allCases: [Self] = [.frodo, .bilbo]
            }

            extension Test: RawRepresentable {
            }
            """,
            macros: testMacros,
        )
        #else
        Test.cancel("macros are only supported when running tests for the host platform")
        #endif
    }

    @Test
    func `@OtherCase works when enum cases are backticked`() {
        #if canImport(OtherCaseMacros)
        assertMacroExpansion(
            """
            @OtherCase
            enum Test: CaseIterable {
                private enum Options: String {
                    case `case`
                    case `default`
                }
            }
            """,
            expandedSource: """
            enum Test: CaseIterable {
                private enum Options: String {
                    case `case`
                    case `default`
                }

                case `case`, `default`, other(RawValue)

                typealias RawValue = String

                init(rawValue: RawValue) {
                    switch Options(rawValue: rawValue) {
                    case .`case`:
                        self = .`case`
                    case .`default`:
                        self = .`default`
                    default:
                        self = .other(rawValue)
                    }
                }

                var rawValue: RawValue {
                    switch self {
                    case .`case`:
                        return Options.`case`.rawValue
                    case .`default`:
                        return Options.`default`.rawValue
                    case .other(let rawValue):
                        return rawValue
                    }
                }

                static let allCases: [Self] = [.`case`, .`default`]
            }

            extension Test: RawRepresentable {
            }
            """,
            macros: testMacros,
        )
        #else
        Test.cancel("macros are only supported when running tests for the host platform")
        #endif
    }
}
