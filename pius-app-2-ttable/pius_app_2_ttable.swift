//
//  pius_app_2_ttable.swift
//  pius-app-2-ttable
//
//  Created by Michael Mosler-Krings on 24.10.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    /// For all timetable views this function checks if dashboard can be used. In this case
    /// timetable is able to mix substitution schedule into timetable before displaying a
    /// particular row.
    var canUseDashboard: Bool {
        if AppDefaults.authenticated && (AppDefaults.hasLowerGrade || (AppDefaults.hasUpperGrade && AppDefaults.courseList != nil && AppDefaults.courseList!.count > 0)) {
            if let _ = AppDefaults.selectedGradeRow, let _ = AppDefaults.selectedClassRow {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }

    func placeholder(in context: Context) -> TTableEntry {
        TTableEntry(
            date: Date(), fromLesson: 0, forDay: 0, forWeek: .A,
            tTableForDay: TTableSampleData().scheduleForDay)
    }

    func getSnapshot(in context: Context, completion: @escaping (TTableEntry) -> ()) {
        let tTableEntry = TTableEntry(
            date: Date(), fromLesson: 0, forDay: 0, forWeek: .A,
            tTableForDay: TTableSampleData().scheduleForDay)
        completion(tTableEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TTableEntry] = []
        let currentDate = Date()
        let entryDate = currentDate
        
        let timetable = AppDefaults.timetable
        let effectiveWeek = DateHelper.effectiveWeek()
        let effectiveDay = DateHelper.effectiveDay()
        let entry = TTableEntry(
            date: entryDate,
            fromLesson: 0, // TimetableHelper.currentLesson() ?? 0,
            forDay: effectiveDay,
            forWeek: effectiveWeek,
            tTableForDay: timetable.schedule(forWeek: effectiveWeek, forDay: effectiveDay))
        entries.append(entry)
        
        if canUseDashboard {
            let grade = AppDefaults.gradeSetting
            let vplanLoader = VertretungsplanLoader(forGrade: grade)
            vplanLoader.load({ vplan_, isReachable in
                // When backend load failed use data from cache. If this also fails
                // pass nil (aka error).
                let vplan = try? vplan_ ?? vplanLoader.loadFromCache()
                
                if vplan != nil {
                    let effectiveDate = TimetableHelper.effectiveDate(forWeek: effectiveWeek, forDay: effectiveDay)
                    let filteredVplan = vplan?.filter(onDate: effectiveDate)

                    if let gradeItem = filteredVplan?.item(forIndex: 0) {
                        entry.tTableForDay.map(
                            {
                                (lesson, scheduleItem) in
                                guard let lesson = lesson else { return scheduleItem }
                                let details = gradeItem.details(forLesson: lesson)
                                return scheduleItem.update(withDetails: details)
                            })
                    }
                }

                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .never)
                completion(timeline)
            })

        } else {
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

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
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct pius_app_2_ttable_Previews: PreviewProvider {
    static var previews: some View {
        pius_app_2_ttableEntryView(
            entry: TTableEntry(
                date: Date(), fromLesson: 0, forDay: 0, forWeek: .A,
                tTableForDay: TTableSampleData().scheduleForDay))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        pius_app_2_ttableEntryView(
            entry: TTableEntry(
                date: Date(), fromLesson: 0, forDay: 0, forWeek: .A,
                tTableForDay: TTableSampleData().scheduleForDay))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
