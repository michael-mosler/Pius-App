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
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var openAppButton: UIButton!
    
    // Text constants
    private struct messages {
        static let notConfigured: String = "Du musst Dich anmelden und eine Kursliste anlegen, um das Widget verwenden zu können.";
        static let error: String = "Die Daten konnten leider nicht geladen werden.";
        static let noNextItem: String = "In den nächsten Tagen hast Du keinen Vertretungsunterricht."
    }

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
            return 6;
        }
    }
    
    private var displayMode: NCWidgetDisplayMode {
        get {
            guard data.count > 0 && data[0].gradeItems.count > 0 else { return .compact; }
            return (data[0].gradeItems[0].vertretungsplanItems[0].count == 8) ? .expanded : .compact;
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
    private var realFixedHeight: CGFloat {
        get {
            return 16 + 2 * 2 + 2;
        }
    }

    // Compute row height to use.
    private var rowHeight: CGFloat {
        return (compactHeight - realFixedHeight) / 4;
    }

    // Navigate to app.
    @IBAction func openAppAction(_ sender: Any) {
        extensionContext?.open(URL(string: "pius-app://dashboard")!);
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func getVertretungsplanFromWeb(forGrade grade: String, withCompeltionHandler completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        // Scoped version of doUpdate(). completionHandler() is injected from outside.
        // This allows to notify widget of load result.
        func doUpdate(with vertretungsplan: Vertretungsplan?, online: Bool) {
            if let vertretungsplan = vertretungsplan {
                self.infoLabel.isHidden = true;
                self.openAppButton.isEnabled = true;
                
                data = vertretungsplan.next;
                if data.count > 0 {
                    DispatchQueue.main.async {
                        self.lastUpdateLabel.text = vertretungsplan.lastUpdate;
                        
                        if !online {
                            self.lastUpdateLabel.backgroundColor = Config.offlineRed;
                            self.lastUpdateLabel.textColor = .white;
                        }

                        self.tableView.reloadData();
                        self.extensionContext?.widgetLargestAvailableDisplayMode = self.displayMode;
                    }
                } else {
                    DispatchQueue.main.async {
                        self.infoLabel.isHidden = false;
                        self.openAppButton.isEnabled = false;
                        self.infoLabel.text = messages.noNextItem;
                        self.extensionContext?.widgetLargestAvailableDisplayMode = .compact;
                        completionHandler(NCUpdateResult.newData);
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.infoLabel.isHidden = false;
                    self.openAppButton.isEnabled = false;
                    self.infoLabel.text = messages.error;
                    self.extensionContext?.widgetLargestAvailableDisplayMode = .compact;
                    completionHandler(NCUpdateResult.newData);
                }
            }
        }
        
        // Load data and perform update of view.
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: grade);
        vertretungsplanLoader.load(doUpdate);
    }

    private func showConfigNotice() {
        infoLabel.isHidden = false;
        openAppButton.isEnabled = false;
        infoLabel.text = messages.notConfigured;
        extensionContext?.widgetLargestAvailableDisplayMode = .compact;
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if (activeDisplayMode == .expanded) {
            // If there is not data fallback to collapsed mode.
            let height = rowHeight * CGFloat(tableRows + 1) + realFixedHeight;
            preferredContentSize = CGSize(width: 0.0, height: height)
        } else {
            let height = rowHeight * 4 + realFixedHeight;
            preferredContentSize = CGSize(width: 0.0, height: height);
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // This dashboard is for this grade setting.
        if AppDefaults.authenticated && (AppDefaults.hasLowerGrade || (AppDefaults.hasUpperGrade && AppDefaults.courseList != nil && AppDefaults.courseList!.count > 0)) {
            if let gradeSetting = AppDefaults.selectedGradeRow, let classSetting = AppDefaults.selectedClassRow {
                let grade = Config.shortGrades[gradeSetting] + Config.shortClasses[classSetting];
                getVertretungsplanFromWeb(forGrade: grade, withCompeltionHandler: completionHandler);
            } else {
                showConfigNotice();
            }
        } else {
            showConfigNotice();
        }
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
            
        case 5:
            return 3 * rowHeight;

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
                cell?.isHidden = false;
            } else {
                cell?.isHidden = true;
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
