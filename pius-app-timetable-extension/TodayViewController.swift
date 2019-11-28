//
//  TodayViewController.swift
//  pius-app-timetable-extension
//
//  Created by Michael Mosler-Krings on 14.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit
import NotificationCenter

/**
 * View controller for iOS Today view timetable widget.
 */
class TodayViewController: UIViewController, NCWidgetProviding, ItemContainerProtocol {
    
    var timetableDataSource: ExtTimetableDataSource = ExtTimetableDataSource()
    var dashboardDataSource: DashboardDataSource<ExtDashboardItemCell> = DashboardDataSource<ExtDashboardItemCell>()
    var completionHandler: ((NCUpdateResult) -> Void)? = nil
    
    @IBOutlet var widgetView: UIView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var timetableTableView: UITableView!
    
    /**
     * Returns the top row top be displayed in timetable. Top row refers
     * to the first row shown in table view. In compact mode top row
     * is calculated so that current lessin is displayed in the middle,
     * if possible.
     */
    private var topRow: Int {
        // In expanded mode top row is always 0.
        // When there are no rows displayed top row is 0.
        // If current lesson cannot be computed then top row is also 0.
        guard extensionContext?.widgetActiveDisplayMode ?? .compact == .compact,
            timetableTableView.numberOfRows(inSection: 0) > 0,
            let row = TimetableHelper.currentLesson()
        else { return 0 }
        
        // If current time is before first lesson start with 0.
        if row == Int.min {
            return 0
        }
        
        // If current is after last lesson show last lesson in bottom row.
        if row == Int.max {
            return (lessons.count - 1) - 2
        }
        
        // Center current lesson.
        let topRow = max(row - 1, 0)
        let bottomRow = min(topRow + 2, lessons.count)
        let delta = bottomRow - topRow
        return topRow - (2 - delta)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .compact
        timetableDataSource.mode(useDisplayMode: extensionContext?.widgetActiveDisplayMode ?? .compact)
        timetableTableView.dataSource = timetableDataSource
    }
        
    override func viewWillAppear(_ animated: Bool) {
        weekLabel.text = "\(String(DateHelper.effectiveWeek()))-Woche"
        
        if #available(iOS 13.0, *) {
            weekLabel.textColor = .white
        }
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            let frame = timetableTableView.rectForRow(at: IndexPath(row: 0, section: 0))
            preferredContentSize = CGSize(width: maxSize.width, height: 14 * frame.size.height + weekLabel.frame.size.height + 4)
            timetableDataSource.mode(useDisplayMode: .expanded)
            timetableTableView.reloadData()
        } else {
            preferredContentSize = maxSize
            
            // Now we need to make sure that current lesson is displayed in
            // the middle of view. For first and last lesson this is not
            // possible, they are displayed as first or last row, respectively.
            guard let row = TimetableHelper.currentLesson(), timetableTableView.numberOfRows(inSection: 0) > 0
                else { return }
            
            var topRow: Int
            var bottomRow: Int
            if row == Int.min {
                topRow = 0
                bottomRow = 2
            } else if row == Int.max {
                bottomRow = lessons.count - 1
                topRow = bottomRow - 2
            } else {
                topRow = max(row - 1, 0)
                bottomRow = min(topRow + 1, lessons.count)
                let delta = bottomRow - topRow
                topRow -= (3 - delta)
            }
            
            timetableDataSource.mode(useDisplayMode: .compact, withTopRow: topRow)
            timetableTableView.reloadData()
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        if AppDefaults.useTimetable {
            self.completionHandler = completionHandler
            dashboardDataSource.loadData(self)
            timetableDataSource.loadData(self)
        } else {
            timetableDataSource.loadData(self)
        }
    }
    
    /**
     * Delegate to signal data has been loaded. Depending on the signalling
     * data source timetable view is filled with either timetable only or
     * with substitution schedule mixed in.
     */
    func didLoadData(_ sender: Any? = nil) {
        DispatchQueue.main.async {
            if sender as? ExtTimetableDataSource != nil {
                self.timetableDataSource.forWeek = DateHelper.effectiveWeek()
                self.timetableDataSource.forDay = DateHelper.effectiveDay()
                self.timetableDataSource.mode(useDisplayMode: self.extensionContext?.widgetActiveDisplayMode ?? .compact, withTopRow: self.topRow)
                self.timetableTableView.reloadData()
                self.widgetView.layoutIfNeeded()
            } else if let sender = sender as? DashboardDataSource<ExtDashboardItemCell> {
                self.timetableDataSource.substitutionSchedule = sender.substitutionSchedule
                self.timetableDataSource.forWeek = DateHelper.effectiveWeek()
                self.timetableDataSource.forDay = DateHelper.effectiveDay()
                self.timetableDataSource.mode(useDisplayMode: self.extensionContext?.widgetActiveDisplayMode ?? .compact, withTopRow: self.topRow)
                self.timetableTableView.reloadData()
                self.widgetView.layoutIfNeeded()
            }
            
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            self.completionHandler?(NCUpdateResult.newData)
        }
    }
    
    func perform(segue: String, with data: Any?, presentModally: Bool) {
        // Empty, no segue exists.
    }
    
    func registerTimerDelegate(_ delegate: TimerDelegate) {
        // Empty, won't use timer. We suppose that marker does not need to
        // be moved as nobody will be using widget that long that any movement
        // gets visible.
    }

}
