//
//  TTableEntry.swift
//  pius-app-2-ttableExtension
//
//  Created by Michael Mosler-Krings on 24.10.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import SwiftUI
import WidgetKit
import Foundation

/// Payload passed from timeline provider to view provider. Some
/// properties are used for preview only when it does not make
/// sense to use dynamic values.
struct TTableEntry: TimelineEntry {
    let date: Date
    let fromLesson: Int
    let forDay: Int
    let forWeek: Week
    let currentLesson: Int?
    let tTableForDay: ScheduleForDay?
    var lastUpdate: Date?
    var colorScheme: ColorScheme = .light
    
    // These are used for preview and overwrite the current
    // computed day and week.
    var day: Int?
    var week: Week?

    init(date: Date, fromLesson: Int, forDay: Int, forWeek: Week, currentLesson: Int?, tTableForDay: ScheduleForDay?, lastUpdate: Date? = nil) {
        self.date = date
        self.fromLesson = fromLesson
        self.forDay = forDay
        self.forWeek = forWeek
        self.currentLesson = currentLesson
        self.tTableForDay = tTableForDay
        self.lastUpdate = lastUpdate
    }
}
