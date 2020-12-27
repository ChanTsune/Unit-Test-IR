import Foundation
import SwiftSyntax

extension Syntax {
    func write(to: URL, atomically: Bool, encoding: String.Encoding) throws {
        var text = ""
        write(to: &text)
        try text.write(to: to, atomically: atomically, encoding: encoding)
    }
}
