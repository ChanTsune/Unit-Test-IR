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
    var body: [Decl]
    var version: Int
}

struct Block: Node {
    var body:[Stmt]
}

protocol Stmt: Node { }

struct StmtDecl: Stmt {
    var decl: Decl
}

struct StmtExpr: Stmt {
    var expr: Expr
}

protocol Decl: Node { }

struct Var: Decl {
    var name: String
    var type: String?
    var expr: Expr?
}

struct Func: Decl {
    var name: String
    var args: [Arg]
    var body: Block
    struct Arg: Decl {
        var field: Var
        var vararg: Bool
    }
}

struct Class: Decl {
    var name: String
    var bases: [String]
    var constractors: [Func]
    var fields: [Decl]
}

protocol IR: Decl { }

struct Suite: IR {
    var setUp: [Expr]
    var cases: [Case]
    var tearDown: [Expr]
}
protocol Case: IR { }

struct Set: Case {
    var target: Node
    var call: String
    var params: [Params]
    var kind: Kind
    enum Kind {
        case METHOD
        case MEMBER
        case FUNCTION
        case BIN_OP
        case UNARY_OP
    }
}
struct Params: IR {
    var name: String
    var args: [String: Expr]
    var excepted: Expr
    var actual: Expr
    var message: String?
}

struct CaseExpr: Case {
    var name: String
    var expr: [Expr]
    var asserts: [Assert]
}

struct Assert: IR {
    var kind: AssertKind
}

protocol AssertKind: IR { }

struct AssertEqual: AssertKind {
    var excepted: Node
    var actual: Node
    var message: String?
}

protocol Expr: Node { }

struct Name: Expr {
    var name: String
}

struct Constant: Expr {
    var kind: Kind
    var value: String

    enum Kind {
        case STRING
        case BYTES
        case INTEGER
        case FLOAT
        case BOOLEAN
        case NULL
    }
}

struct List: Expr {
    var values: [Expr]
}

struct Tuple: Expr {
    var values: [Expr]
}

struct BinOp: Expr {
    var right: Expr
    var kind: Kind
    var left: Expr

    enum Kind {
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
}
struct UnaryOp: Expr {
    var kind: Kind
    var value: Expr

    enum Kind {
        case PLUS
        case MINUS
    }
}
struct Subscript: Expr {
    var value: Expr
    var index: Expr
}

struct Call: Expr {
    var value: Expr
    var args: [Arg]

    struct Arg {
        var name: String?
        var value: Expr
    }
}

struct Throw: Expr {
    var value: Expr
}

struct Return: Expr {
    var value: Expr
}

struct For: Expr {
    var value: Var
    var generator: Expr
    var body: Block
}

struct Try: Expr {
    var body: Block
}

struct Catch: Expr {
    var type: String
    var body: Block
}
