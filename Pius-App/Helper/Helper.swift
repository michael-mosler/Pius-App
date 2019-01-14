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
            .replacingOccurrences(of: "&auml;", with: "ä", options: .literal, range: nil)
            .replacingOccurrences(of: "&uuml;", with: "ü", options: .literal, range: nil)
            .replacingOccurrences(of: "&ouml;", with: "ö", options: .literal, range: nil)
            .replacingOccurrences(of: "&rarr;", with: "→", options: .literal, range: nil)
            .replacingOccurrences(of: "&nbsp;", with: "", options: .literal, range: nil)
            .replacingOccurrences(of: "\\", with: "", options: .literal, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines);
    }
}

class FormatHelper {
    static func teacherText(oldTeacher: String?, newTeacher: String?) -> NSAttributedString {
        guard let oldTeacher = oldTeacher, let newTeacher = newTeacher else { return NSMutableAttributedString()  }
        
        let textRange = NSMakeRange(0, oldTeacher.count);
        let attributedText = NSMutableAttributedString(string: oldTeacher + " → " + newTeacher);
        attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: textRange);
        return attributedText;
        
    }
    
    static func roomText(room: String?) -> NSAttributedString {
        guard let room = room, room != "" else { return NSAttributedString(string: "") }
        
        let attributedText = NSMutableAttributedString(string: room);
        
        let index = room.index(of: "→");
        if (index != nil) {
            let length = room.distance(from: room.startIndex, to: room.index(before: index!));
            let strikeThroughRange = NSMakeRange(0, length);
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: strikeThroughRange);
        }
        
        return attributedText;
    }
}

class DateHelper {
    // Gets the current week: When odd week num returns "A" else "B".
    static func week() -> String {
        if let calendar = NSCalendar(calendarIdentifier: .gregorian) {
            let oddWeek = (calendar.component(.weekOfYear, from: Date()) % 2) != 0;
            return (oddWeek) ? "A" : "B";
        } else {
            return "Unbekannte";
        }

    }
}
