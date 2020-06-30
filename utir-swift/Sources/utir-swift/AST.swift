//
//  AST.swift
//  utir-swift
//
//  Created by tsunekwataiki on 2020/06/30.
//

import Foundation

protocol AST { }

protocol Node: AST { }

struct File: Node {
    var body: [Node]
}

struct Assign: Node {
    var target: Node
    var value: Node
}

struct Name: Node {
    enum AccessLevel {
        case Public
        case Internal
        case Package
        case FilePrivate
        case Protected
        case ProtectedInternal
        case PrivateProtected
        case Private
    }
    var name: String
    var type: String?
    var access: AccessLevel?
}

struct Attribute: Node {
    var value: Node
    var attribute: String
}

struct FunctionDef: Node {
    enum Kind {
        case Function
        case StaticMethod
        case BinOp
        case SingleOp
    }
    var name: String
    var kind: Kind
    var args: [Node]
    var kwargs: [String: Node]
    var body: [Node]
    var returnType: String?
}

struct Call: Node {
    var func_: Node
    var args: [Node]
    var kwargs: [String: Node]
}

struct ClassDef: Node {
    var name: String
    var fields: [Name]
    var body: [FunctionDef]
}

struct Value: Node {
    enum Kind {
        case String
        case Int
        case Float
        case Bool
        case Nil
    }
    var kind: Kind
    var value: Any?
}

struct TestProject: Node { // as File
    var name: String
    var testSuites: [TestSuite]
}

struct TestSuite: Node {  // as TestClass
    var name: String
    var testCases: [TestCase]
}

struct TestCase: Node {  // as TestMethod
    var name: String
    var expressions: [Node]
}

struct Assert: Node {  // as assertXX
    enum Kind {
        case Equal
    }
    var kind: Kind
    var excepted: Node
    var actual: Node
    var message: String?
}
