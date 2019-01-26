//
//  InterfaceController.swift
//  Pius-App for WatchOS Extension
//
//  Created by Michael Mosler-Krings on 20.01.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class DateRow: NSObject {
    @IBOutlet weak var label: WKInterfaceLabel!
    @IBOutlet weak var group: WKInterfaceGroup!
}

class HeaderRow: NSObject {
    @IBOutlet weak var label: WKInterfaceLabel!
}

class ContentRow: NSObject {
    @IBOutlet weak var label: WKInterfaceLabel!
}

class EvaRow: NSObject {
    @IBOutlet weak var label: WKInterfaceLabel!
}

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    private var session: WCSession?
    private var hadLoadError: Bool = false
    @IBOutlet weak var dashboardTable: WKInterfaceTable!
    
    private static func shortenDayOfWeekInString(input: String) -> String {
        var output: String = input
        ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"].forEach { word in
            let index = word.index(word.startIndex, offsetBy: 2)
            output = output.replacingOccurrences(of: word, with: word.prefix(upTo: index))
        }
        return output
    }

    private func showMessageInRow(_ text: String) {
        let style = NSMutableParagraphStyle()
        style.hyphenationFactor = 1
        let attributes = [NSAttributedString.Key.paragraphStyle: style]

        dashboardTable.setRowTypes(["iconRow", "contentRow"])
        let tableRow = dashboardTable.rowController(at: 1) as! ContentRow
        tableRow.label.setAttributedText(NSAttributedString(string: text, attributes: attributes))
    }

    private func sendMessage(session: WCSession) {
        if session.isReachable {
            showMessageInRow("Dein Vertretungsplan wird geladen...")

            session.sendMessage(["request" : "dashboard"],
                replyHandler: { (response) in
                    let action = WKAlertAction.init(title: "Dismiss", style:. cancel) {
                        self.hadLoadError = true
                    }
                    
                    var rowTypes: [String] = []
                    var tableRowData: [Any] = []
                    
                    print(response)

                    switch(response["status"] as! String) {
                    case "notConfigured":
                        DispatchQueue.main.async {
                            self.presentAlert(withTitle: "Pius-App", message: "Du musst Dich auf Deinem iPhone in der Pius-Aoo anmelden und, wenn Du in der EF, Q1 oder Q2 bist, eine Kursliste anlegen, um die App nutzen zu können.", preferredStyle: .alert, actions: [action])
                        }
                        break;

                    case "error":
                        DispatchQueue.main.async {
                            self.presentAlert(withTitle: "Pius-App", message: "Beim Laden der Daten ist ein Fehler aufgetreten. Prüfe bitte die Internetverbindung Deines iPhones.", preferredStyle: .alert, actions: [action])
                        }

                        break;
                        
                    case "loaded":
                        let dateItems = response["vertretungsplaene"] as! NSArray
                        
                        for dateItem in dateItems {
                            let dateItemDictionary = dateItem as! [String: Any]
                            let date = dateItemDictionary["date"] as! String

                            rowTypes.append("dateRow")
                            tableRowData.append(InterfaceController.shortenDayOfWeekInString(input: date))
                            
                            let gradeItems = dateItemDictionary["gradeItems"] as! NSArray
                            for gradeItem in gradeItems {
                                let gradeItemDictionary = gradeItem as! [String: Any]
                                let vertretungsplanItems = gradeItemDictionary["vertretungsplanItems"] as! NSArray
                                for vertretungsplanItem in vertretungsplanItems {
                                    var vertretungsplanItemArray = vertretungsplanItem as! [String]
                                    vertretungsplanItemArray = vertretungsplanItemArray.map { StringHelper.replaceHtmlEntities(input: $0) }
                                    
                                    rowTypes.append("headerRow")
                                    tableRowData.append("\(vertretungsplanItemArray[2]), \(vertretungsplanItemArray[0]). Std.")
                                    
                                    // Type of substitution
                                    rowTypes.append("contentRow")
                                    tableRowData.append(NSAttributedString(string: vertretungsplanItemArray[1]))

                                    // Room
                                    rowTypes.append("contentRow")
                                    tableRowData.append(FormatHelper.roomText(room: vertretungsplanItemArray[3]))
                                    
                                    // Teacher
                                    rowTypes.append("contentRow")
                                    tableRowData.append(FormatHelper.teacherText(oldTeacher: vertretungsplanItemArray[5], newTeacher: vertretungsplanItemArray[4]))
                                    
                                    // Text
                                    if vertretungsplanItemArray[6].count > 0 {
                                        rowTypes.append("contentRow")
                                        tableRowData.append(NSAttributedString(string: vertretungsplanItemArray[6]))
                                    }
                                    
                                    // EVA
                                    if vertretungsplanItemArray.count == 8 && vertretungsplanItemArray[7].count > 0 {
                                        let style = NSMutableParagraphStyle()
                                        style.hyphenationFactor = 1
                                        let attributes = [NSAttributedString.Key.paragraphStyle: style]
                                        
                                        rowTypes.append("evaRow")
                                        tableRowData.append(NSAttributedString(string: vertretungsplanItemArray[7], attributes: attributes))
                                    }
                                }
                            }
                        }
                    
                        self.dashboardTable.setRowTypes(rowTypes)
                        for index in 0..<tableRowData.count {
                            switch rowTypes[index] {
                            case "dateRow":
                                let tableRow = self.dashboardTable.rowController(at: index) as! DateRow
                                tableRow.label.setText(tableRowData[index] as? String)
                                
                                // When no substitutions for the current date set bg color
                                // to gray (inactive).
                                // There is no substituion when either current date row is the
                                // last date row or if next row is also a date row.
                                if index == rowTypes.count - 1 || rowTypes[index + 1] == "dateRow" {
                                    tableRow.group.setBackgroundColor(Config.colorGray)
                                }
                                break

                            case "headerRow":
                                let tableRow = self.dashboardTable.rowController(at: index) as! HeaderRow
                                tableRow.label.setText(tableRowData[index] as? String)
                                break

                            case "contentRow":
                                let tableRow = self.dashboardTable.rowController(at: index) as! ContentRow
                                tableRow.label.setAttributedText(tableRowData[index] as? NSAttributedString)
                                break

                            case "evaRow":
                                let tableRow = self.dashboardTable.rowController(at: index) as! EvaRow
                                tableRow.label.setAttributedText(tableRowData[index] as? NSAttributedString)
                                break

                            default:
                                break
                            }
                        }
                        
                    default:
                        break
                    }
                },
                    errorHandler: { (error) in
                        print("Error sending message: %@", error)
                })
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        if hadLoadError {
            showMessageInRow("Die Daten konnten leider nicht geladen werden.")
            hadLoadError = false

        } else {
            session = WCSession.default
            session?.delegate = self
            
            if session?.activationState == .activated {
                sendMessage(session: session!)
            } else {
                session?.activate()
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activated")
        sendMessage(session: session)
    }
}
