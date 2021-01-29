//
//  AST.swift
//  utir-swift
//
//  Created by tsunekwataiki on 2020/06/30.
//

import Foundation

protocol UTIRNode {
    var node: String { get }
}

class NodeNotMatchError: Error { }
typealias CodableNode = UTIRNode & Codable

enum NodeCodingKeys: String, CodingKey {
    case node = "Node"
}

struct File: CodableNode {
    var node: String = "File"
    var body: [Decl]
    var version: Int
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case body = "Body"
        case version = "Version"
    }
}

struct Block: CodableNode {
    var node: String = "Block"
    var body: [Stmt]
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case body = "Body"
    }
}

enum Stmt: Codable {
    case decl(StmtDecl)
    case expr(StmtExpr)
    case `throw`(Throw)
    case `return`(Return)
    case `for`(For)
    case `try`(Try)
}

struct StmtDecl: CodableNode {
    var node: String = "Decl"

    var decl: Decl
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case decl = "Decl"
    }
}
struct StmtExpr: CodableNode {
    var node: String = "Expr"

    var expr: Expr
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case expr = "Expr"
    }
}

extension Stmt {
    init(from decoder: Decoder) throws {
        let keycontainer = try decoder.container(keyedBy: NodeCodingKeys.self)
        let container = try decoder.singleValueContainer()
        let node = try keycontainer.decode(String.self, forKey: .node)
        switch node.lowercased() {
        case "decl":
            self = .decl(try container.decode(StmtDecl.self))
        case "expr":
            self = .expr(try container.decode(StmtExpr.self))
        case "for":
            self = .for(try container.decode(For.self))
        case "return":
            self = .return(try container.decode(Return.self))
        case "try":
            self = .try(try container.decode(Try.self))
        case "throw":
            self = .throw(try container.decode(Throw.self))
        default:
            throw DecodingError.typeMismatch(Stmt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .decl(let x):
            try container.encode(x)
        case .expr(let x):
            try container.encode(x)
        case .throw(let x):
            try container.encode(x)
        case .return(let x):
            try container.encode(x)
        case .for(let x):
            try container.encode(x)
        case .try(let x):
            try container.encode(x)
        }
    }
}

enum Decl: Codable {
    case `var`(Var)
    case `func`(Func)
    case `class`(Class)
    case suite(Suite)
    case cases(Case)
}
extension Decl {
    init(from decoder: Decoder) throws {
        let keyContainer = try decoder.container(keyedBy: NodeCodingKeys.self)
        let container = try decoder.singleValueContainer()
        let node = try keyContainer.decode(String.self, forKey: .node)

        switch node.lowercased() {
        case "func":
            self = .func(try container.decode(Func.self))
        case "class":
            self = .class(try container.decode(Class.self))
        case "suite":
            self = .suite(try container.decode(Suite.self))
        case "case":
            self = .cases(try container.decode(Case.self))
        case "var":
            self = .var(try container.decode(Var.self))
        default:
            throw DecodingError.typeMismatch(Decl.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .var(let x):
            try container.encode(x)
        case .func(let x):
            try container.encode(x)
        case .class(let x):
            try container.encode(x)
        case .suite(let x):
            try container.encode(x)
        case .cases(let x):
            try container.encode(x)
        }
    }
}

struct Var: CodableNode {
    var node: String = "Var"
    var name: String
    var type: String?
    var value: Expr?
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case name = "Name"
        case type = "Type"
        case value = "Value"
    }
}

struct Func: CodableNode {
    var node: String = "Func"
    var name: String
    var args: [Arg]
    var body: Block
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case name = "Name"
        case args = "Args"
        case body = "Body"
    }
    struct Arg: CodableNode {
        var node: String = "Arg"
        var field: Var
        var vararg: Bool
        enum CodingKeys: String, CodingKey {
            case node = "Node"
            case field = "Field"
            case vararg = "Vararg"
        }
    }
}

struct Class: CodableNode {
    var node: String = "Class"
    var name: String
    var bases: [String]
    var constractors: [Func]
    var fields: [Decl]
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case name = "Name"
        case bases = "Bases"
        case constractors = "Constractors"
        case fields = "Fields"
    }
}

protocol IR { }

struct Suite: CodableNode, IR {
    var node: String = "Suite"
    var name: String
    var setUp: [Expr]
    var cases: [Case]
    var tearDown: [Expr]

    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case name = "Name"
        case setUp = "SetUp"
        case cases = "Cases"
        case tearDown = "TearDown"
    }
}

indirect enum Expr: Codable {
    case name(Name)
    case constant(Constant)
    case list(List)
    case tuple(Tuple)
    case binOp(BinOp)
    case unaryOp(UnaryOp)
    case `subscript`(Subscript)
    case call(Call)
    case assert(Assert)
}
extension Expr {
    init(from decoder: Decoder) throws {
        let keyContainer = try decoder.container(keyedBy: NodeCodingKeys.self)
        let container = try decoder.singleValueContainer()
        let node = try keyContainer.decode(String.self, forKey: .node)
        switch node.lowercased() {
        case "assert":
            self = .assert(try container.decode(Assert.self))
        case "unaryop":
            self = .unaryOp(try container.decode(UnaryOp.self))
        case "subscript":
            self = .subscript(try container.decode(Subscript.self))
        case "call":
            self = .call(try container.decode(Call.self))
        case "list":
            self = .list(try container.decode(List.self))
        case "tuple":
            self = .tuple(try container.decode(Tuple.self))
        case "binop":
            self = .binOp(try container.decode(BinOp.self))
        case "name":
            self = .name(try container.decode(Name.self))
        case "constant":
            self = .constant(try container.decode(Constant.self))
        default:
            throw DecodingError.typeMismatch(Expr.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .name(let x):
            try container.encode(x)
        case .constant(let x):
            try container.encode(x)
        case .list(let x):
            try container.encode(x)
        case .tuple(let x):
            try container.encode(x)
        case .binOp(let x):
            try container.encode(x)
        case .unaryOp(let x):
            try container.encode(x)
        case .subscript(let x):
            try container.encode(x)
        case .call(let x):
            try container.encode(x)
        case .assert(let x):
            try container.encode(x)
        }
    }
}

struct Name: CodableNode {
    var node: String = "Name"
    var name: String
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case name = "Name"
    }
}

