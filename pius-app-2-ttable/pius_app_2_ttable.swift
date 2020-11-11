//
//  pius_app_2_ttable.swift
//  pius-app-2-ttable
//
//  Created by Michael Mosler-Krings on 24.10.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import WidgetKit
import SwiftUI

/// Timeline ptovider for timetable widget view.
struct Provider: TimelineProvider {
    /// For all timetable views this function checks if dashboard can be used. In this case
    /// timetable is able to mix substitution schedule into timetable before displaying a
    /// particular row.
    var canUseDashboard: Bool {
        if AppDefaults.authenticated
            && (AppDefaults.hasLowerGrade
                    || (AppDefaults.hasUpperGrade && AppDefaults.courseList != nil && AppDefaults.courseList!.count > 0
                    )
            ) {
            if let _ = AppDefaults.selectedGradeRow, let _ = AppDefaults.selectedClassRow {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    /// Compute next reload of timeline. Weekdays between 7 and 17 o'clock
    /// timeline is reloaded every 5 minutes and every 60 minutes else.
    /// On weekends refresh is every 30 minutes,
    private var nextUpdateAt: Date {
        var date = Date()
        let dayOfWeek = DateHelper.dayOfWeek()
        
        if dayOfWeek < 5 {
            var calendar = Calendar.current
            calendar.locale = Locale(identifier: "de_DE")
            let hour = Calendar.current.component(.hour, from: date)
            date = date + ((hour >= 7 && hour < 17) ? 5.minutes : 30.minutes)
        } else {
            date = date + 1.hours
        }
        
        return date
    }

    /// Gets widget placeholder based on sample data.
    func placeholder(in context: Context) -> TTableEntry {
        TTableEntry(
            date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, currentLesson: 1,
            tTableForDay: TTableSampleData().scheduleForDay)
    }

    /// Gets a widget snapshot baed on sample data.
    func getSnapshot(in context: Context, completion: @escaping (TTableEntry) -> ()) {
        let tTableEntry = TTableEntry(
            date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, currentLesson: 1,
            tTableForDay: TTableSampleData().scheduleForDay)
        completion(tTableEntry)
    }
    
    /// Get timeline for timetable widget. Timeline provides timetable and vplan data
    /// in ready to use ScheduleForDay object.
    /// - Parameters:
    ///   - context: Widget Context
    ///   - completion: Completion Handler
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TTableEntry] = []
        let currentDate = Date()
        let entryDate = currentDate
        let effectiveWeek = DateHelper.effectiveWeek()
        let effectiveDay = DateHelper.effectiveDay()
        
        let schedule = AppDefaults.useTimetable
            ? AppDefaults.timetable.schedule(forWeek: effectiveWeek, forDay: effectiveDay)
            : nil
        var entry = TTableEntry(
                date: entryDate,
                fromLesson: TimetableHelper.currentLesson() ?? 0,
                forDay: effectiveDay,
                forWeek: effectiveWeek,
                currentLesson: TimetableHelper.currentLesson(),
                tTableForDay: schedule)
            
        // Mix in vplan if timetable is used and vplan is accessible.
        if AppDefaults.useTimetable && canUseDashboard {
            let grade = AppDefaults.gradeSetting
            let vplanLoader = VertretungsplanLoader(forGrade: grade)
            vplanLoader.load({ vplan, isReachable in
                if vplan != nil {
                    let effectiveDate = TimetableHelper.effectiveDate(forWeek: effectiveWeek, forDay: effectiveDay)
                    let filteredVplan = vplan?.filter(onDate: effectiveDate)

                    entry.lastUpdate = vplan?.lastUpdateDate
                    if let gradeItem = filteredVplan?.item(forIndex: 0) {
                        entry.tTableForDay?.map(
                            {
                                (lesson, scheduleItem) in
                                guard let lesson = lesson else { return scheduleItem }
                                let details = gradeItem.details(forLesson: lesson)
                                return scheduleItem.update(withDetails: details)
                            })
                    }
                }

                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .after(nextUpdateAt))
                completion(timeline)
            })

        } else {
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateAt))
            completion(timeline)
        }
    }
}

/// The timetable widget view itself.
struct pius_app_2_ttableEntryView : View {
    @Environment(\.widgetFamily) var size
    var entry: Provider.Entry

    var body: some View {
        let view = TTableWidgetView(family: size, entry: entry)
        return view.body
    }
}

/// Widget view configuration
@main
struct pius_app_2_ttable: Widget {
    let kind: String = "pius_app_2_ttable"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            pius_app_2_ttableEntryView(entry: entry)
        }
        .configurationDisplayName("Pius-App Stundenplan")
        .description("Dieses Widget zeigt Dir deinen Stundenplan an und kombiniert ihn mit Deine aktuellen Vertretungsplan. ")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct pius_app_2_ttable_Previews: PreviewProvider {
    static var tTableEntry: TTableEntry {
        var e = TTableEntry(
            date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, currentLesson: 2,
            tTableForDay: TTableSampleData().scheduleForDay)
        e.day = 0
        e.week = .A
        e.lastUpdate = DateHelper.format("26.10.2020 07:50", using: .standard)
        return e
    }
    
    static var previews: some View {
        pius_app_2_ttableEntryView(entry: tTableEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        pius_app_2_ttableEntryView(entry: tTableEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        pius_app_2_ttableEntryView(entry: tTableEntry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
