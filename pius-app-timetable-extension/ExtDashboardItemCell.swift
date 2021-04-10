//
//  ExtDashboardItemCell.swift
//  pius-app-timetable-extension
//
//  Created by Michael Mosler-Krings on 20.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation

/**
 * This class allows us to make use of DashboardDataSource. In our case
 * we only want to make use of the loader with it's callback infrastructure
 * but we do not want to provide data for a UITableView, thus, we do not
 * implement our own child class but go with the default implementation.
 */
class ExtDashboardItemCell: DashboardItemCellProtocol {
    var items: DetailItem?
}
