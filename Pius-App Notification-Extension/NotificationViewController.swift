//
//  NotificationViewController.swift
//  Pius-App Notification-Extension
//
//  Created by Michael Mosler-Krings on 30.07.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var notificationView: UIView!
    @IBOutlet weak var tablewView: UITableView!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    // Tags used for labels.
    private struct tags {
        enum details: Int {
            case type = 1, room, teacher
        }
    }
    
    private let rowHeight: CGFloat = 44;
    private var data: NSDictionary? = nil;
    private var nChanges: Int = 0;
    
    // Tags used for labels.
    private struct tagsOld {
        enum details: Int {
            case type = 4, room, teacher
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        guard notification.request.content.userInfo["deltaList"] != nil else { return };
        
        let payload = notification.request.content.userInfo["deltaList"] as! NSArray?
        if let payload_ = payload, let deltaList = payload?[0] as! NSDictionary? {
            self.data = deltaList;
            self.nChanges = payload_.count;
            tablewView.reloadData();
            notificationView.layoutIfNeeded();
            preferredContentSize = CGSize(width: view.bounds.size.width, height: tablewView.contentSize.height);
       }
    }
    
    /*
     * TableViewDelegate methods
     */

    // Gets number of rows in section. As we have one section only
    // and we will display one the top most change only this equals
    // the number of rows in table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.data == nil) ? 0 : 10;
    }

    // Return height for cells.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        // Header
        case 0: return 16;
            
        // Spacer
        case 2: return 2;
            
        // Details New
        case 4:
            if let details = data!["detailsNew"] as? NSArray, details.count > 0 {
                return rowHeight
            } else {
                return 0;
            }

        // Details Old
        case 5:
            if let details = data!["detailsOld"] as? NSArray, details.count > 0 {
                return rowHeight
            } else {
                return 0;
            }

        // EVA
        case 7:
            if let details = data!["detailsNew"] as? NSArray, let _ = (details.count == 8 ? details[7] as? String : nil)  {
                return UITableView.automaticDimension;
            } else {
                return 0;
            }
            
        // Spacer2
        case 8: return 2;
        
        // Number of further changes
        case 9: return 16;
            
       default:
            return rowHeight;
        }
    }
    
    // Return cell for row at a given index path.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?;
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "type");
            if let type = data!["type"] as? String {
                switch(type) {
                case "ADDED":
                    cell?.textLabel?.text = "Hinzugefügt";
                    cell?.textLabel?.textColor = .black;
                    cell?.backgroundColor = Config.colorGreen;

                case "DELETED":
                    cell?.textLabel?.text = "Entfällt";
                    cell?.textLabel?.textColor = .white;
                    cell?.backgroundColor = Config.colorRed;

                case "CHANGED":
                    cell?.textLabel?.text = "Geändert";
                    cell?.textLabel?.textColor = .black;
                    cell?.backgroundColor = Config.colorYellow;

                default:
                    NSLog("Invalid item change type \(type)");
                }
            }
            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "day");
            cell?.textLabel?.text = data!["date"] as? String;
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "spacer");
            
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "course")!;
            var details = data!["detailsNew"] as? NSArray;
            
            if (details == nil) {
                details = data!["detailsOld"] as? NSArray;
            }
            
            let course: String! = StringHelper.replaceHtmlEntities(input: details![2] as? String);
            let lesson: String! = details![0] as? String;
            
            if (course != "") {
                cell?.textLabel?.text = String(format: "Fach/Kurs: %@, %@. Stunde", course, lesson);
            } else {
                cell?.textLabel?.text! = String(format: "%@. Stunde", lesson);
            }
            
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "details");
            
            if let details = data!["detailsNew"] as? NSArray, details.count > 0 {
                let typeLabel = cell?.viewWithTag(tags.details.type.rawValue) as! UILabel;
                typeLabel.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: details[1] as? String));
                
                let roomLabel = cell?.viewWithTag(tags.details.room.rawValue) as! UILabel;
                roomLabel.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: details[3] as? String));
                
                let teacherLabel = cell?.viewWithTag(tags.details.teacher.rawValue) as! UILabel;
                teacherLabel.attributedText = FormatHelper.teacherText(oldTeacher: details[5] as? String, newTeacher: details[4] as? String);
            }
            
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "detailsOld");
            
            if let details = data!["detailsOld"] as? NSArray, details.count > 0 {
                let typeLabel = cell?.viewWithTag(tagsOld.details.type.rawValue) as! UILabel;
                typeLabel.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: details[1] as? String));
                
                let roomLabel = cell?.viewWithTag(tagsOld.details.room.rawValue) as! UILabel;
                roomLabel.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: details[3] as? String));
                
                let teacherLabel = cell?.viewWithTag(tagsOld.details.teacher.rawValue) as! UILabel;
                teacherLabel.attributedText = FormatHelper.teacherText(oldTeacher: details[5] as? String, newTeacher: details[4] as? String);
            }

        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "comment");
            
            if let details = data!["detailsNew"] as? NSArray {
                let text = StringHelper.replaceHtmlEntities(input: details[6] as? String);
                cell?.textLabel?.text = text;
            }
            
        case 7:
            cell = tableView.dequeueReusableCell(withIdentifier: "eva");
 
            if let details = data!["detailsNew"] as? NSArray, let eva = (details.count == 8 ? details[7] as? String : nil) {
                let text = StringHelper.replaceHtmlEntities(input: eva);
                cell?.textLabel?.text = text;
                cell?.isHidden = false;
            }
            
        case 8:
            cell = tableView.dequeueReusableCell(withIdentifier: "spacer2");
            
        case 9:
            cell = tableView.dequeueReusableCell(withIdentifier: "#changes");
            cell?.textLabel?.text = (self.nChanges == 1) ? "Keine weiteren Änderungen" : "\(self.nChanges - 1) weitere Änderung\((self.nChanges - 1 == 1) ? "" : "en")";
            
       default:
            cell = tableView.dequeueReusableCell(withIdentifier: "spacer");
        }
        
        return cell!;
    }
}
