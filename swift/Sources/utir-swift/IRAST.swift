//
//  AST.swift
//  utir-swift
//
//  Created by tsunekwataiki on 2020/06/30.
//

import Foundation

protocol ClassNameGettable {
    var className: String { get }
}
extension ClassNameGettable {
    var className: String {
        return String(describing: type(of: self)) // ClassName
    }
}
protocol UTIRNode {
    var node: String { get }
}

class NodeNotMatchError: Error { }
typealias CodableNode = UTIRNode & Codable & ClassNameGettable


enum TopLevelNode: Codable {
    case file(File)
    case block(Block)
    case decl(Decl)
    case expr(Expr)
}
extension TopLevelNode {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(File.self) {
            self = .file(x)
            return
        }
        if let x = try? container.decode(Block.self) {
            self = .block(x)
            return
        }
        if let x = try? container.decode(Decl.self) {
            self = .decl(x)
            return
        }
        if let x = try? container.decode(Expr.self) {
            self = .expr(x)
            return
        }
        throw DecodingError.typeMismatch(TopLevelNode.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .file(let x):
            try container.encode(x)
        case .block(let x):
            try container.encode(x)
        case .decl(let x):
            try container.encode(x)
        case .expr(let x):
            try container.encode(x)
        }
    }
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
    case throw_(Throw)
    case return_(Return)
    case for_(For)
    case try_(Try)
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
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(StmtDecl.self) {
            self = .decl(x)
            return
        }
        if let x = try? container.decode(StmtExpr.self) {
            self = .expr(x)
            return
        }
        if let x = try? container.decode(For.self) {
            self = .for_(x)
            return
        }
        if let x = try? container.decode(Return.self) {
            self = .return_(x)
            return
        }
        if let x = try? container.decode(Try.self) {
            self = .try_(x)
            return
        }
        if let x = try? container.decode(Throw.self) {
            self = .throw_(x)
            return
        }
        throw DecodingError.typeMismatch(Stmt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .decl(let x):
            try container.encode(x)
        case .expr(let x):
            try container.encode(x)
        case .throw_(let x):
            try container.encode(x)
        case .return_(let x):
            try container.encode(x)
        case .for_(let x):
            try container.encode(x)
        case .try_(let x):
            try container.encode(x)
        }
    }
}

enum Decl: Codable {
    case var_(Var)
    case func_(Func)
    case class_(Class)
    case suite(Suite)
    case cases(Case)
}
extension Decl {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        print("excec decl stm.")
        if let x = try? container.decode(Func.self) {
            self = .func_(x)
            return
        }
        print("excec decl not func.")
        if let x = try? container.decode(Class.self) {
            self = .class_(x)
            return
        }
        print("excec decl not class.")
        if let x = try? container.decode(Suite.self) {
            self = .suite(x)
            return
        }
        print("exec decl not suite.")
        if let x = try? container.decode(Case.self) {
            self = .cases(x)
            return
        }
        print("exec decl not case.")
        if let x = try? container.decode(Var.self) {
            self = .var_(x)
            return
        }
        print("excec decl not var.")
        throw DecodingError.typeMismatch(Decl.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .var_(let x):
            try container.encode(x)
        case .func_(let x):
            try container.encode(x)
        case .class_(let x):
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
    case subscript_(Subscript)
    case call(Call)
    case assert(Assert)
}
extension Expr {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let x = try? container.decode(Assert.self) {
            self = .assert(x)
            return
        }
        if let x = try? container.decode(UnaryOp.self) {
            self = .unaryOp(x)
            return
        }
        if let x = try? container.decode(Subscript.self) {
            self = .subscript_(x)
            return
        }
        if let x = try? container.decode(Call.self) {
            self = .call(x)
            return
        }
        if let x = try? container.decode(List.self) {
            self = .list(x)
            return
        }
        if let x = try? container.decode(Tuple.self) {
            self = .tuple(x)
            return
        }
        if let x = try? container.decode(BinOp.self) {
            self = .binOp(x)
            return
        }
        if let x = try? container.decode(Name.self) {
            self = .name(x)
            return
        }
        if let x = try? container.decode(Constant.self) {
            self = .constant(x)
            return
        }
        throw DecodingError.typeMismatch(Expr.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
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
        case .subscript_(let x):
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
    enum CodingKeys:String, CodingKey {
        case node = "Node"
        case values = "Values"
    }
}

struct Tuple: CodableNode {
    var node = "Tuple"
    var values: [Expr]
    enum CodingKeys:String, CodingKey {
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
    var catch_: Catch
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case body = "Body"
        case catch_ = "Catch"
    }
    class Catch: CodableNode { // TODO:
        var node = "Catch"
        var type: String
        var body: Block
        var catch_: Catch? = nil
        enum CodingKeys: String, CodingKey {
            case node = "Node"
            case type = "Type"
            case body = "Body"
            case catch_ = "Catch"
        }
    }
}

enum Case: Codable {
    case caseBlock(CaseBlock)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(CaseBlock.self) {
            self = .caseBlock(x)
            return
        }
        throw DecodingError.typeMismatch(Case.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
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
    }
    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case kind = "Kind"
    }
}
extension Assert.AssertKind {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(AssertEqual.self) {
            self = .equal(x)
            return
        }
        throw DecodingError.typeMismatch(Case.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for InstructionElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .equal(let x):
            try container.encode(x)
        }
    }
}
struct AssertEqual: CodableNode {
    var node: String = "Equal"
    var excepted: Expr
    var actual: Expr
    var message: String?

    enum CodingKeys: String, CodingKey {
        case node = "Node"
        case excepted = "Excepted"
        case actual = "Actual"
        case message = "Message"
    }
}
