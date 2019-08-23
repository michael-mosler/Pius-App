//
//  NewsCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayItemCell: UITableViewCell {
    func layoutIfNeeded(forFrameView view: UIView) {
        super.layoutIfNeeded()
        view.layer.borderColor = Config.colorPiusBlue.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false;
    }
}

class NewsCell: TodayItemCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tableView: NewsTableView!
    
    override func layoutIfNeeded() {
        layoutIfNeeded(forFrameView: view)
    }
}

class CalendarCell: TodayItemCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tableView: CalendarTableView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func layoutIfNeeded() {
        layoutIfNeeded(forFrameView: view)
        // messageLabel.isHidden
    }
}

class PostingsCell: TodayItemCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tableView: PostingsTableView!
    override func layoutIfNeeded() {
        layoutIfNeeded(forFrameView: view)
        // messageLabel.isHidden
    }
}

class DashboardCell: TodayItemCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tableView: UITableView!

    override func layoutIfNeeded() {
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! DashboardTableDataSource
        if let loadDate = dataSource.loadDate {
            lastUpdateLabel.text = loadDate
        } else {
            lastUpdateLabel.text = nil
        }
        layoutIfNeeded(forFrameView: view)
    }
}
