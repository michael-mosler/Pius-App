//
//  TTableSampleData.swift
//  pius-app-2-ttableExtension
//
//  Created by Michael Mosler-Krings on 24.10.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import Foundation

struct TTableSampleData {
    let ttable = Timetable()
    private let courseItem1 = CourseItem(course: "M", teacher: "ABC", courseType: 0, courseNumber: 0, exam: false)
    private let courseItem2 = CourseItem(course: "GE", teacher: "DEF", courseType: 0, courseNumber: 0, exam: false)
    private let courseItem3 = CourseItem(course: "BI", teacher: "GHI", courseType: 0, courseNumber: 0, exam: false)

    init() {
        let scheduleItem1 = ScheduleItem(room: "100", courseItem: courseItem1)
        let scheduleItem2 = ScheduleItem(room: "100", courseItem: courseItem1)
        let scheduleItem3 = ScheduleItem(room: "200", courseItem: courseItem2)
        let scheduleItem4 = ScheduleItem(room: "200", courseItem: courseItem3)
        
        let scheduleForDay = ScheduleForDay()
        scheduleForDay.item(forLesson: 0, scheduleItem1)
        scheduleForDay.item(forLesson: 1, scheduleItem2)
        scheduleForDay.item(forLesson: 2, scheduleItem3)
        scheduleForDay.item(forLesson: 3, scheduleItem4)
 
        ttable.schedule(forWeek: .A, forDay: 0, scheduleForDay)
    }
    
    var scheduleForDay: ScheduleForDay {
        ttable.schedule(forWeek: .A, forDay: 0)
    }
}
