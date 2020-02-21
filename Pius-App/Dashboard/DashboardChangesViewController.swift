//
//  DashboardChangesViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 28.06.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class DashboardChangesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public var data: NSDictionary = NSDictionary()
    private var deltaList: NSArray? { return data["deltaList"] as? NSArray }
    private var itemList: DateItems = []
    
    private let rowHeight: CGFloat = 44

    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var tablewView: UITableView!
    
    // Tags used for labels.
    private struct tags {
        enum details: Int {
            case type = 1, room, teacher
        }
    }

    private struct tagsOld {
        enum details: Int {
            case type = 4, room, teacher
        }
    }

    @IBOutlet weak var doneAction: UIBarButtonItem!
    
    @IBAction func doneAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let deltaList = self.deltaList {
            itemList = ChangeListDateItemCollection(from: deltaList).dateItems
        }
        timestampLabel.text = DateHelper.formatIsoUTCDate(date: data["timestamp"] as? String)
        tablewView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (_, deltaLists) = itemList[indexPath.section]

        if indexPath.row == 0 {
            return rowHeight
        }

        let deltaList = deltaLists[(indexPath.row - 1) / 8]
        let logicalRow = (indexPath.row - 1) % 8

        switch logicalRow {
        // Spacer
        case 0: return 2
            
        // Type
        case 1: return 16
            
        // Spacer
        case 2: return 2

        // Details New
        case 4:
            if let details = deltaList["detailsNew"] as? NSArray, details.count > 0 {
                return rowHeight
            } else {
                return 0
            }
            
        // Details Old
        case 5:
            if let details = deltaList["detailsOld"] as? NSArray, details.count > 0 {
                return rowHeight
            } else {
                return 0
            }
            
        // EVA
        case 7:
            if let details = deltaList["detailsNew"] as? NSArray, let _ = (details.count == 8 ? details[7] as? String : nil)  {
                return UITableView.automaticDimension
            } else {
                return 0
            }
            
        default: return rowHeight
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (date, deltaLists) = itemList[indexPath.section]
        let deltaList = deltaLists[(indexPath.row - 1) / 8]

        // Date is first row in section.
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "day")
            cell?.textLabel?.text = date
            return cell!
        }
        
        let logicalRow = (indexPath.row - 1) % 8
        switch(logicalRow) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "spacer")
            return cell!

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "type")
            let type = deltaList["type"] as! String

            switch(type) {
            case "ADDED":
                cell?.textLabel?.text = "Hinzugefügt"
                cell?.textLabel?.textColor = .black
                cell?.backgroundColor = Config.colorGreen
                
            case "DELETED":
                cell?.textLabel?.text = "Entfernt"
                cell?.textLabel?.textColor = .white
                cell?.backgroundColor = Config.colorRed
                
            case "CHANGED":
                cell?.textLabel?.text = "Geändert"
                cell?.textLabel?.textColor = .black
                cell?.backgroundColor = Config.colorYellow
                
            default:
                NSLog("Invalid item change type \(type)")
            }

            return cell!
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "spacer")
            return cell!

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "course")
            var details = deltaList["detailsNew"] as? NSArray
            
            if (details == nil) {
                details = deltaList["detailsOld"] as? NSArray
            }
            
            let course: String! = StringHelper.replaceHtmlEntities(input: details![2] as? String)
            let lesson: String! = details![0] as? String
            
            if (course != "") {
                cell?.textLabel?.text = String(format: "Fach/Kurs: %@, %@. Stunde", course, lesson)
            } else {
                cell?.textLabel?.text! = String(format: "%@. Stunde", lesson)
            }
            
            return cell!

        case 4:
            var cell: UITableViewCell?
            
            if let details = deltaList["detailsNew"] as? NSArray, details.count > 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "details")
                let typeLabel = cell?.viewWithTag(tags.details.type.rawValue) as! UILabel
                typeLabel.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: details[1] as? String))
                
                let roomLabel = cell?.viewWithTag(tags.details.room.rawValue) as! UILabel
                roomLabel.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: details[3] as? String))
                
                let teacherLabel = cell?.viewWithTag(tags.details.teacher.rawValue) as! UILabel
                teacherLabel.attributedText = FormatHelper.teacherText(oldTeacher: details[5] as? String, newTeacher: details[4] as? String)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "spacer")
            }
            
            return cell!

        case 5:
            var cell: UITableViewCell?
            
            if let details = deltaList["detailsOld"] as? NSArray, details.count > 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "detailsOld")
                let typeLabel = cell?.viewWithTag(tagsOld.details.type.rawValue) as! UILabel
                typeLabel.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: details[1] as? String))
                
                let roomLabel = cell?.viewWithTag(tagsOld.details.room.rawValue) as! UILabel
                roomLabel.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: details[3] as? String))
                
                let teacherLabel = cell?.viewWithTag(tagsOld.details.teacher.rawValue) as! UILabel
                teacherLabel.attributedText = FormatHelper.teacherText(oldTeacher: details[5] as? String, newTeacher: details[4] as? String)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "spacer")
            }
            
            return cell!

        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "comment")
            
            if let details = deltaList["detailsNew"] as? NSArray {
                let text = StringHelper.replaceHtmlEntities(input: details[6] as? String)
                cell?.textLabel?.text = text
            }
            
            return cell!
            
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: "eva")
            
            if let details = deltaList["detailsNew"] as? NSArray, let eva = (details.count == 8 ? details[7] as? String : nil) {
                let text = StringHelper.replaceHtmlEntities(input: eva)
                cell?.textLabel?.text = text
                cell?.isHidden = false
            }
            
            return cell!
            
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemList.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let (_, deltaLists) = itemList[section]
        return 8 * deltaLists.count + 1
    }
}
