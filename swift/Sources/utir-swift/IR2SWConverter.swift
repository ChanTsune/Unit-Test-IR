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
        case .file(let fileNode):
            print(fileNode)
            return SourceFile {
                Import("XCTest")
            }.buildSyntax(format: Format(), leadingTrivia: .zero)
        default:
            print("unsupported node", node)
        }
        return nil
    }
}
