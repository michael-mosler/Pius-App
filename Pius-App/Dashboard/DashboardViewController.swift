//
//  DashboardViewController.swift
//  Pius-App
//
//  Created by Michael on 28.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DashboardViewController: UITableViewController, UITabBarControllerDelegate, ExpandableHeaderViewDelegate {
    private var vertretungsplan: Vertretungsplan?;
    private var nextDate: String = "";
    private var currentHeader: ExpandableHeaderView?;

    private var data: [VertretungsplanForDate] {
        get {
            if let vertretungsplan_ = vertretungsplan {
                return vertretungsplan_.vertretungsplaene;
            }
            return [];
        }
        
        set(newValue) {
            if (vertretungsplan != nil) {
                vertretungsplan!.vertretungsplaene = newValue;
            }
        }
    }

    private struct ExpandHeaderInfo {
        var header: ExpandableHeaderView
        var section: Int
    }
    private var expandHeaderInfo: ExpandHeaderInfo?;

    // This dashboard is for this grade setting.
    private var grade: String = "";

    // That many rows per unfolded item.
    private let rowsPerItem = 6;
    
    func doUpdate(with vertretungsplan: Vertretungsplan?, online: Bool) {
        if (vertretungsplan == nil) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Vertretungsplan", message: "Die Daten konnten leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert);
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true);
                }));
                self.present(alert, animated: true, completion: nil);
            }
        } else {
            self.vertretungsplan = vertretungsplan;
            
            // What is actually next active substitution schedule date?
            let nextVertretungsplanForDate = vertretungsplan!.next;
            if nextVertretungsplanForDate.count > 0 {
                self.nextDate = nextVertretungsplanForDate[0].date;
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData();
                self.tableView.layoutIfNeeded();
                if let headerInfo = self.expandHeaderInfo {
                    self.toggleSection(header: headerInfo.header, section: headerInfo.section);
                }
            }
        }
    }
    
    private func getVertretungsplanFromWeb(forGrade grade: String) {
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: grade);
        
        // Clear all data.
        currentHeader = nil;
        vertretungsplanLoader.load(self.doUpdate);
    }

    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        getVertretungsplanFromWeb(forGrade: grade);
        sender.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged);
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        // This dashboard is for this grade setting.
        grade = AppDefaults.gradeSetting;
        title = grade;
        
        getVertretungsplanFromWeb(forGrade: grade);
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count + 2;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard (section >= 2) else { return 1; }
        return ((data[section - 2].gradeItems.count == 0)) ? 0 : rowsPerItem * data[section - 2].gradeItems[0].vertretungsplanItems.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section) {
        case 0: return 128;
        case 1: return UITableView.automaticDimension;
        default:
            if (data[indexPath.section - 2].expanded) {
                let gradeItem: GradeItem? = data[indexPath.section - 2].gradeItems[0];
                
                switch indexPath.row % rowsPerItem {
                case 0: return 2;
                case 1: return UITableView.automaticDimension;
                case 2: return UITableView.automaticDimension;
                case 3:
                    let itemIndex: Int = indexPath.row / rowsPerItem;
                    let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6]);
                    return (text == "") ? 0 : 44; // UITableView.automaticDimension;
                case 4:
                    let itemIndex: Int = indexPath.row / rowsPerItem;
                    return ((gradeItem?.vertretungsplanItems[itemIndex].count)! < 8) ? 0: UITableView.automaticDimension;
                default:
                    // Spacer is shown only if there is a EVA text.
                    let itemIndex: Int = indexPath.row / rowsPerItem;
                    return ((gradeItem?.vertretungsplanItems[itemIndex].count)! < 8) ? 0 : 5;
                }
            } else {
                return 0;
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section) {
        case 0: return 0;
        case 1: return 0;
        default: return 44;
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section < 2) ? 0 : 2;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard (section >= 2) else { return UITableViewHeaderFooterView(); }

        let header = ExpandableHeaderView();
        header.customInit(title: data[section - 2].date, userInteractionEnabled: (data[section - 2].gradeItems.count != 0), section: section, delegate: self);
        
        // Expand next substitution date entry.
        if data[section - 2].date == nextDate {
            expandHeaderInfo = ExpandHeaderInfo(header: header, section: section);
         }

        return header;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "metaDataCell") as! MetaDataTableViewCell;
            cell.setContent(tickerText: StringHelper.replaceHtmlEntities(input: vertretungsplan?.tickerText), additionalText: StringHelper.replaceHtmlEntities(input: vertretungsplan?.additionalText))
            return cell;
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "lastUpdateCell")!;
            cell.textLabel?.text = vertretungsplan?.lastUpdate;
            cell.detailTextLabel?.text = "Letzte Aktualisierung";
            return cell;
        default:
            let itemIndex: Int = indexPath.row / rowsPerItem;
            let gradeItem: GradeItem? = data[indexPath.section - 2].gradeItems[0];
            
            switch indexPath.row % rowsPerItem {
            case 0:
                return tableView.dequeueReusableCell(withIdentifier: "spacerTop")!;
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "course")!;
                let grade: String! = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][2]);
                let lesson: String! = (gradeItem?.vertretungsplanItems[itemIndex][0])!
                cell.textLabel?.text = (grade != "") ? String(format: "Fach/Kurs: %@, %@. Stunde", grade, lesson) : String(format: "%@. Stunde", lesson);
                return cell;
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "details") as! VertretungsplanDetailsCell;
                cell.setContent(type: NSAttributedString(string: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][1])), room: getRoomText(room: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][3])), substitution: getTeacherText(oldTeacher: (gradeItem?.vertretungsplanItems[itemIndex][5]), newTeacher: gradeItem?.vertretungsplanItems[itemIndex][4]))
                return cell;
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "comment")!;
                let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6]);
                cell.textLabel?.text = text;
                return cell;
            case 4:
                let cell = tableView.dequeueReusableCell(withIdentifier: "eva")!;
                if (gradeItem?.vertretungsplanItems[itemIndex].count == 8) {
                    let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][7]);
                    cell.textLabel?.text = text;
                }
                return cell;
            default:
                return tableView.dequeueReusableCell(withIdentifier: "spacerBottom")!;
            }
        }
    }

    func getTeacherText(oldTeacher: String?, newTeacher: String?) -> NSAttributedString {
        guard let oldTeacher = oldTeacher, let newTeacher = newTeacher else { return NSMutableAttributedString()  }
        
        let textRange = NSMakeRange(0, oldTeacher.count);
        let attributedText = NSMutableAttributedString(string: oldTeacher + " → " + newTeacher);
        attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: textRange);
        return attributedText;
        
    }
    
    func getRoomText(room: String?) -> NSAttributedString {
        guard let room = room, room != "" else { return NSAttributedString(string: "") }
        
        let attributedText = NSMutableAttributedString(string: room);
        
        let index = room.index(of: "→");
        if (index != nil) {
            let length = room.distance(from: room.startIndex, to: room.index(before: index!));
            let strikeThroughRange = NSMakeRange(0, length);
            attributedText.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: strikeThroughRange);
        }
        
        return attributedText;
    }

    func toggleSection(header: ExpandableHeaderView, section: Int) {
        // If another than the current section is selected hide the current
        // section.
        if (currentHeader != nil && currentHeader != header) {
            let currentSection = currentHeader!.section!;
            data[currentSection - 2].expanded = false;
            
            tableView.beginUpdates();
            for i in 0 ..< data[currentSection - 2].gradeItems[0].vertretungsplanItems.count {
                tableView.reloadRows(at: [IndexPath(row: i, section: currentSection)], with: .automatic)
            }
            tableView.endUpdates();
        }
        
        // Expand/collapse the selected header depending on it's current state.
        currentHeader = header;
        data[section - 2].expanded = !data[section - 2].expanded;
        
        tableView.beginUpdates();
        for i in 0 ..< data[section - 2].gradeItems[0].vertretungsplanItems.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates();
    }
}
