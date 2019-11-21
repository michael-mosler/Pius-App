//
//  DashboardDataSource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 22.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

class TodayDashboardDataSource<T: DashboardItemCellProtocol>: DashboardDataSource<T>, TodayItemDataSourceProtocol {
    
    func needsShow() -> Bool {
        return canUseDashboard
    }
    
    func willTryLoading() -> Bool {
        return canUseDashboard
    }
    
    func isEmpty() -> Bool {
        return data.count == 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !hadError else {
            return MessageCell("Die Daten konnten leider nicht geladen werden.")
        }
        guard !isEmpty() else {
            return MessageCell("Heute hast Du keinen Vertretungsunterricht.")
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}
