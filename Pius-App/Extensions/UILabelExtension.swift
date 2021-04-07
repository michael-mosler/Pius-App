//
//  UILabelExtension.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 07.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

extension UILabel {
    /// Highlight text that is enclosed by "*" characters.
    /// - Parameter color: Color to use for highlighting. If not given default color is used.
    func colorText(with color: UIColor?) {
        guard
            let regex: NSRegularExpression = try? NSRegularExpression(pattern: "\\*[^*]*\\*"),
            let attributedSourceText = attributedText
        else { return }
        
        // Find all substrings to color.
        let labelText = attributedSourceText.string
        let searchRange = NSRange(location: 0, length: labelText.count)
        let results = regex.matches(in: labelText, options: [], range: searchRange)

        var linkColor: UIColor
        if #available(iOS 13, *) {
            linkColor = color ?? UIColor.link
        } else {
            linkColor = color ?? UIColor.systemBlue
        }

        let attributedTargetText = NSMutableAttributedString(attributedString: attributedSourceText)
        let targetText = attributedTargetText.string

        // For each substring created a colored attributed string and replace
        // substring with this new attributed string. Remove "*" characters from
        // target.
        attributedTargetText.beginEditing()
        results.forEach({ result in
            if let range = Range(result.range, in: targetText) {
                var matchedText = String(targetText[range.lowerBound..<range.upperBound])
                matchedText = matchedText.replacingOccurrences(of: "*", with: "")
                
                let attributedMatchedText = NSAttributedString(string: matchedText, attributes: [NSAttributedString.Key.foregroundColor : linkColor])
                attributedTargetText.replaceCharacters(in: result.range, with: attributedMatchedText)
            }
        })
        attributedTargetText.endEditing()
        
        attributedText = attributedTargetText
    }
}
