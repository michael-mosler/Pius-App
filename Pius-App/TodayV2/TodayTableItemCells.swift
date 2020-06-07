//
//  TodayTableItemCells.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayItemCell: UITableViewCell {
    fileprivate var newFunctionOnboardingViewController: NewFunctionOnboardingViewController?
    
    fileprivate func layoutIfNeeded(forFrameView view: UIView) {
        // guard window != nil else { return }
        super.layoutIfNeeded()
        view.layer.borderColor = UIColor(named: "piusBlue")?.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false
    }
    
    fileprivate func reload(_ tableView: UITableView) {
        setNeedsLayout()
        tableView.reloadData()
        layoutIfNeeded()
        // tableView.layoutIfNeeded()
    }
    
    func reload() { }
    
    func showHelpPopover(viewController: NewFunctionOnboardingViewController?) {
        newFunctionOnboardingViewController = viewController
    }
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

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let newFunctionOnboardingViewController = newFunctionOnboardingViewController,
            !newFunctionOnboardingViewController.hasShownHelp
        else { return }

        newFunctionOnboardingViewController.hasShownHelp = true
        newFunctionOnboardingViewController.setSourceView(view: tableView)
        let controller = TodayV2TableViewController.shared.controller as? UIViewController
        controller?.present(newFunctionOnboardingViewController, animated: true)
    }

    override func layoutIfNeeded() {
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! TodayDashboardDataSource<DashboardTableViewCell>
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
    @IBOutlet weak var weekSegmentControl: UISegmentedControl!
    
    @IBAction func weekSegmentControlAction(_ sender: UISegmentedControl) {
        weekToShow = Week(rawValue: sender.selectedSegmentIndex) ?? .A
        doReload()
        layoutIfNeeded()
    }
    
    // The day that is selected in collection view. 0 = Monday, 4 = Friday
    private var selectedDay: Int {
        get {
            return Int((collectionView.contentOffset.x / CGFloat(IOSHelper.screenWidth)).rounded());
        }
    }

    private var dayToShow: Int = 0
    private var weekToShow: Week = .A
    
    // When cell gets awakened set delegate and reload data.
    override func awakeFromNib() {
        collectionView.delegate = self
        reload()
    }

    override func layoutIfNeeded() {
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! TodayDashboardDataSource<DashboardTableViewCell>
        if let loadDate = dataSource.loadDate {
            lastUpdateLabel.text = loadDate
        } else {
            lastUpdateLabel.text = nil
        }
        
        // Draw border.
        layoutIfNeeded(forFrameView: view)

        if dayToShow == DateHelper.dayOfWeek() && weekToShow == DateHelper.effectiveWeek() {
            dayTextLabel.attributedText = NSAttributedString(string: "Heute")
        } else {
            dayTextLabel.attributedText = NSAttributedString(string: Config.dayNames[selectedDay])
        }

        // On first show center on timetable for current day of week.
        if needsPositioning {
            collectionView.scrollToItem(at: IndexPath(row: DateHelper.effectiveDay(), section: 0), at: .centeredHorizontally, animated: false)
            needsPositioning = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let newFunctionOnboardingViewController = newFunctionOnboardingViewController,
            !newFunctionOnboardingViewController.hasShownHelp
        else { return }

        newFunctionOnboardingViewController.hasShownHelp = true
        newFunctionOnboardingViewController.setSourceView(view: collectionView)
        let controller = TodayV2TableViewController.shared.controller as? UIViewController
        controller?.present(newFunctionOnboardingViewController, animated: true)
    }

    // This reloads data and positions on current day to show.
    // It also ensures proper sizing of collection view items.
    private func doReload() {
        // Set week to show in data source.
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TodayTimetableDataSource<TodayTimetableItemCell>
        dataSource.forWeek = weekToShow
        dataSource.forDay = selectedDay
        weekSegmentControl.selectedSegmentIndex = weekToShow.rawValue

        collectionView.reloadData()
    }
    
    override func reload() {
        needsPositioning = true
        
        // On reload we reset day and week to current date.
        weekToShow = DateHelper.effectiveWeek()
        dayToShow = DateHelper.effectiveDay()
        doReload()

        collectionViewHeightConstraint.constant = CGFloat(ScheduleForDay().numberOfItems * TodayScreenUnits.timetableRowHeight + 2 * TodayScreenUnits.timetableSpacing)
        flowLayout.itemSize = CGSize(width: collectionView.frame.width, height: collectionViewHeightConstraint.constant)
    }
    
    // On end of scrolling of collection view update timetable shown. Also update day name. For current
    // day show "Heute" otherwise day name.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Set data source and let it know which day of week and week it is running for.
        let dataSource = TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TodayTimetableDataSource<TodayTimetableItemCell>
        dayToShow = selectedDay
        dataSource.forWeek = weekToShow
        dataSource.forDay = dayToShow
        collectionView.reloadData()
        layoutIfNeeded()
    }
}
