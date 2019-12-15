//
//  ExtTimetableDataSource.swift
//  pius-app-timetable-extension
//
//  Created by Michael Mosler-Krings on 17.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter

/**
 * This class implements data source for timetable iOS Today view. Basically it only
 * needs to overwrite UITableViewDataSource methods.
 */
class ExtTimetableDataSource: TimetableDataSource<ExtTimetableItemCell> {
    private var displayMode: NCWidgetDisplayMode = .compact
    private var topRow: Int = 0
    
    func mode(useDisplayMode mode: NCWidgetDisplayMode, withTopRow row: Int = 0) {
        displayMode = mode;
        topRow = row
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard AppDefaults.useTimetable else { return 1 }
        return (displayMode == .compact) ? 3 : super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard AppDefaults.useTimetable else {
            return MessageCell("Konfiguriere in den Einstellungen Deinen Stundenplan, um das Widget zu verwenden.")
        }
        
        let indexPath = IndexPath(row: indexPath.row + topRow, section: indexPath.section)
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}

