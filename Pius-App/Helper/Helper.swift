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
    // Since middleware version 2.2.4 old teacher is always blank as this info has been
    // removed from actual schedule for data privacy reasons. Thus, no further formatting
    // is needed anymore and the function only makes sure that a not-nil value is available.
    static func teacherText(oldTeacher: String?, newTeacher: String?) -> NSAttributedString {
        guard let newTeacher = newTeacher else { return NSMutableAttributedString()  }
        return NSAttributedString(string: newTeacher);
    }
    
    static func roomText(room: String?) -> NSAttributedString {
        guard let room = room, room != "" else { return NSAttributedString(string: "") }
        
        let attributedText = NSMutableAttributedString(string: room);
        
        let index = room.firstIndex(of: "→");
        if (index != nil) {
            let length = room.distance(from: room.startIndex, to: room.index(before: index!));
            let strikeThroughRange = NSMakeRange(0, length);
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: strikeThroughRange);
        }
        
        return attributedText;
    }
}

enum Week: Int {
    case A = 0
    case B = 1
}

extension Week {
    static prefix func !(week: Week) -> Week {
        return week == .A ? .B : .A
    }
}

class DateHelper {
    static func week() -> Week? {
        if let calendar = NSCalendar(calendarIdentifier: .ISO8601) {
            let oddWeek = (calendar.component(.weekOfYear, from: Date()) % 2) != 0;
            return (oddWeek) ? .A : .B;
        } else {
            return nil;
        }
    }
    
    // Gets the current week: When odd week num returns "A" else "B".
    static func week() -> String {
        if let week = week() {
            return week == .A ? "A" : "B";
        } else {
            return "Unbekannte";
        }
    }
    
    // The effective week is the week that effectively should be
    // shown. For Mon-Fri this equals currentWeek but on weekends
    // effectiveWeek gets shifted to next week.
    static func effectiveWeek() -> Week {
        guard let week: Week = DateHelper.week() else { return .A }
        return DateHelper.dayOfWeek() <= 4 ? week : !week
    }

    static func dayOfWeek() -> Int {
        var calendar = NSCalendar.current
        calendar.locale = Locale(identifier: "de_DE")
        let weekDay = calendar.component(.weekday, from: Date())
        
        // Monday is day 2 here, we want it to be 0.
        return (weekDay + 5) % 7
    }
    
    // The effective day of week, for weekends this return 0 = Monday otherwise the real
    // day is returned.
    static func effectiveDay() -> Int {
        return DateHelper.dayOfWeek() > 4 ? 0 : DateHelper.dayOfWeek()
    }

    static func formatIsoUTCDate(date: String?) -> String {
        var isoDate: Date
        let dateFormatter = DateFormatter();

        if let date = date {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ";
            isoDate = (dateFormatter.date(from: date) ?? Date())!;
        } else {
            isoDate = Date()
        }
        
        dateFormatter.dateFormat = "EEEE, d. MMMM, HH:mm";
        dateFormatter.locale = Locale(identifier: "de_DE");
        return "\(dateFormatter.string(from: isoDate)) Uhr";
    }
    
    // Returns epoch for the given time for current date.
    // Time must be in Format HH:mm:ss, e.g. 07:55:00.
    static func epoch(forTime time: String) -> TimeInterval? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")

        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateString = dateFormatter.string(from: Date())
        let dateString = "\(todayDateString)T\(time)"
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: dateString)
        return date?.timeIntervalSince1970
    }
}
