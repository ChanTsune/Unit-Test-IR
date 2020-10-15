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
            return Syntax(visit(x))
        case .block(let x):
            return Syntax(visit(x))
        case .decl(let x):
            return Syntax(visit(x))
        case .expr(let x):
            return Syntax(visit(x))
        }
    }
    func visit(_ node: File) -> SourceFileSyntax? {
        return SourceFileSyntax {
            $0.addStatement(CodeBlockItemSyntax {
                $0.useItem(Import("XCTest").buildSyntax(format: Format(), leadingTrivia: .zero))
            }.withTrailingTrivia(.newlines(2)))
            for n in node.body {
                if let n = visit(n) {
                    $0.addStatement(CodeBlockItemSyntax {
                        $0.useItem(Syntax(n))
                    })
                } else {
                    print("Skipped \(n)")
                }
            }
        }
    }
    func visit(_ node: Block) -> CodeBlockSyntax? {
        return CodeBlockSyntax {
            $0.useLeftBrace(SyntaxFactory.makeLeftBraceToken())
            $0.useRightBrace(SyntaxFactory.makeRightBraceToken().withLeadingTrivia(.newlines(1)))
            for stmt in node.body {
                if let stmt = visit(stmt) {
                    $0.addStatement(SyntaxFactory.makeCodeBlockItem(
                        item: stmt,
                        semicolon: nil,
                        errorTokens: nil
                    ))
                } else {
                    print("Skipped \(stmt)")
                }
            }
        }
    }
    func visit(_ node: Stmt) -> Syntax? {
        switch node {
        case .decl(let x):
            return Syntax(visit(x.decl))
        case .expr(let x):
            return Syntax(visit(x.expr))
        }
    }
    //MARK:- Decl
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
                    SyntaxFactory.makeToken(.rightBrace, presence: .present).withLeadingTrivia(.spaces(1) + .newlines(1))
                )
                let format = Format()
                for decl in node.fields {
                    print("~~\(node.name)~~")
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
                    for (i, p) in node.args.enumerated() {
                        if let param = visit(p) {
                            if i == node.args.count - 1 {
                                $0.addParameter(param.withTrailingComma(nil))
                            } else {
                                $0.addParameter(param)
                            }
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
        let field = node.field
        return SyntaxFactory.makeFunctionParameter(
            attributes: nil,
            firstName: SyntaxFactory.makeToken(.wildcardKeyword, presence: .present),
            secondName: SyntaxFactory.makeIdentifier(node.field.name).withLeadingTrivia(.spaces(1)),
            colon: SyntaxFactory.makeColonToken(),
            type: SyntaxFactory.makeTypeIdentifier(node.field.type ?? "Any"),
            ellipsis: node.vararg ? SyntaxFactory.makeEllipsisToken() : nil,
            defaultArgument: field.expr != nil ? InitializerClauseSyntax {
                $0.useEqual(SyntaxFactory.makeEqualToken())
                if let e = field.expr, let expr = visit(e) {
                    $0.useValue(expr)
                }
            }: nil,
            trailingComma: SyntaxFactory.makeCommaToken() // TODO: comma
        )
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
            return visit(x)
        case .constant(let x):
            return visit(x)
        case .list(let x):
            return visit(x)
        case .tuple(let x):
            return visit(x)
        case .binOp(let x):
            return visit(x)
        case .unaryOp(let x):
            return visit(x)
        case .subscript_(let x):
            return visit(x)
        case .call(let x):
            return visit(x)
        case .throw_(let x):
            return visit(x)
        case .return_(let x):
            return visit(x)
        case .for_(let x):
            return visit(x)
        case .try_(let x):
            return visit(x)
        case .cases(let x):
            return visit(x)
        case .assert(let x):
            return visit(x)
        }
    }
    func visit(_ node: BinOp) -> ExprSyntax? {
        if node.kind == .DOT {
            switch node.right {
            case .name(let x):
                return ExprSyntax(SyntaxFactory.makeMemberAccessExpr(
                    base: visit(node.left),
                    dot: SyntaxFactory.makeToken(.period, presence: .present),
                    name: SyntaxFactory.makeIdentifier(x.name),
                    declNameArguments: nil
                ))
            default:
                fatalError("dot op right must be Name class! but \(node.right) was recived.")
            }
        }
        var binList: [ExprSyntax] = []
        if let left = visit(node.left) {
            binList.append(left)
        } else {
            print("Skipped \(node.left)")
        }
        switch node.kind {
        case .ADD:
            let binOp = BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("+").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }
            binList.append(ExprSyntax(binOp))
        case .SUB:
            let binOp = BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("-").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }
            binList.append(ExprSyntax(binOp))
        case .ASSIGN:
            binList.append(ExprSyntax(AssignmentExprSyntax {
                $0.useAssignToken(
                    SyntaxFactory.makeToken(.equal, presence: .present).withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        default:
            let binOp = BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("UNSUPPORTED").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }
            binList.append(ExprSyntax(binOp))
        }
        if let right = visit(node.right) {
            binList.append(right)
        } else {
            print("Skipped \(node.right)")
        }
        return ExprSyntax(SyntaxFactory.makeSequenceExpr(elements: SyntaxFactory.makeExprList(binList)).withLeadingTrivia(.newlines(1)))
    }
    func visit(_ node: Name) -> ExprSyntax? {
        let source = SyntaxFactory.makeIdentifierExpr(
            identifier: SyntaxFactory.makeIdentifier(node.name),
            declNameArguments: nil
        )
        return ExprSyntax(source)
    }
    func visit(_ node: Constant) -> ExprSyntax? {
        switch node.kind {
        case .STRING, .BYTES:
            return ExprSyntax(SyntaxFactory.makeStringLiteralExpr(node.value))
        case .INTEGER:
            return ExprSyntax(SyntaxFactory.makeIntegerLiteralExpr(digits: SyntaxFactory.makeIntegerLiteral(node.value)))
        case .FLOAT:
            return ExprSyntax(SyntaxFactory.makeFloatLiteralExpr(floatingDigits: SyntaxFactory.makeFloatingLiteral(node.value)))
        case .BOOLEAN:
            return ExprSyntax(SyntaxFactory.makeBooleanLiteralExpr(
                booleanLiteral: SyntaxFactory.makeToken(
                    node.value.lowercased() == "true" ? .trueKeyword : .falseKeyword,
                    presence: .missing
                )
            ))
        case .NULL:
            return ExprSyntax(SyntaxFactory.makeNilLiteralExpr(nilKeyword: SyntaxFactory.makeNilKeyword()))
        }
    }
    func visit(_ node: List) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Tuple) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: UnaryOp) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Subscript) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Call) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Throw) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Return) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: For) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Try) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Case) -> ExprSyntax? {
        switch node {
        case .caseBlock(let x):
            return visit(x)
        }
    }
    func visit(_ node: CaseBlock) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Assert) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: AssertEqual) -> ExprSyntax? {
        return nil
    }

}
