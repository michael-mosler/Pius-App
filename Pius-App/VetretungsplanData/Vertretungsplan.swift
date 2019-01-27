//
//  Vetretungsplan.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

let lessonStartTimes = ["07:55", "08:40", "09:45", "10:35", "11:25", "12:40", "13:25", "14:30", "15:15", "16:00", "16:45"];

typealias DetailItems = [String];

struct GradeItem: Encodable {
    var grade: String!
    var vertretungsplanItems: [DetailItems]!
    
    init(grade: String!) {
        self.grade = grade;
        self.vertretungsplanItems = [];
    }
}

struct VertretungsplanForDate: Encodable {
    var date: String!
    var gradeItems: [GradeItem]!
    var expanded: Bool!

    init(date: String!, gradeItems: [GradeItem]!, expanded: Bool!) {
        self.date = date;
        self.gradeItems = gradeItems;
        self.expanded = expanded;
    }
}

struct Vertretungsplan: Encodable {
    var tickerText: String? = nil;
    var additionalText: String? = nil;
    var lastUpdate: String! = ""
    var vertretungsplaene: [VertretungsplanForDate] = []
    
    // Returns true when Vertretungsplan has additional text.
    func hasAdditionalText() -> Bool {
        return additionalText != nil && additionalText!.count > 0;
    }
    
    // Returns a filtered Vertretungsplan that holds information on the next item only.
    // It expects that this is a Vertretungsplan instance which is filtered by grade
    // and a given course list.
    var next: [VertretungsplanForDate] {
        get {
            do {
                // Match date.
                let matchDate = try NSRegularExpression(pattern: "\\d{2}.\\d{2}.\\d{4}");

                // Match first number in a string.
                let matchFirstNumber = try NSRegularExpression(pattern: "\\d+");

                // Date formatter.
                let dateFormatter = DateFormatter();
                dateFormatter.locale = Locale(identifier: "de-DE");
                dateFormatter.dateFormat = "dd.MM.yyyy'-'HH:mm";

                // Scan all dates.
                for vertretungsplanForDate in vertretungsplaene {
                    if let dateMatch = matchDate.firstMatch(in: vertretungsplanForDate.date, range: NSMakeRange(0, vertretungsplanForDate.date.count)) {
                        let range = Range(dateMatch.range, in: vertretungsplanForDate.date);
                        let date = String(vertretungsplanForDate.date[range!]) + "-";
                        
                        // This function is for dashboard mode only. Thus, there will be one or none grade
                        // item.
                        if vertretungsplanForDate.gradeItems.count > 0 {
                            let gradeItem = vertretungsplanForDate.gradeItems[0];

                            // Scan all items for the current date.
                            for vertretungsplanItem in gradeItem.vertretungsplanItems {
                                // Which lessons are affected? This may be a single figure or a range like "3-4. Stunde". Anyway
                                // we are interested in the very first figure only as this defines the time.
                                let lessonRange = vertretungsplanItem[0];
                                if let startLessonMatch = matchFirstNumber.firstMatch(in: lessonRange, range: NSMakeRange(0, lessonRange.count)), let range = Range(startLessonMatch.range, in: lessonRange) {
                                    // When something matched convert lesson number to time string, append it to date and convert
                                    // this string to NSDate. Then check if date is greater than current date and time.
                                    let startLesson = (String(lessonRange[range]) as NSString).integerValue;
                                    let lessonStartTime = lessonStartTimes[startLesson - 1];
                                    
                                    if let lessonStartDateAndTime = dateFormatter.date(from: date + lessonStartTime), lessonStartDateAndTime > Date() {
                                        // Build a reduced vertretungsplan that only has the "next" item
                                        var filteredGradeItem = gradeItem;
                                        filteredGradeItem.vertretungsplanItems = [vertretungsplanItem];
                                        
                                        var filteredVertretungsplanForDate = vertretungsplanForDate;
                                        filteredVertretungsplanForDate.gradeItems = [filteredGradeItem];
                                        return [filteredVertretungsplanForDate];
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Nothing found, no next item. Sorry!
                return [];
            } catch {
                NSLog("Failed to return widget data \(error)");
                return [];
            }
        }
    }
}
