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
class TodayTimetableDataSource<T: TimetableItemCellProtocol>: TimetableDataSource<T>, /* NSObject, UITableViewDataSource, */ TodayItemDataSourceProtocol {
   
    let collectionViewDataSource: UICollectionViewDataSource = TimetableCollectionViewDataSource()
    
    // Retutns true if timetable shall be shown in today view of App.
    func needsShow() -> Bool {
        return AppDefaults.useTimetable
    }
    
    // Return true if data source will try loading data.
    func willTryLoading() -> Bool {
        return AppDefaults.useTimetable
    }
    
    // Retutns true if data source does not contain data.
    func isEmpty() -> Bool {
        if let forWeek = forWeek, let forDay = forDay {
            return timetable.schedule(forWeek: forWeek, forDay: forDay).numberOfItems == 0
        } else {
            return true
        }
    }
    
    /*
    // Refresh timetable.
    func loadData(_ observer: TodayItemContainer) {
        timetable  = AppDefaults.timetable
        observer.didLoadData(self)
    }
    */
    
}
