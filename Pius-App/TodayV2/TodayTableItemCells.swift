//
//  TodayTableItemCells.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayItemCell: UITableViewCell {
    fileprivate func layoutIfNeeded(forFrameView view: UIView) {
        super.layoutIfNeeded()
        view.layer.borderColor = Config.colorPiusBlue.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false;
    }
    
    fileprivate func reload(_ tableView: UITableView) {
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    func reload() { }
}

class NewsCell: TodayItemCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tableView: NewsTableView!
    
    override func layoutIfNeeded() {
        layoutIfNeeded(forFrameView: view)
    }
    
    override func reload() {
        reload(tableView)
    }
}

class CalendarCell: TodayItemCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var tableView: CalendarTableView!
    
    override func layoutIfNeeded() {
        layoutIfNeeded(forFrameView: view)
    }
    
    override func reload() {
        reload(tableView)
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

    override func reload() {
        reload(tableView)
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

    override func reload() {
        reload(tableView)
    }
}

class TimetableCell: TodayItemCell, UICollectionViewDelegate, UIScrollViewDelegate {
    private var needsPositioning: Bool = true
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var dayTextLabel: UILabel!
    @IBOutlet weak var collectionView: TodayTimetableCollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var view: UIView!

    // The day that is selected in collection view. 0 = Monday, 4 = Friday
    private var currentDay: Int {
        get {
            guard let scrollView = collectionView else { return 0 }
            return Int((scrollView.contentOffset.x / CGFloat(IOSHelper.screenWidth)).rounded());
        }
    }

    // The day to show, for weekends this return 0 = Monday otherwise the real
    // day is returned.
    private var dayToShow: Int {
        get {
            return DateHelper.dayOfWeek() > 4 ? 0 : DateHelper.dayOfWeek()
        }
    }
    
    // The week to show. On weekends the week to show swaps, aka if current week is .A
    // variable value is .B.
    private var weekToShow: Week {
        get {
            guard let week: Week = DateHelper.week() else { return .A }
            guard DateHelper.dayOfWeek() > 4 else { return week }
            return week == .A ? .B : .A
        }
    }

    // When cell gets awakened start showing with current day and week and reload data.
    override func awakeFromNib() {
        collectionView.delegate = self
        reload()
    }

    override func layoutIfNeeded() {
        // We want to show load date of substitution schedule. Thus, we need the data source for substitution
        // schedule.
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! DashboardTableDataSource
        if let loadDate = dataSource.loadDate {
            lastUpdateLabel.text = loadDate
        } else {
            lastUpdateLabel.text = nil
        }
        
        // Draw border.
        layoutIfNeeded(forFrameView: view)

        if DateHelper.dayOfWeek() == currentDay {
            dayTextLabel.attributedText = NSAttributedString(string: "Heute")
        } else {
            dayTextLabel.attributedText = NSAttributedString(string: Config.dayNames[currentDay])
        }

        // On first show center on timetable for current day of week.
        if needsPositioning {
            collectionView.scrollToItem(at: IndexPath(row: dayToShow, section: 0), at: .centeredHorizontally, animated: false)
            needsPositioning = false
        }
    }
    
    // This reloads data and positions on current day to show.
    // It also ensures proper sizing of collection view items.
    override func reload() {
        needsPositioning = true
        let itemCount = ScheduleForDay().numberOfItems
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TimetableDataSource
        dataSource.forWeek = weekToShow
        dataSource.forDay = dayToShow

        collectionView.reloadData()
        collectionViewHeightConstraint.constant = CGFloat(itemCount * TodayScreenUnits.timetableRowHeight + 2 * TodayScreenUnits.timetableSpacing)
        flowLayout.itemSize = CGSize(width: collectionView.frame.width - 8, height: collectionViewHeightConstraint.constant)
        
    }
    
    // On end of scrolling of collection view update timetable shown. Also update day name. For current
    // day show "Heute" otherwise day name.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Set data source and let it know which day of week and week it is running for.
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TimetableDataSource
        dataSource.forWeek = weekToShow
        dataSource.forDay = currentDay
        collectionView.reloadData()
        layoutIfNeeded()
    }
}
