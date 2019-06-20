//
//  String.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 20.06.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation

public extension String {
    func allStandardRanges(of filter: String) -> [Range<String.Index>]? {
        var allRanges: [Range<String.Index>]?;
        var subString = self[..<self.endIndex];
        
        while (subString.count > 0) {
            if let range = subString.localizedStandardRange(of: filter) {
                if allRanges == nil {
                    allRanges = [];
                }
                allRanges!.append(range);
                let lowerBound = Substring.Index(utf16Offset: range.upperBound.utf16Offset(in: subString), in: subString);
                subString = subString[lowerBound..<subString.endIndex];
            } else {
                subString = "";
            }
        }

        return allRanges;
    }
}
