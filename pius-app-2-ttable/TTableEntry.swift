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

struct TTableEntry: TimelineEntry {
    let date: Date
    let fromLesson: Int
    let forDay: Int
    let forWeek: Week
    let tTableForDay: ScheduleForDay
    let lastUpdate: String?

    init(date: Date, fromLesson: Int, forDay: Int, forWeek: Week, tTableForDay: ScheduleForDay, lastUpdate: String? = nil) {
        self.date = date
        self.fromLesson = fromLesson
        self.forDay = forDay
        self.forWeek = forWeek
        self.tTableForDay = tTableForDay
        self.lastUpdate = lastUpdate
    }
}
