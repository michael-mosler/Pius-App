//
//  TTableEntry.swift
//  pius-app-2-ttableExtension
//
//  Created by Michael Mosler-Krings on 24.10.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import WidgetKit
import Foundation

struct TTableEntry: TimelineEntry {
    let date: Date
    let forDay: Int
    let forWeek: Week
    var tTableForDay: ScheduleForDay
}
