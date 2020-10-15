//
//  StringExt.swift
//  utir-swift
//
//  Created by tsunekwataiki on 2020/10/15.
//

import Foundation

let defaultEscapeMap:[Character:String] = [
    "\t" : "\\t",
    "\n" : "\\n",
    "\r" : "\\r",
    "\"" : "\\\"",
    "\\" : "\\\\",
]


extension String {
    func escapeForWrite(_ escapeMap:[Character: String] = defaultEscapeMap) -> String {
        return self.map({ escapeMap[$0] ?? String($0) }).joined()
    }
}
