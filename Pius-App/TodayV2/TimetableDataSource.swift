//
//  TimetableDatasource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 25.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

// This data source simply defines 5 cells for the timetable collection view. The collection
// view cells are a container for 5 table views which themselves hold timetable for
// each day.
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

// This class is the data source for timetable table view. loadData() refreshes timetable data
// from config settings. This function is not asynchronous.
// When timetable is to be shown forDay and forWeek needs to be set to appropriate values, aka
// day and week to be shown. Week is one of .A or .B. Days are counted starting from Monday with
// 0 being the least index.
class TimetableDataSource: NSObject, UITableViewDataSource, TodayItemDataSource {
    private var timetable: Timetable = AppDefaults.timetable
    var forWeek: Week?
    var forDay: Int?
    
    let collectionViewDataSource: UICollectionViewDataSource = TimetableCollectionViewDataSource()
    
    func needsShow() -> Bool {
        return true
    }
    
    func willTryLoading() -> Bool {
        return true
    }
    
    // Refresh timetable.
    func loadData(_ observer: TodayItemContainer) {
        timetable  = AppDefaults.timetable
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timetable.schedule(forWeek: .A, forDay: 0).numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timetableItemCell") as! TodayTimetableItemCell
        cell.lesson = indexPath.row

        if let forWeek = forWeek, let forDay = forDay {
            cell.scheduleItem = timetable.schedule(forWeek: forWeek, forDay: forDay).item(forLesson: indexPath.row)
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
