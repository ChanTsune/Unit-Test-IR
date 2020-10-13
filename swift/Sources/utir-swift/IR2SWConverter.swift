//
//  IR2SWConverter.swift
//  utir-swift
//
//  Created by tsunekwataiki on 2020/09/20.
//

import SwiftSyntax
import SwiftSyntaxBuilder


class IR2SWConverter {
    func visit(_ node: TopLevelNode) -> Syntax? {
        switch node {
        case .file(let x):
            return visit(x)
        case .block(let x):
            return Syntax(visit(x))
        case .decl(let x):
            return Syntax(visit(x))
        case .expr(let x):
            return Syntax(visit(x))
        }
    }
    func visit(_ node: File) -> Syntax? {
        var source = SourceFileSyntax {
            $0.addStatement(CodeBlockItemSyntax {
                $0.useItem(Import("XCTest").buildSyntax(format: Format(), leadingTrivia: .zero))
            }.withTrailingTrivia(.newlines(2)))
        }
        for n in node.body {
            if let n = visit(n) {
                source = source.addStatement(CodeBlockItemSyntax {
                    $0.useItem(Syntax(n))
                })
            } else {
                print("Skipped \(n)")
            }
        }
        return Syntax(source)
    }
    func visit(_ node: Block) -> CodeBlockSyntax? {
        return CodeBlockSyntax {
            $0.useLeftBrace(SyntaxFactory.makeLeftBraceToken())
            $0.useRightBrace(SyntaxFactory.makeRightBraceToken())
        }
    }
    func visit(_ node: Decl) -> DeclSyntax? {
        switch node {
        case .class_(let x):
            return visit(x)
        case .func_(let x):
            return visit(x)
        case .suite(let x):
            return visit(x)
        case .var_(let x):
            return visit(x)
        }
    }
    //MARK:- Decl
    func visit(_ node: Suite) -> DeclSyntax? {
        return Struct(node.name) {

        }.buildDecl(format: Format(), leadingTrivia: .newlines(1))
    }
    func visit(_ node: Class) -> DeclSyntax? {
        let classKeyword = SyntaxFactory.makeClassKeyword().withTrailingTrivia(.spaces(1))
        let source = ClassDeclSyntax {
            $0.useClassKeyword(classKeyword)
            $0.useIdentifier(SyntaxFactory.makeIdentifier(node.name))
            $0.useMembers(MemberDeclBlockSyntax {
                $0.useLeftBrace(
                    SyntaxFactory.makeToken(.leftBrace, presence: .present).withLeadingTrivia(.spaces(1))
                )
                $0.useRightBrace(
                    SyntaxFactory.makeToken(.rightBrace, presence: .present).withLeadingTrivia(.spaces(1))
                )
                let format = Format()
                for decl in node.fields {
                    if let decl = visit(decl) {
                        let member = SyntaxFactory
                            .makeMemberDeclListItem(decl: decl, semicolon: nil)
                            .withLeadingTrivia(.newlines(1) + format._makeIndent())
                        $0.addMember(member)
                    } else {
                        print("Skipped \(decl)")
                    }
                }
            })
        }.withLeadingTrivia(.newlines(1))
        return DeclSyntax(source)
    }
    func visit(_ node: Func) -> DeclSyntax? {
        let funcKeyword = SyntaxFactory.makeFuncKeyword().withTrailingTrivia(.spaces(1))
        let source = FunctionDeclSyntax {
            $0.useFuncKeyword(funcKeyword)
            $0.useIdentifier(SyntaxFactory.makeIdentifier(node.name))
            if let body = visit(node.body) {
                $0.useBody(body)
            }
            $0.useSignature(SyntaxFactory.makeFunctionSignature(
                input: ParameterClauseSyntax {
                    $0.useLeftParen(SyntaxFactory.makeLeftParenToken())
                    $0.useRightParen(SyntaxFactory.makeRightParenToken())
                    for p in node.args {
                        if let param = visit(p) {
                            $0.addParameter(param)
                        } else {
                            print("Skipped \(p)")
                        }
                    }
                },
                throwsOrRethrowsKeyword: nil,
                output: nil)
            )
        }
        return DeclSyntax(source)
    }
    func visit(_ node: Func.Arg) -> FunctionParameterSyntax? {
        return nil
    }
    func visit(_ node: Var) -> DeclSyntax? {
        let source = SyntaxFactory.makeVariableDecl(
            attributes: nil,
            modifiers: nil,
            letOrVarKeyword: SyntaxFactory.makeLetKeyword(),
            bindings: SyntaxFactory.makePatternBindingList([])
                .appending(SyntaxFactory.makePatternBinding(
                    pattern: PatternSyntax(IdentifierPatternSyntax {
                        $0.useIdentifier(SyntaxFactory.makeIdentifier(node.name))
                    }),
                    typeAnnotation: nil,
                    initializer: InitializerClauseSyntax {
                        $0.useEqual(SyntaxFactory.makeEqualToken())
                        if let nodeExpr = node.expr {
                            if let expr = visit(nodeExpr) {
                                $0.useValue(expr)
                            } else {
                                print("Skipped \(nodeExpr)")
                            }
                        }
                    },
                    accessor: nil,
                    trailingComma: nil
                    )
                )
        )
        return DeclSyntax(source)
    }
    //MARK:- Expr
    func visit(_ node: Expr) -> ExprSyntax? {
        switch node {
        case .name(let x):
            return nil
        case .constant(let x):
            return nil
        case .list(let x):
            return nil
        case .tuple(let x):
            return nil
        case .binOp(let x):
            return nil
        case .unaryOp(let x):
            return nil
        case .subscript_(let x):
            return nil
        case .call(let x):
            return nil
        case .throw_(let x):
            return nil
        case .return_(let x):
            return nil
        case .for_(let x):
            return nil
        case .try_(let x):
            return nil
        case .cases(let x):
            return nil
        case .assert(let x):
            return nil
        }
    }
}
