//
//  File.swift
//  
//
//  Created by 恒川大輝 on 2021/01/22.
//

import Foundation
import SwiftFormat
import SwiftSyntax

extension SwiftFormatter {
    func format(syntax: SourceFileSyntax, assumingFileURL url: URL?=nil) throws -> String {
        var txt = ""
        try format(syntax: syntax, assumingFileURL: url, to: &txt)
        return txt
    }
}
