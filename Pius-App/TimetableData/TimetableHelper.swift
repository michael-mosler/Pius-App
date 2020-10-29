//
//  TimetableHelper.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 27.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

struct TimetableHelper {
    /**
     * Gives current lesson. If calculation fails for some reason
     * nil is returned. This value also counts breaks; if you want
     * to read the real lesson then call function realLesson(from:lesson).
     * Before the very first lesson currentLesson is -1, after last lesson
     * value is 99.
     */
    static func currentLesson() -> Int? {
        // Compute number of seconds since 07:55. This is the number of seconds since 07:55h today.
        // row is the row which is covered by the lesson addressed
        // by secondsSince0755. If row is out of scope hide markers.
        guard let epochFor0755 = DateHelper.epoch(forTime: "\(lessons[0]):00") else { return nil }
        let epochSince1970 = Date().timeIntervalSince1970
        let secondsSince0755 = epochSince1970 - epochFor0755

        guard secondsSince0755 >= 0 else { return Int.min }
        
        // Epoch for lesson ends. These are needed to find out the current lesson.
        var lessonEndTimes: [TimeInterval] = []
        for i in 0..<lessonsWithAllEndTimes.count-1 {
            if let epochLessonStart = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[i]):00"),
                let epochLessonEnd = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[i+1]):00") {
                if i == 0 {
                    lessonEndTimes.append(epochLessonEnd - epochLessonStart)
                } else {
                    lessonEndTimes.append(lessonEndTimes[i-1] + epochLessonEnd - epochLessonStart)
                }
            }
        }
        
        // If nothing is found current time is beyond last lessons
        // end.
        guard let lesson = lessonEndTimes.firstIndex(where: { lessonEndTime in return secondsSince0755 <= lessonEndTime })
        else {
            return Int.max
        }

        return lesson
    }
    
    static func offset(forCurrentLesson currentLesson: Int, withTopRow topRow: Int, withRowHeight rowHeight: CGFloat) -> CGFloat? {
        guard currentLesson != Int.min && currentLesson != Int.max,
            let epochLessonStart = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[currentLesson]):00"),
            let epochLessonEnd = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[currentLesson + 1]):00")
        else {
            return nil
        }
        
       // let rowHeight = CGFloat(TodayScreenUnits.timetableRowHeight) // CGFloat((frame.height - 2 * CGFloat(TodayScreenUnits.timetableSpacing)) / CGFloat(lessons.count))
       let duration = CGFloat(epochLessonEnd - epochLessonStart)
       let lessonDuration = CGFloat(Date().timeIntervalSince1970 - epochLessonStart)
       return CGFloat(currentLesson - topRow) * rowHeight + lessonDuration * rowHeight / duration
    }
    
    /// For a given day of week and week (A/B) compute the date that is shown in timetable.
    /// - Parameters:
    ///   - forWeek: A or B week
    ///   - forDay: Day of week
    /// - Returns: Date that is defined by week and day of week.
    static func effectiveDate(forWeek: Week?, forDay: Int?) -> Date? {
        guard let forWeek = forWeek, let forDay = forDay else { return nil }

        let dayOfWeek = DateHelper.dayOfWeek()
        let currentDate = Date()

        if dayOfWeek > 4 {
            return forWeek != DateHelper.week()
                ? currentDate + ((7 - dayOfWeek) + forDay).days     // On weekends we expect the next week to show.
                : currentDate + ((7 - dayOfWeek) + forDay + 7).days // If users toggles week we shift by another 7 days.
            
        } else {
            // If the week shown is the current week than date is by adding
            // difference for day shown and current day of week to the current
            // date.
            // Weeks will differ for weekend only. In this case we need to
            // move to next Monday and then we add the day shown.
            return forWeek == DateHelper.week()
                ? currentDate + (forDay - dayOfWeek).days
                : currentDate + (forDay - dayOfWeek + 7).days
        }
    }
}
