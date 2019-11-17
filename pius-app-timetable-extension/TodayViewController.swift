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
    @IBOutlet weak var timetableTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timetableTableView.dataSource = timetableDataSource
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        timetableDataSource.loadData(self)
        completionHandler(NCUpdateResult.newData)
    }
    
    func didLoadData(_ sender: Any? = nil) {
        NSLog("ExtTimetable did load data")
    }
    
    func perform(segue: String, with data: Any?, presentModally: Bool) {
        
    }
    
    func registerTimerDelegate(_ delegate: TimerDelegate) {
        
    }

}
