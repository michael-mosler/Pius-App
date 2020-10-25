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
    @Environment(\.widgetFamily) var size
    var entry: TTableEntry
    
    /// Widget body
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 2, content: {
            let tTableForDay = entry.tTableForDay
            let numItems: Int = size == .systemMedium ? 4 : 8
            
            Text(String("\(entry.forWeek)-Woche"))
                .font(.callout)
                .padding([.leading, .trailing], 8)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .background(Color("piusBlue"))
                .foregroundColor(.white)
            
            Group(content: {
                // Show up to lessons for this type of widget.
                ForEach((entry.fromLesson..<(entry.fromLesson + numItems)), id: \.self) { lesson -> AnyView in
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
                            .frame(minWidth: 100, maxHeight: .infinity, alignment: .leading)
                        roomText
                            .frame(minWidth: 100, maxHeight: .infinity, alignment: .leading)
                        teacherText
                            .frame(minWidth: 50, maxHeight: .infinity, alignment: .leading)

                        ViewBuilder.buildIf(
                            tTableEntry.isSubstitution ? Image("blueinfo").resizable() : nil
                        )
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
        TTableWidgetView(entry: TTableEntry(date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, tTableForDay: TTableSampleData().scheduleForDay, lastUpdate: "26.10.2020, 07:50 Uhr"))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        TTableWidgetView(entry: TTableEntry(date: Date(), fromLesson: 0, forDay: 0, forWeek: .A, tTableForDay: TTableSampleData().scheduleForDay, lastUpdate: "26.10.2020, 07:50 Uhr"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
