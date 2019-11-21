//
//  TodayViewController.swift
//  pius-app-timetable-extension
//
//  Created by Michael Mosler-Krings on 14.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, ItemContainerProtocol {
    
    var timetableDataSource: ExtTimetableDataSource = ExtTimetableDataSource()
    var dashboardDataSource: DashboardDataSource<ExtDashboardItemCell> = DashboardDataSource<ExtDashboardItemCell>()
    var completionHandler: ((NCUpdateResult) -> Void)? = nil
    
    @IBOutlet var widgetView: UIView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var timetableTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .compact
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
        } else {
            preferredContentSize = maxSize
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        if AppDefaults.useTimetable {
            self.completionHandler = completionHandler
            dashboardDataSource.loadData(self)
            timetableDataSource.loadData(self)
        } else {
            
        }
    }
    
    func didLoadData(_ sender: Any? = nil) {
        DispatchQueue.main.async {
            if sender as? ExtTimetableDataSource != nil {
                self.timetableDataSource.forWeek = DateHelper.effectiveWeek()
                self.timetableDataSource.forDay = DateHelper.effectiveDay()
                self.timetableTableView.reloadData()
                self.widgetView.layoutIfNeeded()
            } else if let sender = sender as? DashboardDataSource<ExtDashboardItemCell> {
                self.timetableDataSource.substitutionSchedule = sender.substitutionSchedule
                self.timetableDataSource.forWeek = DateHelper.effectiveWeek()
                self.timetableDataSource.forDay = DateHelper.effectiveDay()
                self.timetableTableView.reloadData()
                self.widgetView.layoutIfNeeded()
            }
            
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
            self.completionHandler?(NCUpdateResult.newData)
        }
    }
    
    func perform(segue: String, with data: Any?, presentModally: Bool) {
        
    }
    
    func registerTimerDelegate(_ delegate: TimerDelegate) {
        
    }

}
