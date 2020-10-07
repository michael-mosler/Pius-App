//
//  pius_app_2_vplan.swift
//  pius-app-2-vplan
//
//  Created by Michael Mosler-Krings on 27.09.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

/// Sample data for widget preview and canvas view
fileprivate var demoDetailItems: Dictionary<String, [DetailItems]> {
    get {
        var detailItems: Dictionary<String, [DetailItems]> = Dictionary<String, [DetailItems]>()
        detailItems["7A"] = [[]]
        detailItems["7A"]!.append([])
        detailItems["7A"]![0].append("1 - 2")
        detailItems["7A"]![0].append("Vertretung")
        detailItems["7A"]![0].append("D")
        detailItems["7A"]![0].append("202 → 309")
        detailItems["7A"]![0].append("IOS")
        detailItems["7A"]![0].append(" ")
        detailItems["7A"]![0].append("&nbsp;")

        detailItems["7A"]!.append([])
        detailItems["7A"]![1].append("3")
        detailItems["7A"]![1].append("Vertretung")
        detailItems["7A"]![1].append("M")
        detailItems["7A"]![1].append("300 404")
        detailItems["7A"]![1].append("FOO")
        detailItems["7A"]![1].append(" ")
        detailItems["7A"]![1].append("Alle Aufgaben im Buch rechnen und auswendig lernen.")

        detailItems["7A"]!.append([])
        detailItems["7A"]![2].append("4")
        detailItems["7A"]![2].append("Vertretung")
        detailItems["7A"]![2].append("D")
        detailItems["7A"]![2].append("202 → 309")
        detailItems["7A"]![2].append("BAR")
        detailItems["7A"]![2].append(" ")
        detailItems["7A"]![2].append("Wir treffen uns in der Aula und gehen von dort zusammen in den Raum.")
        detailItems["7A"]![2].append("Bitte beachtet die E-Mail, die ich euch geschickt habe (Bearbeitung der Aufgaben a) und b) auf Seite 41 sowie Lesen der Seiten 42-45). Viel Erfolg und bis Montag!")

        detailItems["7A"]!.append([])
        detailItems["7A"]![3].append("7")
        detailItems["7A"]![3].append("Entfall")
        detailItems["7A"]![3].append("MU")
        detailItems["7A"]![3].append("---")
        detailItems["7A"]![3].append("XXX")
        detailItems["7A"]![3].append(" ")
        detailItems["7A"]![3].append("&nbsp;")

        detailItems["7A"]!.append([])
        detailItems["7A"]![4].append("1")
        detailItems["7A"]![4].append("Entfall")
        detailItems["7A"]![4].append("GE")
        detailItems["7A"]![4].append("---")
        detailItems["7A"]![4].append("XXX")
        detailItems["7A"]![4].append(" ")
        detailItems["7A"]![4].append("&nbsp;")

        detailItems["7A"]!.append([])
        detailItems["7A"]![5].append("3")
        detailItems["7A"]![5].append("Entfall")
        detailItems["7A"]![5].append("BI")
        detailItems["7A"]![5].append("---")
        detailItems["7A"]![5].append("XXX")
        detailItems["7A"]![5].append(" ")
        detailItems["7A"]![5].append("&nbsp;")

        return detailItems
    }
}
fileprivate var demoGradeItems: [[GradeItem]] {
    get {
        var gradeItems: [[GradeItem]] = [[]]
        gradeItems.append([])
        gradeItems[0].append(GradeItem(grade: "7A"))
        gradeItems[0][0].vertretungsplanItems.append(demoDetailItems["7A"]![0])
        gradeItems[0][0].vertretungsplanItems.append(demoDetailItems["7A"]![1])

        gradeItems.append([])
        gradeItems[1].append(GradeItem(grade: "7A"))
        gradeItems[1][0].vertretungsplanItems.append(demoDetailItems["7A"]![2])
        gradeItems[1][0].vertretungsplanItems.append(demoDetailItems["7A"]![3])

        gradeItems.append([])
        gradeItems[2].append(GradeItem(grade: "7A"))
        gradeItems[2][0].vertretungsplanItems.append(demoDetailItems["7A"]![4])
        gradeItems[2][0].vertretungsplanItems.append(demoDetailItems["7A"]![5])

        return gradeItems
    }
}

