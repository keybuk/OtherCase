//
//  OtherCaseDiagnostic.swift
//  OtherCase
//
//  Created by Scott James Remnant on 10/7/26.
//

import SwiftDiagnostics

enum OtherCaseDiagnostic {
    case onlyApplicableToEnum
    case requiresMemberEnum
    case requiresEnumRawValueType
}

extension OtherCaseDiagnostic: DiagnosticMessage {
    var message: String {
        switch self {
        case .onlyApplicableToEnum: "@OtherCase can only be applied to an enum"
        case .requiresMemberEnum: "@OtherCase requires an Options member enum"
        case .requiresEnumRawValueType: "@OtherCase requires member enum inherit from type for RawValue"
        }
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .onlyApplicableToEnum: .error
        case .requiresMemberEnum: .error
        case .requiresEnumRawValueType: .error
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "OtherCase", id: "OtherCase.\(self)")
    }
}
