//
//  scheduleForDayDataSource.swift
//
//  Created by Michael Mosler-Krings on 27.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit

/* ****************************************************************
 * This collection view cell holds the timetable for a certain
 * week (A/B) and day. It adds proxy attributes that transport
 * this information to the underlying table view that holds the
 * actual timetable for week and day.
 * ****************************************************************/
class ScheduleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var timetableTableView: TimetableTableView!
    
    var forWeek: Week {
        get {
            return timetableTableView.forWeek
        }
        set(week) {
            timetableTableView.forWeek = week
            timetableTableView.reloadData()
        }
    }
    
    var forDay: Int {
        get {
            return timetableTableView.forDay
        }
        set(day) {
            timetableTableView.forDay = day
            timetableTableView.reloadData()
        }
    }
    
    var dropDelegate: UITableViewDropDelegate? {
        get {
            return timetableTableView.dropDelegate
        }
        set(dropDelegate) {
            timetableTableView.dropDelegate = dropDelegate
        }
    }
    
    var dataDelegate: TimetableViewDataDelegate? {
        get {
            return timetableTableView.dataDelegate
        }
        set(dataDelegate) {
            timetableTableView.dataDelegate = dataDelegate
        }
    }
}
