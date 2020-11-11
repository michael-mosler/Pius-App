//
//  TTableMediumSizeProvider.swift
//  pius-app-2-ttableExtension
//
//  Created by Michael Mosler-Krings on 24.10.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import WidgetKit
import SwiftUI

/// Timetable Widget medium size configuration
struct TTableWidgetView: View {
    var family: WidgetFamily
    var entry: TTableEntry

    /// Number of items to show in timetable depending on widget family.
    let numItems: [WidgetFamily : Int] = [.systemSmall: 3, .systemMedium: 4, .systemLarge: 7]
    
    /// Computes the top lesson to show from the requested lesson and
    /// widget size.
    /// - Parameters:
    ///   - fromLesson: Requested top lesson
    ///   - family: Widget family
    /// - Returns: Effective from lesson
    private func effectiveFromLesson(fromLesson: Int, family: WidgetFamily) -> Int {
        // If current time is before first lesson start with 0.
        if fromLesson == Int.min {
            return 0
        }
        
        // Center current lesson.
        let N = numItems[family]!
        return max(
            min(
                fromLesson - N/2,
                lessons.count - N),
            0)
    }
    
    /// Gets the last update date to display as String object.
    /// - Returns: Last update string to use.
    private func lastUpdate() -> String? {
        guard let d = entry.lastUpdate else { return nil }
        
        switch family {
        case .systemSmall:
            return DateHelper.format(d, using: .shortStandard)
        default:
            guard let s = DateHelper.format(d, using: .standard) else { return nil }
            return "\(s) Uhr"
        }
    }
    
    /// Computes opacity value for the given lesson based on configuration
    /// in entry.
    /// - Parameters:
    ///   - lesson: Lesson for which opactity is requested.
    ///   - entry: Entry definition used for display.
    /// - Returns: Opacity value for lesson.
    private func opacityValue(forLesson lesson: Int?, withEntry entry: TTableEntry) -> Double {
        guard entry.forWeek == entry.week ?? DateHelper.week(),
              entry.forDay == entry.day ?? DateHelper.dayOfWeek(),
            lesson == entry.currentLesson
        else { return 1 }
        
        return 2
    }

    /// Widget body
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading) {
            if let tTableForDay = entry.tTableForDay {
                GeometryReader { g in
                    VStack(spacing: 2) {
                        Group {
                            // Show up to lessons for this type of widget.
                            let fromLesson = effectiveFromLesson(fromLesson: entry.fromLesson, family: family)
                            let iconImage = Image("blueinfo")
                                .resizable()
                                .frame(width: 20, height: 20, alignment: .center)

                            ForEach((fromLesson..<(fromLesson + numItems[family]!)), id: \.self) { lesson -> AnyView in
                                let tTableEntry = tTableForDay.item(forLesson: lesson)
                                
                                let effectiveLesson = ScheduleForDay.effectiveLessonFromIndex(lesson)
                                let lessonText = effectiveLesson != nil
                                    ? Text("\(effectiveLesson!).")
                                    : Text("")

                                let courseText: Text = Text(StringHelper.replaceHtmlEntities(input: tTableEntry.courseName))
                                let roomText: AnyView = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: tTableEntry.room))
                                let teacherText: Text = Text(StringHelper.replaceHtmlEntities(input: tTableEntry.teacher))
                                
                                let hstack = HStack(alignment: .center, spacing: 2, content: {
                                    lessonText
                                        .frame(minWidth: 20, alignment: .trailing)
                                    courseText
                                        .frame(minWidth: 100, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                    
                                    // Don't show room and teacher in small widget.
                                    ViewBuilder.buildIf(
                                        family != .systemSmall
                                            ? roomText
                                                .frame(
                                                    minWidth: 100, maxWidth: .infinity,
                                                    maxHeight: .infinity,
                                                    alignment: .leading)
                                        : nil)
                                    
                                    ViewBuilder.buildIf(
                                        family != .systemSmall
                                            ? teacherText
                                                .frame(
                                                    minWidth: 50, maxWidth: .infinity,
                                                    maxHeight: .infinity, alignment: .leading)
                                            : nil)

                                    ViewBuilder.buildIf(tTableEntry.isSubstitution ? iconImage : nil)
                                })
                                .padding([.leading, .trailing], 8)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .font(.callout)

                                // If a background is color is defined use it for stack view.
                                if let color = tTableEntry.color {
                                    return AnyView(
                                        hstack.background(
                                            Color(color)
                                                .opacity(opacityValue(forLesson: effectiveLesson, withEntry: entry))
                                        )
                                    )
                                }
                                return AnyView(hstack)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                }

                let lastUpdate = self.lastUpdate()
                ViewBuilder.buildIf(
                    lastUpdate != nil
                        ? Text(lastUpdate!)
                            .font(.footnote)
                            .padding([.leading, .trailing], 8)
                            .frame(maxWidth: .infinity)
                        : nil
                )
            } else {
                Text("Konfiguriere in den Einstellungen Deinen Stundenplan, um das Widget zu verwenden.")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .widgetURL(URL(string: "pius-app://today")!)
    }
}

/// Provides a preview of medium and large size widget.
struct ttable_medium_size_Preview: PreviewProvider {
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
        TTableWidgetView(family: .systemSmall, entry: tTableEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        TTableWidgetView(family: .systemMedium, entry: tTableEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        TTableWidgetView(family: .systemLarge, entry: tTableEntry)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