fileprivate var demoVPlaene: [VertretungsplanForDate] {
    get {
        let date1 = Date()
        let date2 = date1 + 1.days
        let date3 = date2 + 1.days
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "de_DE")
        
        var vplaene: [VertretungsplanForDate] = []
        vplaene.append(VertretungsplanForDate(date: dateFormatter.string(from: date1), gradeItems: [], expanded: false))
        vplaene[0].gradeItems = demoGradeItems[0]
        vplaene.append(VertretungsplanForDate(date: dateFormatter.string(from: date2), gradeItems: [], expanded: false))
        vplaene[1].gradeItems = demoGradeItems[1]
        vplaene.append(VertretungsplanForDate(date: dateFormatter.string(from: date3), gradeItems: [], expanded: false))
        vplaene[2].gradeItems = demoGradeItems[2]

        return vplaene
    }
}

fileprivate var demoVPlan: Vertretungsplan {
    get {
        var vplan: Vertretungsplan = Vertretungsplan()
        vplan.tickerText = "Heute ist Freitag, der 02.10.2020"
        vplan.additionalText = "Willkommen bei der PiusApp für iOS!"
        vplan.digest = "digest"
        vplan.lastUpdate = "02.10.2020, 18:39 Uhr"
        vplan.vertretungsplaene = demoVPlaene

        return vplan
    }
}

/// Provider for VPlan widget.
struct Provider: IntentTimelineProvider {
    /// Gets widget placeholder based on sample data.
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), configuration: ConfigurationIntent(), canUseDashboard: true, isReachable: true, vplan: demoVPlan)
    }

    /// Gets a widget snapshot baed on sample data.
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), configuration: configuration, canUseDashboard: true, isReachable: true, vplan: demoVPlan)
        completion(entry)
    }

    /// Get timeline. The timeline has one entry only and is reloaded as defined by variable
    /// nextUpdateAt. On refresh vplan is read from backend. If this fails it is tried to
    /// use cache instead.
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [Entry] = []
        let currentDate = Date()
        let entryDate = currentDate

        if !canUseDashboard {
            let entry = Entry(date: entryDate, configuration: configuration, canUseDashboard: false, isReachable: true, vplan: nil)
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }

        let grade = AppDefaults.gradeSetting
        let vplanLoader = VertretungsplanLoader(forGrade: grade)
        vplanLoader.load({ vplan, isReachable in
            var entry: Entry
            
            // When backend load failed use data from cache. If this also fails
            // pass nil (aka error).
            if vplan == nil {
                entry = Entry(date: entryDate, configuration: configuration, canUseDashboard: true, isReachable: isReachable, vplan: try? vplanLoader.loadFromCache())
            } else {
                entry = Entry(date: entryDate, configuration: configuration, canUseDashboard: true, isReachable: isReachable, vplan: vplan)
            }
            
            entries.append(entry)
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateAt))
            completion(timeline)
        })
    }
    
    /// true when dashboard can be used.
    private var canUseDashboard: Bool {
        get {
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
        
        NSLog("Next update at \(date)")
        return date
    }
}

/// Timeline Entry definition.
struct Entry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let canUseDashboard: Bool
    let isReachable: Bool
    let vplan: Vertretungsplan?
    
    var hadError: Bool { vplan == nil }
}

/// Defines layout and content of medium size VPlan widget.
struct MediumSizeView {
    var entry: Entry
    var vplan: Vertretungsplan?
    
