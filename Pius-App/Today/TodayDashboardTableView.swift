//
//  DashboardTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 02.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayDashboardTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    private var parentTableView: UITableView?;
    private var vertretungsplan: Vertretungsplan?;
    private var nextDate: String = "";
    private let rowsPerItem = 4;

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
    
    private var canUseDashboard: Bool {
        get {
            if AppDefaults.authenticated && (AppDefaults.hasLowerGrade || (AppDefaults.hasUpperGrade && AppDefaults.courseList != nil && AppDefaults.courseList!.count > 0)) {
                if let _ = AppDefaults.selectedGradeRow, let _ = AppDefaults.selectedClassRow {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }
    
    private func doUpdate(with vertretungsplan: Vertretungsplan?, online: Bool) {
        if (vertretungsplan != nil) {
            self.vertretungsplan = vertretungsplan;
            
            // What is actually next active substitution schedule date?
            let nextVertretungsplanForDate = vertretungsplan!.next;
            if nextVertretungsplanForDate.count > 0 {
                self.nextDate = nextVertretungsplanForDate[0].date;
            }
            
            DispatchQueue.main.async {
                self.parentTableView?.beginUpdates();
                self.reloadData();
                self.layoutIfNeeded();
                self.parentTableView?.endUpdates();
            }
        }
    }

    func loadData(sender: UITableView) {
        parentTableView = sender;
        delegate = self;
        dataSource = self;

        if canUseDashboard {
            let grade = AppDefaults.gradeSetting;
            let vertretungsplanLoader = VertretungsplanLoader(forGrade: grade);
            vertretungsplanLoader.load(doUpdate);
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return (data.count == 0) ? 0 : 2;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section > 0 else { return (data.count == 0) ? 0 : 1; }
        return ((data[section - 1].gradeItems.count == 0)) ? 0 : rowsPerItem * data[section - 1].gradeItems[0].vertretungsplanItems.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.section) {
        case 0: return UITableView.automaticDimension;
        default:
            switch(indexPath.row % rowsPerItem) {
            case 0: return UITableView.automaticDimension;
            case 1: return UITableView.automaticDimension;
            case 2: return UITableView.automaticDimension;
            case 3:
                let gradeItem: GradeItem? = data[indexPath.section - 1].gradeItems[0];
                let itemIndex: Int = indexPath.row / rowsPerItem;
                return ((gradeItem?.vertretungsplanItems[itemIndex].count)! < 8) ? 0: UITableView.automaticDimension;
            default: return 0;
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = dequeueReusableCell(withIdentifier: "lastUpdateCell")!;
            cell.textLabel?.text = vertretungsplan?.lastUpdate;
            cell.detailTextLabel?.text = "Letzte Aktualisierung";
            return cell;
        default:
            let itemIndex: Int = indexPath.row / rowsPerItem;
            let gradeItem: GradeItem? = data[indexPath.section - 1].gradeItems[0];

            switch(indexPath.row % rowsPerItem) {
            case 0:
                let cell = dequeueReusableCell(withIdentifier: "course")!;
                let grade: String! = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][2]);
                let lesson: String! = (gradeItem?.vertretungsplanItems[itemIndex][0])!
                cell.textLabel?.text = (grade != "") ? String(format: "Fach/Kurs: %@, %@. Stunde", grade, lesson) : String(format: "%@. Stunde", lesson);
                return cell;
            case 1:
                let cell = dequeueReusableCell(withIdentifier: "details") as! TodayDashboardDetailsCell;
                cell.setContent(type: NSAttributedString(string: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][1])), room: getRoomText(room: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][3])), substitution: getTeacherText(oldTeacher: (gradeItem?.vertretungsplanItems[itemIndex][5]), newTeacher: gradeItem?.vertretungsplanItems[itemIndex][4]))
                return cell;
            case 2:
                let cell = dequeueReusableCell(withIdentifier: "comment")!;
                let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6]);
                cell.textLabel?.text = text;
                return cell;
            case 3:
                let cell = dequeueReusableCell(withIdentifier: "eva")!;
                if (gradeItem?.vertretungsplanItems[itemIndex].count == 8) {
                    let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][7]);
                    cell.textLabel?.text = text;
                }
                return cell;
            default:
                return UITableViewCell();
            }
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