struct Constant: CodableNode {
    var node: String = "Constant"

    var kind: Kind
    var value: String
    enum Kind: String, Codable {
        case STRING
        case BYTES
        case INTEGER
        case FLOAT
        case BOOLEAN
        case NULL
    }
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case kind = "Kind"
        case value = "Value"
    }
}

struct List: CodableNode {
    var node = "List"
    var values: [Expr]
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case values = "Values"
    }
}

struct Tuple: CodableNode {
    var node = "Tuple"
    var values: [Expr]
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case values = "Values"
    }
}

struct BinOp: CodableNode {
    var node: String = "BinOp"
    var right: Expr
    var kind: Kind
    var left: Expr

    enum Kind: String, Codable {
        case DOT
        case ASSIGN
        case ADD
        case SUB
        case MUL
        case DIV
        case MOD
        case LEFT_SHIFT
        case RIGHT_SHIFT
        case NOT_EQUAL
        case IN
    }
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case right = "Right"
        case kind = "Kind"
        case left = "Left"
    }
}
struct UnaryOp: CodableNode {
    var node: String = "UnaryOp"

    var kind: Kind
    var value: Expr

    enum Kind: String, Codable {
        case PLUS
        case MINUS
    }
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case kind = "Kind"
        case value = "Value"
    }
}
struct Subscript: CodableNode {
    var node = "Subscript"
    var value: Expr
    var index: Expr
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case value = "Value"
        case index = "Index"
    }

}

struct Call: CodableNode {
    var node = "Call"
    var value: Expr
    var args: [Arg]

    struct Arg: CodableNode {
        var node = "Arg"
        var name: String?
        var value: Expr
        enum CodingKeys: String, CodingKey {
            case node = "Node"
            case name = "Name"
            case value = "Value"
        }
    }
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case value = "Value"
        case args = "Args"
    }
}

struct Throw: CodableNode {
    var node = "Throw"
    var value: Expr
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case value = "Value"
    }
}

struct Return: CodableNode {
    var node = "Return"
    var value: Expr
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case value = "Value"
    }
}

struct For: CodableNode {
    var node = "For"
    var value: Var
    var generator: Expr
    var body: Block
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case value = "Value"
        case generator = "Generator"
        case body = "Body"
    }
}

struct Try: CodableNode {
    var node = "Try"
    var body: Block
    var `catch`: Catch
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case body = "Body"
        case `catch` = "Catch"
    }
    class Catch: CodableNode { // TODO:
        var node = "Catch"
        var type: String
        var body: Block
        var `catch`: Catch? = nil
        enum CodingKeys: String, CodingKey {
            case node = "Node"
            case type = "Type"
            case body = "Body"
            case `catch` = "Catch"
        }
    }
}

enum Case: Codable {
    case caseBlock(CaseBlock)
    init(from decoder: Decoder) throws {
        let keycontainer = try decoder.container(keyedBy: NodeCodingKeys.self)
        let container = try decoder.singleValueContainer()
        let node = try keycontainer.decode(String.self, forKey: .node)
        switch node.lowercased() {
        case "caseblock":
            self = .caseBlock(try container.decode(CaseBlock.self))
        default:
            throw DecodingError.typeMismatch(Case.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .caseBlock(let x):
            try container.encode(x)
        }
    }
}

struct CaseBlock: CodableNode {
    var node: String = "CaseBlock"
    var name: String
    var body: Block
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case name = "Name"
        case body = "Body"
    }
}
struct Assert: CodableNode, IR {
    var node: String = "Assert"
    var kind: AssertKind
    enum AssertKind: Codable {
        case equal(AssertEqual)
        case failure(AssertFailure)
    }
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case kind = "Kind"
    }
}
extension Assert.AssertKind {
    init(from decoder: Decoder) throws {
        let keycontainer = try decoder.container(keyedBy: NodeCodingKeys.self)
        let container = try decoder.singleValueContainer()
        let node = try keycontainer.decode(String.self, forKey: .node)
        switch node.lowercased() {
        case "equal":
            self = .equal(try container.decode(AssertEqual.self))
        case "failure":
            self = .failure(try container.decode(AssertFailure.self))
        default:
            throw DecodingError.typeMismatch(Assert.AssertKind.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .equal(let x):
            try container.encode(x)
        case .failure(let x):
            try container.encode(x)
        }
    }
}
struct AssertEqual: CodableNode {
    var node: String = "Equal"
    var expected: Expr
    var actual: Expr
    var message: String?

    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case expected = "Expected"
        case actual = "Actual"
        case message = "Message"
    }
}

struct AssertFailure: CodableNode {
    var node: String = "Failure"
    var error: String?
    var `func`: Expr
    var args: [Expr]

    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case error = "Error"
        case `func` = "Func"
        case args = "Args"
    }
}