    /// Returns standard heading for widget built from text.
    /// - Parameter text: Heading text
    /// - Returns: Heading view
    private func heading(_ text: String) -> AnyView {
        AnyView(
            Text(text)
                .font(.headline)
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 8)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .background(Color("piusBlue"))
                .foregroundColor(.white))
    }

    /// Small Widget body
    var body: AnyView {
        var view: AnyView
        
        // Can we display anything?
        guard entry.canUseDashboard else {
            return AnyView(
                Group(content: {
                    heading("Pius-App")
                    Text("Du musst Dich anmelden und, wenn Du in der EF, Q1 oder Q2 bist, eine Kursliste anlegen, um das Widget verwenden zu können.")
                    Spacer()
                })
            )
        }

        // Any error when loading data?
        guard !entry.hadError else {
            return AnyView(
                Group(content: {
                    heading("Pius-App")
                    Text("Die Daten konnten leider nicht geladen werden.")
                    Spacer()
                })
            )
        }

        // Any data? Should never occur but who knows?
        guard let vplan = entry.vplan else {
            return AnyView(
                Group(content: {
                    heading("Pius-App")
                    Text("Das Widget hat noch keine Informationen zu Deinem Vetretungsplan.")
                    Spacer()
                })
                .widgetURL(URL(string: "pius-app://settings")!)
            )
        }
        
        let nextVPlanForDate = vplan.next
        if nextVPlanForDate.count > 0 {
            let gradeItem: GradeItem? = nextVPlanForDate[0].gradeItems[0]
            let grade: String = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[0][2])
            let lesson: String = gradeItem?.vertretungsplanItems[0][0] ?? ""

            view = AnyView(
                VStack(alignment: .leading, spacing: 2, content: {
                    heading(nextVPlanForDate[0].date)

                    let heading2Text = grade.count > 0
                        ? "Fach/Kurs: \(grade), \(lesson). Stunde"
                        : "\(lesson). Stunde"
                    Text(heading2Text)
                        .font(.subheadline)
                        .padding([.leading, .trailing], 8)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .background(Color("piusBlue").opacity(0.9))
                        .foregroundColor(.white)
                    
                    // Details:
                    // Type
                    // Room
                    // Teacher
                    let items = gradeItem?.vertretungsplanItems[0]
                    let replacementTypeText = StringHelper.replaceHtmlEntities(input: items?[1]) ?? ""
                    let roomText: AnyView = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: items?[3]))
                    let teacherText = StringHelper.replaceHtmlEntities(input: items?[4]) ?? ""

                    HStack(alignment: .top, spacing: 4, content: {
                        Text(replacementTypeText)
                            .font(.callout)
                        roomText
                            .font(.callout)
                            .frame(width: 100)
                        Text(teacherText)
                            .font(.callout)
                            .frame(width: 100)
                    })
                    .padding([.leading, .trailing], 8)

                    // Comment text
                    let commentText = StringHelper.replaceHtmlEntities(input: items?[6]) ?? ""
                    if commentText.count > 0 {
                        Divider()
                        Text(commentText)
                            .font(.callout)
                            .padding([.leading, .trailing], 8)
                    }
                    
                    // EVA
                    if items?.count == 8 {
                        let evaText = StringHelper.replaceHtmlEntities(input: items?[7]) ?? ""
                        Divider()
                        Text(evaText)
                            .font(.callout)
                            .padding([.leading, .trailing], 8)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .background(Color("eva"))
                            .foregroundColor(.black)
                    }

                    Spacer()
                    
                    Text(vplan.lastUpdate)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .font(.footnote)
                })
                .widgetURL(URL(string: "pius-app://dashboard")!)
            )
        } else {
            view = AnyView(
                Group(content: {
                    heading("Pius-App")
                    Text("In den nächsten Tagen hast Du keinen Vertretungsunterricht.")
                        .widgetURL(URL(string: "pius-app://dashboard")!)
                    Spacer()
                    Text(vplan.lastUpdate)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .font(.footnote)
                })
            )
        }
        
        return view
    }
}

struct pius_app_2_vplanEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    var entry: Provider.Entry

    var body: some View {
        let view = MediumSizeView(entry: entry)
        view.body
    }
}

/// Widget view configuration
@main
struct pius_app_2_vplan: Widget {
    let kind: String = "pius_app_2_vplan"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            pius_app_2_vplanEntryView(entry: entry)
        }
        .configurationDisplayName("Pius-App Vertretungsplan")
        .description("Dieses Widget zeigt Dir deine nächste Vertretungsstunde.")
        .supportedFamilies([.systemMedium /*, .systemLarge*/])
    }
}

/// Widget preview provider
struct pius_app_2_vplan_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            pius_app_2_vplanEntryView(entry: Entry(date: Date(), configuration: ConfigurationIntent(), canUseDashboard: true, isReachable: true, vplan:demoVPlan))
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            /*
            pius_app_2_vplanEntryView(entry: Entry(date: Date(), configuration: ConfigurationIntent(), canUseDashboard: true, hadError: false, vplan: demoVPlan))
                .previewContext(WidgetPreviewContext(family: .systemLarge))
            */
        }
    }
}
