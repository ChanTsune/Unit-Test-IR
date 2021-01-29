//
//  IR2SWConverter.swift
//  utir-swift
//
//  Created by tsunekwataiki on 2020/09/20.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftyPyString


class IR2SWConverter {
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
        case .throw(let x):
            return Syntax(visit(x))
        case .return(let x):
            return Syntax(visit(x))
        case .for(let x):
            return Syntax(visit(x))
        case .try(let x):
            return Syntax(visit(x))
        }
    }
    func visit(_ node: Throw) -> ExprSyntax? {
        return nil
    }
    func visit(_ node: Return) -> StmtSyntax? {
        return StmtSyntax(ReturnStmtSyntax {
            $0.useReturnKeyword(SyntaxFactory.makeReturnKeyword())
            if let expr = visit(node.value) {
                $0.useExpression(expr)
            } else {
                print("Skipped \(node.value)")
            }
        })
    }
    func visit(_ node: For) -> StmtSyntax? {
        return StmtSyntax(ForInStmtSyntax {
            $0.useForKeyword(SyntaxFactory.makeForKeyword())
            $0.useInKeyword(SyntaxFactory.makeInKeyword())
            if let body = visit(node.body) {
                $0.useBody(body)
            } else {
                print("Skipped \(node.body)")
            }
            if let sequence = visit(node.generator) {
                $0.useSequenceExpr(sequence)
            } else {
                print("Skipped \(node.generator)")
            }
            $0.usePattern(PatternSyntax(SyntaxFactory.makeIdentifierPattern(identifier: SyntaxFactory.makeIdentifier(node.value.name))))
        })
    }
    func visit(_ node: Try) -> StmtSyntax? {
        return StmtSyntax(DoStmtSyntax {
            $0.useDoKeyword(SyntaxFactory.makeDoKeyword())
            print("Skipped \(node.body)")
        })
    }
    //MARK:- Decl
    func visit(_ node: Decl) -> DeclSyntax? {
        switch node {
        case .class(let x):
            return visit(x)
        case .func(let x):
            return visit(x)
        case .suite(let x):
            return visit(x)
        case .var(let x):
            return visit(x)
        case .cases(let x):
            return visit(x)
        }
    }
    func visit(_ node: Suite) -> DeclSyntax? {
        let classKeyword = SyntaxFactory.makeClassKeyword().withTrailingTrivia(.spaces(1))
        let source = ClassDeclSyntax {
            $0.useClassKeyword(classKeyword)
            $0.useIdentifier(SyntaxFactory.makeIdentifier(node.name))
            $0.useInheritanceClause(TypeInheritanceClauseSyntax {
                $0.useColon(SyntaxFactory.makeColonToken())
                $0.addInheritedType(InheritedTypeSyntax {
                    $0.useTypeName(SyntaxFactory.makeTypeIdentifier("XCTestCase"))
                })
            })
            $0.useMembers(MemberDeclBlockSyntax {
                $0.useLeftBrace(
                    SyntaxFactory.makeToken(.leftBrace, presence: .present).withLeadingTrivia(.spaces(1))
                )
                $0.useRightBrace(
                    SyntaxFactory.makeToken(.rightBrace, presence: .present).withLeadingTrivia(.spaces(1) + .newlines(1))
                )
                let format = Format()
                for c in node.cases {
                    if let decl = visit(c) {
                        let member = SyntaxFactory
                            .makeMemberDeclListItem(decl: decl, semicolon: nil)
                            .withLeadingTrivia(.newlines(1) + format._makeIndent())
                        $0.addMember(member)
                    } else {
                        print("Skipped \(c)")
                    }
                }
            })
        }.withLeadingTrivia(.newlines(1))
        return DeclSyntax(source)
    }
    func visit(_ node: Class) -> DeclSyntax? {
        let classKeyword = SyntaxFactory.makeClassKeyword().withTrailingTrivia(.spaces(1))
        let source = ClassDeclSyntax {
            $0.useClassKeyword(classKeyword)
            $0.useIdentifier(SyntaxFactory.makeIdentifier(node.name))
            if !node.bases.isEmpty {
                $0.useInheritanceClause(TypeInheritanceClauseSyntax {
                    $0.useColon(SyntaxFactory.makeColonToken())
                    for (i, n) in node.bases.enumerated() {
                        $0.addInheritedType(InheritedTypeSyntax {
                            $0.useTypeName(SyntaxFactory.makeTypeIdentifier(n))
                            if i != node.bases.count - 1 {
                                $0.useTrailingComma(SyntaxFactory.makeCommaToken())
                            }
                        })
                    }
                })
            }

            $0.useMembers(MemberDeclBlockSyntax {
                $0.useLeftBrace(
                    SyntaxFactory.makeToken(.leftBrace, presence: .present).withLeadingTrivia(.spaces(1))
                )
                $0.useRightBrace(
                    SyntaxFactory.makeToken(.rightBrace, presence: .present).withLeadingTrivia(.spaces(1) + .newlines(1))
                )
                let format = Format()
                for f in node.constractors {
                    if let decl = visit(f) {
                        let member = SyntaxFactory
                            .makeMemberDeclListItem(decl: decl, semicolon: nil)
                            .withLeadingTrivia(.newlines(1) + format._makeIndent())
                        $0.addMember(member)
                    } else {
                        print("Skipped \(f)")
                    }
                }
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
            defaultArgument: field.value != nil ? InitializerClauseSyntax {
                $0.useEqual(SyntaxFactory.makeEqualToken())
                if let e = field.value, let expr = visit(e) {
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
                        if let nodeExpr = node.value {
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
    func visit(_ node: Case) -> DeclSyntax? {
        switch node {
        case .caseBlock(let x):
            return visit(x)
        }
    }
    func visit(_ node: CaseBlock) -> DeclSyntax? {
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
                },
                throwsOrRethrowsKeyword: SyntaxFactory.makeThrowsKeyword(),
                output: nil)
            )
        }
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
        case .subscript(let x):
            return visit(x)
        case .call(let x):
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
                    dot: SyntaxFactory.makePeriodToken(),
                    name: SyntaxFactory.makeIdentifier(x.name),
                    declNameArguments: nil
                ))
            default:
                fatalError("dot op right must be Name class! but \(node.right) was recived.")
            }
        } else if node.kind == .IN {
            let right = visit(node.right)
            guard let left = visit(node.left) else {
                print("Skipped \(node) node")
                return nil
            }
            let expr = SyntaxFactory.makeMemberAccessExpr(
                base: right,
                dot: SyntaxFactory.makePeriodToken(),
                name: SyntaxFactory.makeIdentifier("contains"),
                declNameArguments: nil
            )
            let args = [SyntaxFactory.makeTupleExprElement(
                label: nil,
                colon: nil,
                expression: left,
                trailingComma: nil)]
            return ExprSyntax(SyntaxFactory.makeFunctionCallExpr(
                calledExpression: ExprSyntax(expr),
                leftParen: SyntaxFactory.makeLeftParenToken(),
                argumentList: SyntaxFactory.makeTupleExprElementList(args),
                rightParen: SyntaxFactory.makeRightParenToken(),
                trailingClosure: nil,
                additionalTrailingClosures: nil
            ))
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
        case .MUL:
            binList.append(ExprSyntax(BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("*").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        case .DIV:
            binList.append(ExprSyntax(BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("/").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        case .MOD:
            binList.append(ExprSyntax(BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("%").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        case .LEFT_SHIFT:
            binList.append(ExprSyntax(BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("<<").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        case .RIGHT_SHIFT:
            binList.append(ExprSyntax(BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator(">>").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        case .ASSIGN:
            binList.append(ExprSyntax(AssignmentExprSyntax {
                $0.useAssignToken(
                    SyntaxFactory.makeToken(.equal, presence: .present).withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        case .NOT_EQUAL:
            binList.append(ExprSyntax(BinaryOperatorExprSyntax {
                $0.useOperatorToken(
                    SyntaxFactory.makeBinaryOperator("!=").withLeadingTrivia(.spaces(1)).withTrailingTrivia(.spaces(1))
                )
            }))
        case .IN, .DOT:
            fatalError("never execution branch \(node.kind) executed.")
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
            return ExprSyntax(SyntaxFactory.makeStringLiteralExpr(node.value.debugDescription[1, -1]))
        case .INTEGER:
            return ExprSyntax(SyntaxFactory.makeIntegerLiteralExpr(digits: SyntaxFactory.makeIntegerLiteral(node.value)))
        case .FLOAT:
            return ExprSyntax(SyntaxFactory.makeFloatLiteralExpr(floatingDigits: SyntaxFactory.makeFloatingLiteral(node.value)))
        case .BOOLEAN:
            return ExprSyntax(SyntaxFactory.makeBooleanLiteralExpr(
                booleanLiteral: node.value.lowercased() == "true" ? SyntaxFactory.makeTrueKeyword() : SyntaxFactory.makeFalseKeyword()
            ))
        case .NULL:
            return ExprSyntax(SyntaxFactory.makeNilLiteralExpr(nilKeyword: SyntaxFactory.makeNilKeyword()))
        }
    }
    func visit(_ node: List) -> ExprSyntax? {
        return ExprSyntax(ArrayExprSyntax {
            $0.useLeftSquare(SyntaxFactory.makeLeftSquareBracketToken())
            for (i, item) in node.values.enumerated() {
                if let item = visit(item) {
                    $0.addElement(SyntaxFactory.makeArrayElement(expression: item, trailingComma: i != (node.values.count - 1) ? SyntaxFactory.makeCommaToken() : nil))
                } else {
                    print("Skipped \(item)")
                }
            }
            $0.useRightSquare(SyntaxFactory.makeRightSquareBracketToken())
        })
    }
    func visit(_ node: Tuple) -> ExprSyntax? {
        return ExprSyntax(TupleExprSyntax {
            $0.useLeftParen(SyntaxFactory.makeLeftParenToken())
            $0.useRightParen(SyntaxFactory.makeRightParenToken())
            for (i, item) in node.values.enumerated() {
                if let item = visit(item) {
                    $0.addElement(SyntaxFactory.makeTupleExprElement(label: nil, colon: nil, expression: item, trailingComma: i != (node.values.count - 1) ? SyntaxFactory.makeCommaToken() : nil))
                } else {
                    print("Skipped \(item)")
                }
            }
        })
    }
    func visit(_ node: UnaryOp) -> ExprSyntax? {
        // TODO: postfix op
        return ExprSyntax(PrefixOperatorExprSyntax {
            switch node.kind {
            case .MINUS:
                $0.useOperatorToken(SyntaxFactory.makePrefixOperator("-"))
            case .PLUS:
                $0.useOperatorToken(SyntaxFactory.makePrefixOperator("+"))
            }
            if let expr = visit(node.value) {
                $0.usePostfixExpression(expr)
            } else {
                print("Skipped \(node.value)")
            }
        })
    }
    func visit(_ node: Subscript) -> ExprSyntax? {
        return ExprSyntax(SubscriptExprSyntax {
            $0.useLeftBracket(SyntaxFactory.makeLeftSquareBracketToken())
            $0.useRightBracket(SyntaxFactory.makeRightSquareBracketToken())
            if let expr = visit(node.value) {
                $0.useCalledExpression(expr)
            } else {
                print("Skipped \(node.value)")
            }
            if let expr = visit(node.index) {
                $0.addArgument(TupleExprElementSyntax {
                    $0.useExpression(expr)
                })
            } else {
                print("Skipped \(node.index)")
            }
        })
    }
    func visit(_ node: Call) -> ExprSyntax? {
        return ExprSyntax(FunctionCallExprSyntax {
            $0.useLeftParen(SyntaxFactory.makeLeftParenToken())
            $0.useRightParen(SyntaxFactory.makeRightParenToken())
            if let expr = visit(node.value) {
                $0.useCalledExpression(expr)
            } else {
                print("Skipped \(node.value)")
            }
            for (i, arg) in node.args.enumerated() {
                $0.addArgument(TupleExprElementSyntax {
                    if let expr = visit(arg.value) {
                        $0.useExpression(expr)
                    } else {
                        print("Skipped \(arg.value)")
                    }
                    if node.args.count - 1 != i {
                        $0.useTrailingComma(SyntaxFactory.makeCommaToken())
                    }
                })
            }
        })
    }
    func visit(_ node: Assert) -> ExprSyntax? {
        switch node.kind {
        case .equal(let x):
            return visit(x)
        case .failure(let x):
            return visit(x)
        }
    }
    func visit(_ node: AssertEqual) -> ExprSyntax? {
        return ExprSyntax(FunctionCallExprSyntax {
            $0.useLeftParen(SyntaxFactory.makeLeftParenToken())
            $0.useRightParen(SyntaxFactory.makeRightParenToken())
            $0.useCalledExpression(
                ExprSyntax(SyntaxFactory.makeIdentifierExpr(
                    identifier: SyntaxFactory.makeIdentifier("XCTAssertEqual"),
                    declNameArguments: nil
                ))
            )
            let args = [node.actual, node.expected]
            for (i, arg) in args.enumerated() {
                $0.addArgument(TupleExprElementSyntax {
                    if let expr = visit(arg) {
                        $0.useExpression(expr)
                    } else {
                        print("Skipped \(arg)")
                    }
                    if args.count - 1 != i {
                        $0.useTrailingComma(SyntaxFactory.makeCommaToken())
                    }
                })
            }
        })
    }
    func visit(_ node: AssertFailure) -> ExprSyntax? {
        let callExpr = ExprSyntax(FunctionCallExprSyntax {
            $0.useRightParen(SyntaxFactory.makeRightParenToken())
            $0.useLeftParen(SyntaxFactory.makeLeftParenToken())
            if let ex = visit(node.func) {
                $0.useCalledExpression(ex)
            } else {
                print("Skipped \(node.func)")
            }
            for (i, arg) in node.args.enumerated() {
                $0.addArgument(TupleExprElementSyntax {
                    if let expr = visit(arg) {
                        $0.useExpression(expr)
                    } else {
                        print("Skipped \(arg)")
                    }
                    if node.args.count - 1 != i {
                        $0.useTrailingComma(SyntaxFactory.makeCommaToken())
                    }
                })
            }
        })
        return ExprSyntax(FunctionCallExprSyntax {
            $0.useLeftParen(SyntaxFactory.makeLeftParenToken())
            $0.useRightParen(SyntaxFactory.makeRightParenToken())
            $0.useCalledExpression(
                ExprSyntax(SyntaxFactory.makeIdentifierExpr(
                    identifier: SyntaxFactory.makeIdentifier("XCTAssertThrowsError"),
                    declNameArguments: nil
                ))
            )
            $0.addArgument(TupleExprElementSyntax {
                $0.useExpression(ExprSyntax(ClosureExprSyntax {
                    $0.useLeftBrace(SyntaxFactory.makeLeftBraceToken())
                    $0.useRightBrace(SyntaxFactory.makeRightBraceToken())
                    $0.addStatement(CodeBlockItemSyntax {
                        $0.useItem(Syntax(ExprSyntax(TryExprSyntax {
                            $0.useTryKeyword(SyntaxFactory.makeTryKeyword())
                            $0.useExpression(callExpr)
                        })))
                    })
                }))
            })
        })
    }

}
