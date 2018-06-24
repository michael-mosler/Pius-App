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
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var offlineLabel: UILabel!
    @IBOutlet weak var offlineLabelBottomConstraint: NSLayoutConstraint!
    
    private struct tags {
        enum details: Int {
            case type = 1, room, teacher
        }
    }
    
    private var isNetworkReachable: Bool {
        get {
            let piusGatewayReachability = ReachabilityChecker(forName: AppDefaults.baseUrl);
            return piusGatewayReachability.isNetworkReachable();
        }
    }

    // Filtered VertretungsplanData.
    private var data: [VertretungsplanForDate] = [];
    
    // Number table of rows depends on presence of Eva element. When Eva is not
    // present we have 5 rows otherwie we have 6.
    private var tableRows: Int {
        get {
            guard data.count > 0 else { return 0; }
            
            let gradeItem: GradeItem? = data[0].gradeItems[0];
            if ((gradeItem?.vertretungsplanItems[0].count)! < 8) {
                return 5;
            } else {
                return 6;
            }
        }
    }

    // Height of Widget in compact mode.
    private var compactHeight: CGFloat {
        get {
            return (extensionContext?.widgetMaximumSize(for: .compact).height)!;
        }
    }
    
    // 16 = Label height
    // 2 = Space between 2 labels
    // 2 = Space between rows to show in compact mode.
    private var maxFixedHeight: CGFloat {
        get {
            return ((offlineLabel.isHidden) ? 1 : 2) * 16 + 2 * 2 + 2;
        }
    }

    private var realFixedHeight: CGFloat {
        get {
            return maxFixedHeight; // - 16 when in offline mode.
        }
    }

    // Compute row height to use.
    private var rowHeight: CGFloat {
        return (compactHeight - realFixedHeight) / 2;
    }

    // Scroll offline label into view when offline mode is detected after in
    // viewDidLoad().
    private func hideOfflineLabelWhenNeeded() {
        guard isNetworkReachable else { return };
        offlineLabelBottomConstraint.constant = -18;
        offlineLabel.isHidden = true;
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded();
        });
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded;
        
        hideOfflineLabelWhenNeeded();

        // This dashboard is for this grade setting.
        if let gradeSetting = AppDefaults.selectedGradeRow, let classSetting = AppDefaults.selectedClassRow {
            let grade = Config.shortGrades[gradeSetting] + Config.shortClasses[classSetting];
            getVertretungsplanFromWeb(forGrade: grade);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func getVertretungsplanFromWeb(forGrade grade: String) {
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: grade);
        vertretungsplanLoader.load(doUpdate);
    }

    func doUpdate(with vertretungsplan: Vertretungsplan?, online: Bool) {
        if let vertretungsplan = vertretungsplan {
            data = vertretungsplan.vertretungsplaene;
            DispatchQueue.main.async {
                self.lastUpdateLabel.text = vertretungsplan.lastUpdate;
                self.tableView.reloadData();
            }
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if activeDisplayMode == .expanded {
            let height = rowHeight * CGFloat(tableRows - 1) + realFixedHeight;
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
        guard data.count > 0 else { return 0; }
        return tableRows;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return 2;

         default:
            return rowHeight;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?;
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "day");
            cell?.textLabel?.text = data[0].date;
            
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "spacer")
            
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "course")!;
            let gradeItem: GradeItem? = data[0].gradeItems[0];

            let grade: String! = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[0][2]);
            let lesson: String! = (gradeItem?.vertretungsplanItems[0][0])!
            
            if (grade != "") {
                cell?.textLabel?.text = String(format: "Fach/Kurs: %@, %@. Stunde", grade, lesson);
            } else {
                cell?.textLabel?.text! = String(format: "%@. Stunde", lesson);
            }
            
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "details");
            let gradeItem: GradeItem? = data[0].gradeItems[0];
            
            let typeLabel = cell?.viewWithTag(tags.details.type.rawValue) as! UILabel;
            typeLabel.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[0][1]));
            
            let roomLabel = cell?.viewWithTag(tags.details.room.rawValue) as! UILabel;
            roomLabel.attributedText = getRoomText(room: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[0][3]));

            let teacherLabel = cell?.viewWithTag(tags.details.teacher.rawValue) as! UILabel;
            teacherLabel.attributedText = getTeacherText(oldTeacher: (gradeItem?.vertretungsplanItems[0][5]), newTeacher: gradeItem?.vertretungsplanItems[0][4])

        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "comment");
            let gradeItem: GradeItem? = data[0].gradeItems[0];
            let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[0][6]);
            cell?.textLabel?.text = text;
            
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "eva");
            let gradeItem: GradeItem? = data[0].gradeItems[0];
            if (gradeItem?.vertretungsplanItems[0].count == 8) {
                let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[0][7]);
                cell?.textLabel?.text = text;
            }
            
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "spacer");
        }
        
        return cell!;
    }
    
    func getTeacherText(oldTeacher: String?, newTeacher: String?) -> NSAttributedString {
        guard let oldTeacher = oldTeacher, let newTeacher = newTeacher else { return NSMutableAttributedString()  }
        
        let textRange = NSMakeRange(0, oldTeacher.count);
        let attributedText = NSMutableAttributedString(string: oldTeacher + " → " + newTeacher);
        attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: textRange);
        return attributedText;
        
    }
    
    func getRoomText(room: String?) -> NSAttributedString {
        guard let room = room, room != "" else { return NSAttributedString(string: "") }
        
        let attributedText = NSMutableAttributedString(string: room);
        
        let index = room.index(of: "→");
        if (index != nil) {
            let length = room.distance(from: room.startIndex, to: room.index(before: index!));
            let strikeThroughRange = NSMakeRange(0, length);
            attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: strikeThroughRange);
        }
        
        return attributedText;
    }
}
