//
//  DashboardDataSource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 22.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

class DashboardTableDataSource: NSObject, UITableViewDataSource, TodayItemDataSource {
    private var hadError = false
    private var observer: TodayItemContainer?
    private var _filteredSubstitutionSchedule: VertretungsplanForDate?
    var substitutionSchedule: Vertretungsplan?

    var loadDate: String? {
        return substitutionSchedule?.lastUpdate
    }

    private var data: [DetailItems] {
        get {
            // If there is a schedule at all and if there a substitutions for the configured
            // grade.
            if let substitutions = _filteredSubstitutionSchedule, substitutions.gradeItems.count > 0 {
                return substitutions.gradeItems[0].vertretungsplanItems
            }
            return []
        }
    }
    
    private var canUseDashboard: Bool {
        get {
            if AppDefaults.authenticated && (AppDefaults.hasLowerGrade || (AppDefaults.hasUpperGrade && AppDefaults.courseList != nil && AppDefaults.courseList!.count > 0)) {
                if let _ = AppDefaults.selectedGradeRow, let _ = AppDefaults.selectedClassRow {
                    return true
                } else {
                    return false
                }
            } else {
                return false
            }
        }
    }

    private func doUpdate(with schedule: Vertretungsplan?, online: Bool) {
        hadError = schedule == nil
        if !hadError, let schedule = schedule {
            // Full schedule and filtered schedule.
            substitutionSchedule = schedule
            _filteredSubstitutionSchedule = schedule.vertretungsplaene[0] // .filter(onDate: Date())
        }
        
        observer?.didLoadData(self)
    }

    func needsShow() -> Bool {
        return canUseDashboard
    }
    
    func willTryLoading() -> Bool {
        return canUseDashboard
    }
    
    func isEmpty() -> Bool {
        return data.count == 0
    }
    
    func loadData(_ observer: TodayItemContainer) {
        self.observer = observer
        let substitutionsLoader: VertretungsplanLoader = VertretungsplanLoader(forGrade: AppDefaults.gradeSetting)
        substitutionsLoader.load(doUpdate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEmpty() ? 1 : data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !hadError else {
            return MessageCell("Die Daten konnten leider nicht geladen werden.")
        }
        guard !isEmpty() else {
            return MessageCell("Heute hast Du keinen Vertretungsunterricht.")
        }

        let items = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardItemCell") as! DashboardTableViewCell
        cell.items = items
        return cell
    }
}
