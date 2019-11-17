//
//  TimetableDataSource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Basic timetable data source class. It uses a protocol to identify
 * the real timetable item cell type. Anyway, in table view such cells
 * must use dequeue identifier "timetableItemCell".
 */
protocol TimetableItemCellProtocol {
    var lesson: Int? { get set }
    var scheduleItem: ScheduleItem? { get set }
}

class TimetableDataSource<T: TimetableItemCellProtocol>: NSObject, UITableViewDataSource {

    var timetable: Timetable = AppDefaults.timetable
    private var _substitutionSchedule: Vertretungsplan?
    private var _filteredSubstitutionSchedule: VertretungsplanForDate? // This schedule is for a particular grade, too.
    private var _forWeek: Week?
    private var _forDay: Int?
    
    // Inject new substitution schedule into timetable.
    var substitutionSchedule: Vertretungsplan? {
        set(value) {
            _substitutionSchedule = value
        }
        get {
            return _substitutionSchedule
        }
    }
    
    // Filtered substitution schedule for the date currently set.
    var filteredSubstitutionSchedule: VertretungsplanForDate? { _filteredSubstitutionSchedule }
    
    // Which week (A/B) is the timetable requested for. Setting this property causes
    // filtered schedule to be updated.
    var forWeek: Week? {
        set(value) {
            _forWeek = value
            _filteredSubstitutionSchedule = substitutionSchedule?.filter(onDate: forDate) // DEBUG .vertretungsplaene[1] //
        }
        get {
            return _forWeek
        }
    }

    // Which das of week is the timetable requested for. Setting this property causes
    // filtered schedule to be updated.
    var forDay: Int? {
        set(value) {
            _forDay = value
            _filteredSubstitutionSchedule = substitutionSchedule?.filter(onDate: forDate) // DEBUG vertretungsplaene[1] // .
        }
        get {
            return _forDay
        }
    }
    
    // Returns the date that is shown in timetable for the current settings
    // of day and week.
    private var forDate: Date? {
        guard let _ = forWeek, let forDay = forDay else { return nil }

        let dayOfWeek = DateHelper.dayOfWeek()
        let currentDate = Date()

        if dayOfWeek > 4 {
            return forWeek != DateHelper.week()
                ? currentDate + ((7 - dayOfWeek) + forDay).days     // On weekends we expect the next week to show.
                : currentDate + ((7 - dayOfWeek) + forDay + 7).days // If users toggles week we shift be another 7 days.
            
        } else {
            // If the week shown is the current week than date is by adding
            // difference for day shown and current day of week to the current
            // date.
            // Weeks will differ for weekend only. In this case we need to
            // move to next Monday and then we add the day shown.
            return forWeek == DateHelper.week()
                ? currentDate + (forDay - dayOfWeek).days
                : currentDate + (forDay - dayOfWeek + 7).days
        }
    }

    // For all timetable views this function checks if dashboard can be used. In this case
    // timetable is able to mix substitution schedule into timetable before displaying a
    // particular row.
    var canUseDashboard: Bool {
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

    // Refresh timetable.
     func loadData(_ observer: ItemContainerProtocol) {
         timetable  = AppDefaults.timetable
         observer.didLoadData(self)
     }

    /*
     * ================================================================================
     *                          Data source delegates.
     * ================================================================================
     */
    
    // If week and day of week have been set this function
    // will return the number of items in schedule for the resulting date.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let forWeek = forWeek, let forDay = forDay {
            return timetable.schedule(forWeek: forWeek, forDay: forDay).numberOfItems
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "timetableItemCell") as! T
        cell.lesson = indexPath.row

        // Get timetable for lesson and if substitution exists mix in this.
        // Schedule item contains all information needed for display and
        // navigation.
        if canUseDashboard, let forWeek = forWeek, let forDay = forDay {
            cell.scheduleItem = timetable.schedule(forWeek: forWeek, forDay: forDay).item(forLesson: indexPath.row)

            // If there is a substitution for this lesson than update schedule item with
            // given details.
            if let gradeItem = filteredSubstitutionSchedule?.item(forIndex: 0), let lesson = cell.lesson {
                let details = gradeItem.details(forLesson: lesson)
                cell.scheduleItem = cell.scheduleItem?.update(withDetails: details)
            }
        } else {
            cell.scheduleItem = timetable.schedule(forWeek: .A, forDay: 0).item(forLesson: indexPath.row)
        }
        
        return cell as! UITableViewCell
    }

}
