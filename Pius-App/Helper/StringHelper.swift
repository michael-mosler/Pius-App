//
//  StringHelper.swift
//  Pius-App
//
//  Created by Michael on 18.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

class StringHelper {
    static func replaceHtmlEntities(input: String?) -> String! {
        guard let input = input else { return "" };
        return input
            .replacingOccurrences(of: "&rarr;", with: "→", options: .literal, range: nil)
            .replacingOccurrences(of: "&nbsp;", with: "", options: .literal, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines);
    }
}
