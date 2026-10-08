//
//  main.swift
//  OtherCase
//
//  Created by Scott James Remnant on 10/7/26.
//

// swiftformat:disable redundantBackticks

import OtherCase

@OtherCase
public enum EnumTest {
    private enum Options: String {
        case frodo
        case bilbo
        case `pippin`
        case meriadoc = "merry"
    }
}

var frodo = EnumTest.frodo
var bilbo = EnumTest.bilbo
var `pippin` = EnumTest.`pippin`
var merry = EnumTest.meriadoc
var gandalf = EnumTest.other("gandalf")

for fellow in [frodo, bilbo, `pippin`, merry, gandalf] {
    print("\(String(reflecting: fellow.rawValue)) = \(String(reflecting: fellow))")
}

frodo = EnumTest(rawValue: "frodo")
bilbo = EnumTest(rawValue: "bilbo")
`pippin` = EnumTest(rawValue: "pippin")
merry = EnumTest(rawValue: "merry")
gandalf = EnumTest(rawValue: "gandalf")

for fellow in [frodo, bilbo, `pippin`, merry, gandalf] {
    print("\(String(reflecting: fellow.rawValue)) = \(String(reflecting: fellow))")
}
