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
    func placeholder(in context: Context) -> TTableEntry {
        TTableEntry(date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, tTableForDay: TTableSampleData().scheduleForDay)
    }

    func getSnapshot(in context: Context, completion: @escaping (TTableEntry) -> ()) {
        let tTableEntry = TTableEntry(date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, tTableForDay: TTableSampleData().scheduleForDay)
        completion(tTableEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [TTableEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = TTableEntry(date: entryDate, fromLesson: 0, forDay: DateHelper.effectiveDay(), forWeek: DateHelper.effectiveWeek(), tTableForDay: Timetable().schedule(forWeek: DateHelper.effectiveWeek(), forDay: DateHelper.effectiveDay()))
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct pius_app_2_ttableEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        let view = TTableWidgetView(entry: entry)
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
        pius_app_2_ttableEntryView(entry: TTableEntry(date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, tTableForDay: TTableSampleData().scheduleForDay))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
