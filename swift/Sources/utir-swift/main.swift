import SwiftSyntax
import Yams
import Foundation

/// AddOneToIntegerLiterals will visit each token in the Syntax tree, and
/// (if it is an integer literal token) add 1 to the integer and return the
/// new integer literal token.
class AddOneToIntegerLiterals: SyntaxRewriter {
    override func visit(_ token: TokenSyntax) -> Syntax {
        // Only transform integer literals.
        guard case .integerLiteral(let text) = token.tokenKind else {
            return Syntax(token)
        }

        // Remove underscores from the original text.
        let integerText = String(text.filter { ("0"..."9").contains($0) })

        // Parse out the integer.
        let int = Int(integerText)!

        // Create a new integer literal token with `int + 1` as its text.
        let newIntegerLiteralToken = token.withKind(.integerLiteral("\(int + 1)"))

        // Return the new integer literal.
        return Syntax(newIntegerLiteralToken)
    }
}

class MyVisitor: SyntaxAnyVisitor {
    override func visitAnyPost(_ node: Syntax) {
        print(type(of: node))
        print(node.customMirror)
    }
}


func _main(_ argv: [String]) {
    do {
        print(FileManager.default.currentDirectoryPath)
        let file = "/Users/tsunekwataiki/Documents/GitHub/Unit-Test-IR/swift/Sources/utir-swift/main.swift"
        let url = URL(fileURLWithPath: file)
        let sourceFile = try SyntaxParser.parse(url)
        MyVisitor().walk(sourceFile)
        let incremented = AddOneToIntegerLiterals().visit(sourceFile)
        print(incremented)
    } catch {
        print(error)
    }
}

func main(_ argv: [String]) {
    print(argv)
    if argv.count >= 3 {
        let inputFilePath = argv[1]
        let outputFilePath = argv[2]
        let decodeer = YAMLDecoder()
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: inputFilePath))
            let file = try decodeer.decode(TopLevelNode.self, from: data)
            switch file {
            case .file(let x):
                let topLevel = TopLevelNode.file(x)
                if let syntax = IR2SWConverter().visit(topLevel) {
                    print(syntax)
                    try syntax.write(to: URL(fileURLWithPath: outputFilePath), atomically: false, encoding: .utf8)
                }
            default:
                print("default")
            }
        } catch {
            print(error)
        }
    }
}

main(CommandLine.arguments)
