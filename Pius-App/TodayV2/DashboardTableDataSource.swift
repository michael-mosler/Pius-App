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
    private var _substitutions: Vertretungsplan?
    private let substitutionsLoader: VertretungsplanLoader = VertretungsplanLoader(forGrade: AppDefaults.gradeSetting)
    
    var loadDate: String? {
        return _substitutions?.lastUpdate
    }

    private var data: [DetailItems] {
        get {
            // If there is a schedule at all and if there a substitutions for the configured
            // grade.
            if let substitutions = _substitutions, substitutions.vertretungsplaene.count > 0, substitutions.vertretungsplaene[0].gradeItems.count > 0 {
                return substitutions.vertretungsplaene[0].gradeItems[0].vertretungsplanItems
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

    private func doUpdate(with substitutions: Vertretungsplan?, online: Bool) {
        hadError = substitutions == nil
        if !hadError, var substitutions = substitutions {
            // Date to filter for. Reduce schedules to the one with the given date.
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "de_DE")
            dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, dd.MM.yyyy")
            // let filterDate = dateFormatter.string(from: Date())

            let filterDate = "Mittwoch, 28.08.2019"

            substitutions.vertretungsplaene = substitutions.vertretungsplaene.filter {$0.date == filterDate}
            _substitutions = substitutions
        }
        
        observer?.didLoadData(self)
    }

    func needsShow() -> Bool {
        return canUseDashboard
    }
    
    func willTryLoading() -> Bool {
        return canUseDashboard
    }
    
    func loadData(_ observer: TodayItemContainer) {
        self.observer = observer
        substitutionsLoader.load(doUpdate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "dashboardItemCell") as! DashboardTableViewCell
        cell.items = items
        return cell
    }
}
