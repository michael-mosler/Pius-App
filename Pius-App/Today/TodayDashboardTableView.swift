//
//  DashboardTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 02.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayDashboardTableView: UITableView, UITableViewDelegate, UITableViewDataSource, TodaySubTableViewDelegate {
    private var hadError = false;
    private var parentTableView: UITableView?;
    private var vertretungsplan: Vertretungsplan?;

    private var data: [VertretungsplanForDate] {
        get {
            // If there is a schedule at all and if there a substitutions for the configured
            // grade.
            if let vertretungsplan_ = vertretungsplan, vertretungsplan_.vertretungsplaene.count > 0, vertretungsplan_.vertretungsplaene[0].gradeItems.count > 0 {
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
    
    /*
     * ====================================================
     *                  Data Loader
     * ====================================================
     */
    
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
    
    func needsShow() -> Bool {
        return canUseDashboard;
    }

    private func doUpdate(with vertretungsplan: Vertretungsplan?, online: Bool) {
        hadError = vertretungsplan == nil;
        if !hadError, var vertretungsplan_ = vertretungsplan {
            // Date to filter for. Reduce schedules to the one with the given date.
            let dateFormatter = DateFormatter();
            
            dateFormatter.locale = Locale(identifier: "de-DE");
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, dd.MM.yyyy");
            let filterDate = dateFormatter.string(from: Date());
            vertretungsplan_.vertretungsplaene = vertretungsplan_.vertretungsplaene.filter {$0.date == filterDate};
            self.vertretungsplan = vertretungsplan_;
        }
            
        DispatchQueue.main.async {
            self.parentTableView?.beginUpdates();
            self.reloadData();
            self.layoutIfNeeded();
            self.parentTableView?.endUpdates();
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

    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard canUseDashboard && !hadError else { return 0; }
        return (data.count == 0) ? 1 : data[0].gradeItems[0].vertretungsplanItems.count + 1;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard canUseDashboard && !hadError else { return 0; }
        guard section > 0 else { return data.count > 0 || hadError ? 1 : 2; }
        
        var numberOfRows = 4;
        
        if (StringHelper.replaceHtmlEntities(input: data[0].gradeItems[0].vertretungsplanItems[section - 1][6]) == "") {
            numberOfRows -= 1;
        }

        if data[0].gradeItems[0].vertretungsplanItems[section - 1].count < 8 {
            numberOfRows -= 1;
        }

        return numberOfRows;
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            switch(indexPath.row) {
            case 0:
                if hadError {
                    let cell = dequeueReusableCell(withIdentifier: "loadError")!;
                    return cell;
                } else {
                    let cell = dequeueReusableCell(withIdentifier: "lastUpdateCell")!;
                    cell.textLabel?.text = vertretungsplan?.lastUpdate;
                    cell.detailTextLabel?.text = "Letzte Aktualisierung";
                    return cell;
                }
            case 1:
                let cell = dequeueReusableCell(withIdentifier: "noSubstitutions")!;
                return cell;
            default:
                return UITableViewCell();
            }
        default:
            let items: DetailItems = data[0].gradeItems[0].vertretungsplanItems[indexPath.section - 1];

            switch(indexPath.row) {
            case 0:
                let cell = dequeueReusableCell(withIdentifier: "course")!;
                let grade: String! = StringHelper.replaceHtmlEntities(input: items[2]);
                let lesson: String! = items[0];
                cell.textLabel?.text = (grade != "") ? String(format: "Fach/Kurs: %@, %@. Stunde", grade, lesson) : String(format: "%@. Stunde", lesson);
                return cell;
            case 1:
                let cell = dequeueReusableCell(withIdentifier: "details") as! TodayDashboardDetailsCell;
                cell.setContent(type: NSAttributedString(string: StringHelper.replaceHtmlEntities(input: items[1])), room: FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: items[3])), substitution: FormatHelper.teacherText(oldTeacher: (items[5]), newTeacher: items[4]))
                return cell;
            case 2:
                if StringHelper.replaceHtmlEntities(input: data[0].gradeItems[0].vertretungsplanItems[indexPath.section - 1][6]) != "" {
                    let cell = dequeueReusableCell(withIdentifier: "comment")!;
                    let text = StringHelper.replaceHtmlEntities(input: items[6]);
                    cell.textLabel?.text = text;
                    return cell;
                }
                
                if data[0].gradeItems[0].vertretungsplanItems[indexPath.section - 1].count >= 8 {
                    let cell = dequeueReusableCell(withIdentifier: "eva")!;
                    let text = StringHelper.replaceHtmlEntities(input: items[7]);
                    cell.textLabel?.text = text;
                    return cell;
                }

                return UITableViewCell();
            case 3:
                let cell = dequeueReusableCell(withIdentifier: "eva")!;
                let text = StringHelper.replaceHtmlEntities(input: items[7]);
                cell.textLabel?.text = text;
                cell.backgroundView?.clipsToBounds = true;
                return cell;
            default:
                return UITableViewCell();
            }
        }
    }
}
