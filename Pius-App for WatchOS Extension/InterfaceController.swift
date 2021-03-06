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
    private var appWillDisappear: Bool = false
    
    private var rowTypes: [String] = []
    private var tableRowData: [Any] = []

    @IBOutlet weak var dashboardTable: WKInterfaceTable!
    
    var hyphantedTextAttribute: [NSAttributedString.Key: NSMutableParagraphStyle] {
        get {
            let style = NSMutableParagraphStyle()
            style.hyphenationFactor = 1
            return [NSAttributedString.Key.paragraphStyle: style]
        }
    }
    
    // Shortens long day of week text in inout to a two letter text.
    // Montag -> Mo, Dienstag -> Di. etc.
    private static func shortenDayOfWeekInString(input: String) -> String {
        var output: String = input
        ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"].forEach { word in
            let index = word.index(word.startIndex, offsetBy: 2)
            output = output.replacingOccurrences(of: word, with: word.prefix(upTo: index))
        }
        return output
    }

    // Show a hyphanated text message in content row with a preceeding icon row.
    private func showMessageInRow(_ text: String, forceShow: Bool = false) {
        guard !appWillDisappear || forceShow else { return }
        dashboardTable.setRowTypes(["iconRow", "contentRow"])
        if let tableRow = dashboardTable.rowController(at: 1) as? ContentRow {
            tableRow.label.setAttributedText(NSAttributedString(string: text, attributes: hyphantedTextAttribute))
        }
    }

    // Converts dashboard response to an array of table tow types and an array of table row data.
    private func convertResponse(response: [String: Any]) -> ([String], [Any]){
        var rowTypes: [String] = []
        var tableRowData: [Any] = []
        
        let dateItems = response["vertretungsplaene"] as! NSArray
        
        // For all date items in reponse...
        for dateItem in dateItems {
            let dateItemDictionary = dateItem as! [String: Any]
            let date = dateItemDictionary["date"] as! String
            
            rowTypes.append("dateRow")
            tableRowData.append(InterfaceController.shortenDayOfWeekInString(input: date))
            
            // For all substituted lessons for current date item...
            let gradeItems = dateItemDictionary["gradeItems"] as! NSArray
            for gradeItem in gradeItems {
                let gradeItemDictionary = gradeItem as! [String: Any]
                let vertretungsplanItems = gradeItemDictionary["vertretungsplanItems"] as! NSArray
                
                // Content...
                for vertretungsplanItem in vertretungsplanItems {
                    var vertretungsplanItemArray = vertretungsplanItem as! [String]
                    vertretungsplanItemArray = vertretungsplanItemArray.map { StringHelper.replaceHtmlEntities(input: $0) }
                    
                    rowTypes.append("headerRow")
                    let course = vertretungsplanItemArray[2]
                    if course != "" {
                        tableRowData.append("\(course), \(vertretungsplanItemArray[0]). Std.")
                    } else {
                        tableRowData.append("\(vertretungsplanItemArray[0]). Std.")
                    }
                    
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
                        rowTypes.append("evaRow")
                        tableRowData.append(NSAttributedString(string: vertretungsplanItemArray[7], attributes: hyphantedTextAttribute))
                    }
                }
            }
        }
        
        return (rowTypes, tableRowData)
    }
    
    // Fill dashboard table from row type and table row data of this instance.
    private func displayDashboard() {
        guard !appWillDisappear else { return }
        dashboardTable.setRowTypes(rowTypes)

        for index in 0..<tableRowData.count {
            switch rowTypes[index] {
            case "dateRow":
                guard let tableRow = dashboardTable.rowController(at: index) as? DateRow else { break }
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
                guard let tableRow = dashboardTable.rowController(at: index) as? HeaderRow else { break }
                tableRow.label.setText(tableRowData[index] as? String)
                break
                
            case "contentRow":
                guard let tableRow = dashboardTable.rowController(at: index) as? ContentRow else { break }
                tableRow.label.setAttributedText(tableRowData[index] as? NSAttributedString)
                break
                
            case "evaRow":
                guard let tableRow = dashboardTable.rowController(at: index) as? EvaRow else { break }
                tableRow.label.setAttributedText(tableRowData[index] as? NSAttributedString)
                break
                
            default:
                break
            }
        }
    }

    // Send message to companion app and check reply. App might not be configured
    // for dashboard or there might be an error. In this case an info is displayed
    // and hadLoadError flag is set.
    // When data is loaded dashboard view is filled and presented.
    private func sendMessage(session: WCSession) {
        let action = WKAlertAction.init(title: "Schließen", style:. cancel) {
            self.hadLoadError = true
        }
        
        showMessageInRow("Dein Vertretungsplan wird geladen...",forceShow: true)

        session.sendMessage(["request" : "dashboard"],
            replyHandler: { (response) in
                switch(response["status"] as! String) {
                case "notConfigured":
                    DispatchQueue.main.async {
                        self.presentAlert(withTitle: "Pius-App", message: "Du musst Dich auf Deinem iPhone in der Pius-Aoo anmelden und, wenn Du in der EF, Q1 oder Q2 bist, eine Kursliste anlegen, um die App nutzen zu können.", preferredStyle: .alert, actions: [action])
                    }
                    break;

                case "error":
                    DispatchQueue.main.async {
                        self.presentAlert(withTitle: "Pius-App", message: "Beim Laden des Vertretungsplans ist leider ein Fehler aufgetreten. Prüfe bitte die Internetverbindung Deines iPhones.", preferredStyle: .alert, actions: [action])
                    }
                    break;
                    
                case "loaded":
                    (self.rowTypes, self.tableRowData) = self.convertResponse(response: response)
                    DispatchQueue.main.async {
                        self.displayDashboard()
                    }
                    
                default:
                    break
                }
            },
                errorHandler: { (error) in
                    NSLog("Error sending message : \(error)")
                    
                    if !self.appWillDisappear {
                        DispatchQueue.main.async {
                            self.presentAlert(withTitle: "Pius-App", message: "Dein Vertretungsplan konnte leider nicht geladen werden.", preferredStyle: .alert, actions: [action])
                        }
                    }
            })
    }

    // Called when app awakes. Sets app title, that's it.
    override func awake(withContext context: Any?) {
        NSLog("App is awake")
        super.awake(withContext: context)
        setTitle("Pius-App")
    }
    
    // When app becomes active check if there was a load error before.
    // In this case show message and reset error flag. This is needed
    // because dismissing error message dialog will reactivate app.
    //
    // When there was no error activate session to companion app when not
    // already active and request data. When active sessions exists
    // request data directly.
    override func willActivate() {
        NSLog("App will activate")
    
        super.willActivate()

        appWillDisappear = false
        session = WCSession.default
        session?.delegate = self

        // This should have any relevance only when an error message
        // from request was shown. In this case controller will
        // become active again but we do not want to reload data.
        if hadLoadError {
            showMessageInRow("Dein Vertretungsplan konnte leider nicht geladen werden.")
            hadLoadError = false
        } else if session?.activationState != .activated {
            // When session is not active reactivate.
            session?.activate()
        }
        
        // Just in case: As order of reachability change and willActivate may
        // vary we must make sure that new data is displayed.
        displayDashboard()
    }

    // Called when app deactivates. Resets load error indicator and sets
    // appWillDisappear indicator.
    override func didDeactivate() {
        NSLog("App will deactivate")

        super.didDeactivate()

        // Indicate that app is closing, this e.g. prevents screen updates.
        appWillDisappear = true
        hadLoadError = false
    }

    // When session becomes reachable request new data.
    func sessionReachabilityDidChange(_ session: WCSession) {
        NSLog("Session reachability did change: \(session.isReachable)")
        if session.isReachable {
            sendMessage(session: session)
        }
    }
    
    // New session has become active. If there was an error show dialog and set
    // load error flag otherwise request data from companion app.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            NSLog("\(error)")
            DispatchQueue.main.async {
                let action = WKAlertAction.init(title: "Schließen", style:. cancel) {
                    self.hadLoadError = true
                }
                
                self.presentAlert(withTitle: "Pius-App", message: "Die App kann keine Verbindung mit Deinem iPhone herstellen.", preferredStyle: .alert, actions: [action])
                self.hadLoadError = true
            }
        } else {
            NSLog("New session active, requesting data")
            sendMessage(session: session)
        }
    }
}
