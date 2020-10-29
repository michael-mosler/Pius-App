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
    let numItems: [WidgetFamily:Int] = [.systemMedium: 4, .systemLarge: 8]
    
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
        
        // If current is last but one, last or after last lesson show last lesson in bottom row.
        if fromLesson >= lessons.count - 1 {
            return (lessons.count - 1) - (numItems[family]! - 1)
        }
        
        // Center current lesson.
        return max(fromLesson - 1, 0)
    }

    /// Widget body
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 2, content: {
            let tTableForDay = entry.tTableForDay
            
            Text(String("\(entry.forWeek)-Woche"))
                .font(.callout)
                .padding([.leading, .trailing], 8)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .background(Color("piusBlue"))
                .foregroundColor(.white)
            
            Group(content: {
                // Show up to lessons for this type of widget.
                let fromLesson = effectiveFromLesson(fromLesson: entry.fromLesson, family: family)
                let iconImage = Image("blueinfo")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                
                ForEach((fromLesson..<(fromLesson + numItems[family]!)), id: \.self) { lesson -> AnyView in
                    let tTableEntry = tTableForDay.item(forLesson: lesson)
                    
                    let lesson = ScheduleForDay.effectiveLessonFromIndex(lesson)
                    let lessonText = lesson != nil ? Text("\(lesson!).") : Text("")

                    let courseText: Text = Text(StringHelper.replaceHtmlEntities(input: tTableEntry.courseName))
                    let roomText: AnyView = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: tTableEntry.room))
                    let teacherText: Text = Text(StringHelper.replaceHtmlEntities(input: tTableEntry.teacher))
                    
                    let hstack = HStack(alignment: .center, spacing: 2, content: {
                        lessonText
                            .frame(minWidth: 20, alignment: .trailing)
                        courseText
                            .frame(minWidth: 100, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        roomText
                            .frame(minWidth: 100, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        teacherText
                            .frame(minWidth: 50, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

                        ViewBuilder.buildIf(tTableEntry.isSubstitution ? iconImage : nil)
                    })
                    .padding([.leading, .trailing], 8)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.callout)

                    // If a background is color is defined use it for stack view.
                    if let color = tTableEntry.color {
                        return AnyView(hstack.background(Color(color)))
                    }
                    
                    return AnyView(hstack)
                }

                ViewBuilder.buildIf(
                    entry.lastUpdate != nil
                        ? Text(entry.lastUpdate!)
                            .font(.footnote)
                            .padding([.leading, .trailing], 8)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        : nil
                )
            })
            .frame(maxHeight: .infinity)
        })
    }
}

/// Provides a preview of medium and large size widget.
struct ttable_medium_size_Preview: PreviewProvider {
    static var previews: some View {
        TTableWidgetView(
            family: .systemMedium,
            entry: TTableEntry(
                date: Date(), fromLesson: 0, forDay: 0, forWeek: .A,
                tTableForDay: TTableSampleData().scheduleForDay,
                lastUpdate: "26.10.2020, 07:50 Uhr"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        TTableWidgetView(
            family: .systemLarge,
            entry: TTableEntry(
                date: Date(), fromLesson: 0, forDay: 0, forWeek: .A,
                tTableForDay: TTableSampleData().scheduleForDay,
                lastUpdate: "26.10.2020, 07:50 Uhr"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
