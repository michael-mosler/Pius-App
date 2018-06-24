//
//  TodayViewController.swift
//  Pius-App-Extension
//
//  Created by Michael Mosler-Krings on 21.06.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import NotificationCenter

class PiusAppExtensionViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet var widgetView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var cacheFilename: String?;
    private var gradeSetting: Int?;
    private var classSetting: Int?;
    
    // Height of Widget in compact mode.
    private var compactHeight: CGFloat {
        get {
            return (extensionContext?.widgetMaximumSize(for: .compact).height)!;
        }
    }
    
    // 16 = Label height
    // 2 = Space between 2 labels
    // 2 = Space between rows to show in compact mode.
    private let maxFixedHeight: CGFloat = 2 * 16 + 2 * 2 + 2;

    private var realFixedHeight: CGFloat {
        get {
            return maxFixedHeight; // - 16 when in offline mode.
        }
    }

    // Compute row height to use.
    private var rowHeight: CGFloat {
        return (compactHeight - realFixedHeight) / 2;
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded;
        
        if let userDefaults = UserDefaults(suiteName: "de.rmkrings.piusapp.widget") {
            cacheFilename = userDefaults.string(forKey: "cacheFilename");
            gradeSetting = userDefaults.integer(forKey: "selectedGradeRow");
            classSetting = userDefaults.integer(forKey: "selectedClassRow");
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if activeDisplayMode == .expanded {
            let height = rowHeight * 5 + realFixedHeight;
            preferredContentSize = CGSize(width: 0.0, height: height)
        } else {
            preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6;
        /*
        if (data[section].gradeItems.count == 0) {
            return 0;
        }
        
        return rowsPerItem * data[section].gradeItems[0].vertretungsplanItems.count;
        */
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1: return 2;
        default: return rowHeight;
        }
        /*
        if (data[indexPath.section].expanded) {
            var height : CGFloat;
            let gradeItem: GradeItem? = data[indexPath.section].gradeItems[0];
            
            switch indexPath.row % rowsPerItem {
            case 0:
                height = 2;
            case 1:
                height = 36;
            case 2:
                height = 30;
            case 3:
                let itemIndex: Int = indexPath.row / rowsPerItem;
                let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6]);
                height = (text == "") ? 0 : 30;
            case 4:
                let itemIndex: Int = indexPath.row / rowsPerItem;
                if ((gradeItem?.vertretungsplanItems[itemIndex].count)! < 8) {
                    height = 0;
                } else {
                    height = UITableViewAutomaticDimension;
                }
            default:
                // Spacer is shown only if there is a EVA text.
                let itemIndex: Int = indexPath.row / rowsPerItem;
                if ((gradeItem?.vertretungsplanItems[itemIndex].count)! < 8) {
                    height = 0;
                } else {
                    height = 5;
                }
            }
            
            return height;
        } else {
            return 0;
        }
        */
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?;
        let itemIndex: Int = indexPath.row;
        // let gradeItem: GradeItem? = data[indexPath.section].gradeItems[0];
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "day");
            if let text = AppDefaults.selectedGradeRow {
                cell?.textLabel?.text = String(text);
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "spacer")
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "course")!;
            cell?.textLabel?.text = "Course";
            /*
            let grade: String! = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][2]);
            let lesson: String! = (gradeItem?.vertretungsplanItems[itemIndex][0])!
            
            if (grade != "") {
                cell?.textLabel?.text = String(format: "Fach/Kurs: %@, %@. Stunde", grade, lesson);
            } else {
                cell?.textLabel?.text! = String(format: "%@. Stunde", lesson);
            }
            */
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "details");
            // cell?.textLabel?.text = "Details";
            /*
            if (cell != nil) {
                // This is the itemIndex this cell is know displaying.
                (cell as! DetailsCellTableViewCell).section = indexPath.section;
                (cell as! DetailsCellTableViewCell).itemIndex = itemIndex;
                
                // Reload content for this cell when it had already been used.
                (cell as! DetailsCellTableViewCell).collectionView?.reloadData();
            }
            */
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "comment");
            cell?.textLabel?.text = "Comment";
            /*
            let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6]);
            cell?.textLabel?.text = text;
            */
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "eva");
            cell?.textLabel?.text = "Eva";
            /*
            if (gradeItem?.vertretungsplanItems[itemIndex].count == 8) {
                let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][7]);
                cell?.textLabel?.text = text;
            }
            */
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "spacer");
        }
        
        return cell!;
    }

}
