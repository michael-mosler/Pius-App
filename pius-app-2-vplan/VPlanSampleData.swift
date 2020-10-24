//
//  vplan_sample_data.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 23.10.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import Foundation

struct VPlanSampleData {
    /// Sample data for widget preview and canvas view
    var demoDetailItems: Dictionary<String, [DetailItems]> {
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
    var demoGradeItems: [[GradeItem]] {
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
    
    var demoVPlaene: [VertretungsplanForDate] {
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
    
    public var demoVPlan: Vertretungsplan {
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
}
