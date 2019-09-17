//
//  TimetableDatasource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 25.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

/* **********************************************************************************************
 * This data source simply defines 5 cells for the timetable collection view. The collection
 * view cells are a container for 5 table views which themselves hold timetable for
 * each day.
 * **********************************************************************************************/
fileprivate class TimetableCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    private let timetable: Timetable = AppDefaults.timetable
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "timetableCollectionCell", for: indexPath) as! TodayTimetableCollectionViewCell
        cell.forDay = indexPath.row
        cell.reload()
        return cell
    }
}

/* **********************************************************************************************
 * This class is the data source for timetable table view. loadData() refreshes timetable data
 * from config settings. This function is not asynchronous.
 * When timetable is to be shown forDay and forWeek needs to be set to appropriate values, aka
 * day and week to be shown. Week is one of .A or .B. Days are counted starting from Monday with
 * 0 being the least index.
 * **********************************************************************************************/
class TimetableDataSource: NSObject, UITableViewDataSource, TodayItemDataSource {
    private var timetable: Timetable = AppDefaults.timetable
    private var substitutionSchedule: VertretungsplanForDate? // This schedule is for a particular grade, too.
    private var _forWeek: Week?
    private var _forDay: Int?
    
    var forWeek: Week? {
        set(value) {
            _forWeek = value
            let dashboardViewDataSource: DashboardTableDataSource = TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! DashboardTableDataSource
            substitutionSchedule = dashboardViewDataSource.substitutionSchedule?.filter(onDate: forDate)            
        }
        get {
            return _forWeek
        }
    }
    var forDay: Int? {
        set(value) {
            _forDay = value
            let dashboardViewDataSource: DashboardTableDataSource = TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! DashboardTableDataSource
            substitutionSchedule = dashboardViewDataSource.substitutionSchedule?.filter(onDate: forDate)
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

        // If the week shown is the current week than date is by adding
        // difference for day shown and current day of week to the current
        // date.
        // Weeks will differ for weekend only. In this case we need to
        // move to next Monday and then we add the day shown.
        if forWeek == DateHelper.week() {
            return currentDate + (forDay - dayOfWeek).days
        }

        return currentDate + ((7 - dayOfWeek) + forDay).days
    }
    
    let collectionViewDataSource: UICollectionViewDataSource = TimetableCollectionViewDataSource()
    
    func needsShow() -> Bool {
        return true
    }
    
    func willTryLoading() -> Bool {
        return true
    }
    
    func isEmpty() -> Bool {
        if let forWeek = forWeek, let forDay = forDay {
            return timetable.schedule(forWeek: forWeek, forDay: forDay).numberOfItems == 0
        } else {
            return true
        }
    }
    
   // Refresh timetable.
    func loadData(_ observer: TodayItemContainer) {
        timetable  = AppDefaults.timetable
        observer.didLoadData(self)
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isEmpty() ? 0 : timetable.schedule(forWeek: forWeek!, forDay: forDay!).numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timetableItemCell") as! TodayTimetableItemCell
        cell.lesson = indexPath.row

        // Get timetable for lesson and if substitution exists mix in this.
        // Schedule item contains all information needed for display and
        // navigation.
        if let forWeek = forWeek, let forDay = forDay {
            cell.scheduleItem = timetable.schedule(forWeek: forWeek, forDay: forDay).item(forLesson: indexPath.row)
            
            // If there is a substituion for this lesson than update schedule item with
            // given details.
            if let gradeItem = substitutionSchedule?.item(forIndex: 0) {
                let details = gradeItem.details(forLesson: indexPath.row)
                cell.scheduleItem = cell.scheduleItem?.update(withDetails: details)
            }
        } else {
            cell.scheduleItem = timetable.schedule(forWeek: .A, forDay: 0).item(forLesson: indexPath.row)
        }
        
        /*
        if indexPath.row <= 1 {
            cell.backgroundColor = UIColor(red: 0.914, green: 0.200, blue: 0.184, alpha: 0.5)
            cell.alpha = 0.25
        }
        */
        
        return cell
    }
}
