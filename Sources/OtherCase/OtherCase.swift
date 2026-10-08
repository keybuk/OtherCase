//
//  OtherCase.swift
//  OtherCase
//
//  Created by Scott James Remnant on 10/7/26.
//

/// A macro that adds an `other(_:)` case to a `RawRepresentable` enum.
@attached(extension, conformances: RawRepresentable)
@attached(member, names: named(RawValue), named(rawValue), named(`init`), named(allCases), arbitrary)
public macro OtherCase() = #externalMacro(module: "OtherCaseMacros", type: "OtherCaseMacro")
