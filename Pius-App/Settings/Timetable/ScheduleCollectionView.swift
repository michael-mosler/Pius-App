//
//  ScheduleCollectionView.swift
//
//  Created by Michael Mosler-Krings on 27.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit

/* ****************************************************************
 * This collection view holds a timetable view for each day of
 * week and each week (A/B)
 * ****************************************************************/
class ScheduleCollectionView: UICollectionView, TimetableCollectionViewProtocol {
    var timetableViewDataDelegate: TimetableViewDataDelegate?
    private var currentWeek: Week = Week.A

    override func numberOfItems(inSection section: Int) -> Int {
        return 5
    }
    
    var week: Week {
        get {
            return currentWeek
        }
        set(week) {
            currentWeek = week
            reloadData()
        }
    }

    func cell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "prototypeCell", for: indexPath) as! ScheduleCollectionViewCell
        cell.forWeek = currentWeek
        cell.forDay = indexPath.row
        cell.dropDelegate = cell.timetableTableView
        cell.dataDelegate = timetableViewDataDelegate
        return cell
    }
    
    func dragItem(forIndexPath indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
}
