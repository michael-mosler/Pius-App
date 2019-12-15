//
//  DashboardDataSource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

protocol DashboardItemCellProtocol {
    var items: DetailItems? { get set }
}

class DashboardDataSource<T: DashboardItemCellProtocol>: NSObject, UITableViewDataSource {

    private var _hadError = false
    private var observer: ItemContainerProtocol?
    private var _filteredSubstitutionSchedule: VertretungsplanForDate?
    var substitutionSchedule: Vertretungsplan?

    var hadError: Bool { _hadError }
    var loadDate: String? { substitutionSchedule?.lastUpdate }

    var data: [DetailItems] {
        get {
            // If there is a schedule at all and if there a substitutions for the configured
            // grade.
            if let substitutions = _filteredSubstitutionSchedule, substitutions.gradeItems.count > 0 {
                return substitutions.gradeItems[0].vertretungsplanItems
            }
            return []
        }
    }
    
    var canUseDashboard: Bool {
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
        _hadError = schedule == nil
        if !_hadError, let schedule = schedule {
            // Full schedule and filtered schedule.
            substitutionSchedule = schedule
            _filteredSubstitutionSchedule = schedule.filter(onDate: Date()) // .vertretungsplaene[0] // Debug: First day of subst. schedule.
        }
        
        observer?.didLoadData(self)
    }

    func loadData(_ observer: ItemContainerProtocol) {
        self.observer = observer
        let substitutionsLoader: VertretungsplanLoader = VertretungsplanLoader(forGrade: AppDefaults.gradeSetting)
        substitutionsLoader.load(doUpdate)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard data.count > 0 else { return 1 }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = data[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: "dashboardItemCell") as! T
        cell.items = items
        return cell as! UITableViewCell
    }
    
}
