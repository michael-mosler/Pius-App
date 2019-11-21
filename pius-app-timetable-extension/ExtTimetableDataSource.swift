//
//  ExtTimetableDataSource.swift
//  pius-app-timetable-extension
//
//  Created by Michael Mosler-Krings on 17.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

class ExtTimetableDataSource: TimetableDataSource<ExtTimetableItemCell> {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard AppDefaults.useTimetable else { return 1 }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard AppDefaults.useTimetable else {
            return MessageCell("Konfiguriere in den Einstellungen Deinen Stundenplan, um das Widget zu verwenden.")
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}

