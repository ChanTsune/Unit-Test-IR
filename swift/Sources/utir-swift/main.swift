import SwiftSyntax
import SwiftFormat
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
            let file = try decodeer.decode(File.self, from: data)
            if let syntax = IR2SWConverter().visit(file) {
                let outputURL = URL(fileURLWithPath: outputFilePath)
                do {
                    try Syntax(syntax).write(to: outputURL, atomically: false, encoding: .utf8)
                    let linter = SwiftLinter.init(configuration: .init(), diagnosticEngine: .init())
                    try linter.lint(syntax: syntax, assumingFileURL: .init(fileURLWithPath: "source"))
                    let formatter = SwiftFormatter.init(configuration: .init())
                    var txt = ""
                    try formatter.format(syntax: syntax, assumingFileURL: nil, to: &txt)
                    try txt.write(to: outputURL, atomically: false, encoding: .utf8)
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
}

main(CommandLine.arguments)
