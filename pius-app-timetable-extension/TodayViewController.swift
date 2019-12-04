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
class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, ItemContainerProtocol {
    
    var timetableDataSource: ExtTimetableDataSource = ExtTimetableDataSource()
    var dashboardDataSource: DashboardDataSource<ExtDashboardItemCell> = DashboardDataSource<ExtDashboardItemCell>()
    var completionHandler: ((NCUpdateResult) -> Void)? = nil
    
    // This is set only if widget is refreshed. Otherwise
    // compuation can get inconsistent. Aka, time stays constant
    // once widget is refreshed.
    private var currentLesson: Int? = 0
    
    @IBOutlet var widgetView: UIView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var timetableTableView: UITableView!
    @IBOutlet weak var timeMarkerView: UIView!
    @IBOutlet weak var timeMarkerDotView: UIView!
    @IBOutlet weak var timeMarkerViewTopConstraint: NSLayoutConstraint!
    
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
            timetableDataSource.forWeek == DateHelper.week(),
            timetableDataSource.forDay == DateHelper.dayOfWeek(),
            let row = currentLesson
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
        timetableTableView.delegate = self
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard AppDefaults.useTimetable else {
            weekLabel.text = nil
            return
        }
        
        weekLabel.text = "\(String(DateHelper.effectiveWeek()))-Woche"
        
        if #available(iOS 13.0, *) {
            weekLabel.textColor = .white
        }
    }
    
    @IBAction func openAppAction(_ sender: Any) {
        if timetableDataSource.canUseDashboard {
            extensionContext?.open(URL(string: "pius-app://dashboard")!);
        } else {
            extensionContext?.open(URL(string: "pius-app://today")!);
        }
    }
    
    /**
     * This delegate is needed because row height depends upon if timetable is configured.
     * If it is not we show a hint which requires a greater row height than regular display
     * mode.
     * As no other delegate methods are needed we do not define a dedicated table view class.
     * Also, this method needs to know height of widget in compact mode. Thus, it sounds natural
     * to have it in here.
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard AppDefaults.useTimetable else { return 110  }
        return 30
    }
    
    /**
     * Display mode has been toggled. Update table view and place marker.
     */
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            let frame = timetableTableView.rectForRow(at: IndexPath(row: 0, section: 0))
            preferredContentSize = CGSize(width: maxSize.width, height: 14 * frame.size.height + weekLabel.frame.size.height + 4)
            timetableDataSource.mode(useDisplayMode: .expanded)
            marker()
            timetableTableView.reloadData()
       } else {
            preferredContentSize = maxSize
            timetableDataSource.mode(useDisplayMode: .compact, withTopRow: topRow)
            marker()
            timetableTableView.reloadData()
        }
    }
    
    /**
     * Widget should reload.
     */
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        currentLesson = TimetableHelper.currentLesson()
        self.completionHandler = completionHandler
        if AppDefaults.useTimetable {
            dashboardDataSource.loadData(self)
            timetableDataSource.loadData(self)
        } else {
            timetableDataSource.loadData(self)
        }
    }
    
    /**
     * Place time marker on timetable view.
     */
    private func marker() {
        // Not current date or day has not started, yet.
        guard timetableDataSource.forWeek == DateHelper.week(),
            timetableDataSource.forDay == DateHelper.dayOfWeek(),
            let currentLesson = currentLesson,
            currentLesson != Int.min,
            currentLesson != Int.max
        else {
            timeMarkerView.isHidden = true
            timeMarkerDotView.isHidden = true
            return
        }
        
        // Offset, if not defined hide marker.
        guard let offset = TimetableHelper.offset(
            forCurrentLesson: currentLesson, withTopRow: topRow, withRowHeight: timetableTableView.rowHeight)
            else {
                timeMarkerView.isHidden = true
                timeMarkerDotView.isHidden = true
                return
            }
        
        // Set marker visible and update top constraint.
        timeMarkerView.isHidden = false
        timeMarkerDotView.isHidden = false
        timeMarkerViewTopConstraint.constant = offset
    }
    
    /**
     * Delegate to signal data has been loaded. Depending on the signalling
     * data source timetable view is filled with either timetable only or
     * with substitution schedule mixed in.
     */
    func didLoadData(_ sender: Any? = nil) {
        DispatchQueue.main.async {
            // Can't use timetable, restrict display mode to compact.
            guard AppDefaults.useTimetable else {
                self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
                self.completionHandler?(NCUpdateResult.newData)
                return
            }
            
            if sender as? ExtTimetableDataSource != nil {
                self.timetableDataSource.forWeek = DateHelper.effectiveWeek()
                self.timetableDataSource.forDay = DateHelper.effectiveDay()
                self.timetableDataSource.mode(useDisplayMode: self.extensionContext?.widgetActiveDisplayMode ?? .compact, withTopRow: self.topRow)
                self.timetableTableView.reloadData()
                self.marker()
                self.widgetView.layoutIfNeeded()
            } else if let sender = sender as? DashboardDataSource<ExtDashboardItemCell> {
                self.timetableDataSource.substitutionSchedule = sender.substitutionSchedule
                self.timetableDataSource.forWeek = DateHelper.effectiveWeek()
                self.timetableDataSource.forDay = DateHelper.effectiveDay()
                self.timetableDataSource.mode(useDisplayMode: self.extensionContext?.widgetActiveDisplayMode ?? .compact, withTopRow: self.topRow)
                self.timetableTableView.reloadData()
                self.marker()
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
