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
struct TTableMediumSizeView: View {
    var entry: TTableEntry
    
    /// Widget body
    var body: AnyView {
        var view: AnyView
        let tTableForDay = entry.tTableForDay
        
        view = AnyView(
            VStack(alignment: .leading, spacing: 2, content: {
                Text(String("\(entry.forWeek)-Woche"))
                    .font(.callout)
                    .padding([.leading, .trailing], 8)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .background(Color("piusBlue"))
                    .foregroundColor(.white)
                
                Group(content: {
                    // Show up to lessons for this type of widget.
                    ForEach((0..<4), id: \.self) { lesson -> AnyView in
                        let tTableEntry = tTableForDay.item(forLesson: lesson)
                        
                        let courseText: Text = Text(StringHelper.replaceHtmlEntities(input: tTableEntry.courseName))
                        let roomText: AnyView = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: tTableEntry.room))
                        let teacherText: Text = Text(StringHelper.replaceHtmlEntities(input: tTableEntry.teacher))

                        let hstack = HStack(alignment: .center, spacing: 2, content: {
                            courseText
                                .frame(minWidth: 100, maxHeight: .infinity, alignment: .leading)
                            roomText
                                .frame(minWidth: 100, maxHeight: .infinity, alignment: .leading)
                            teacherText
                                .frame(maxHeight: .infinity, alignment: .leading)
                        })
                        .padding([.leading, .trailing], 8)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .font(.callout)
                        if let color = tTableEntry.color {
                            return AnyView(hstack.background(Color(color)))
                        }
                        
                        return AnyView(hstack)
                    }
                })
                .frame(maxHeight: .infinity)
                
                Text("Datum")
                    .font(.footnote)
                    .padding([.leading, .trailing], 8)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)

            })
        )
        
        return view
    }
}

/// Provides a preview of medium size widget.
struct ttable_medium_size_Preview: PreviewProvider {
    static var previews: some View {
        TTableMediumSizeView(entry: TTableEntry(date: Date(), forDay: 0, forWeek: .A, tTableForDay: TTableSampleData().scheduleForDay))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
