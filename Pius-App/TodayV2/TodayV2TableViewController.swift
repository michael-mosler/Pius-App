//
//  TodayV2TableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

enum DataSourceType: Int {
    case news = 0
    case calendar = 1
    case postings = 2
    case dashboard = 3
    case timetable = 4
}

/*
 * Observer protocol for data loaders. Data loaders must call didLoadData() when
 * data has been loaded from backend.
 */
protocol TodayItemContainer {
    func didLoadData(_ sender: Any?)
    func perform(segue: String, with data: Any?, presentModally: Bool)
    
    func registerTimerDelegate(_ delegate: TimerDelegate)
}

protocol TodayItemDataSource {
    func needsShow() -> Bool
    func willTryLoading() -> Bool
    func loadData(_ observer: TodayItemContainer)
}

protocol TimerDelegate {
    func onTick(_ timer: Timer)
}

/*
 * This class is used to implement shared state of view controller as a singleton.
 */
class TodayViewSharedState {
    var controller: TodayItemContainer?
    private var dataSources: [DataSourceType : UITableViewDataSource] = [
        .dashboard : DashboardTableDataSource(),
        .postings : PostingsTableDataSource(),
        .news : NewsTableDataSource(),
        .calendar : CalendarTableDataSource(),
        .timetable: TimetableDataSource()
    ]

    func dataSource(forType type: DataSourceType) -> UITableViewDataSource? {
        return dataSources[type]
    }
}

class TodayV2TableViewController: UITableViewController, TodayItemContainer, ModalDismissDelegate {

    private var statusBarShouldBeHidden: Bool = false;
    private var timer: Timer?
    private var timerDelegates: [TimerDelegate] = []
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden;
    }

    private static var sharedState: TodayViewSharedState = TodayViewSharedState()
    class var shared: TodayViewSharedState {
        return sharedState
    }
    
    private var pendingLoads = 0
    private var segueData: Any?
    
    func registerTimerDelegate(_ delegate: TimerDelegate) {
        timerDelegates.append(delegate)
    }
    
    private func onTick(_ timer: Timer) {
        timerDelegates.forEach({ delegate in delegate.onTick(timer) })
    }
    
    override func awakeFromNib() {
        TodayV2TableViewController.shared.controller = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 5)!, repeats: true, block: { timer in self.onTick(timer) })

        pendingLoads = 4
        (TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! DashboardTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .postings) as! PostingsTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .news) as! NewsTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .calendar) as! CalendarTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TimetableDataSource).loadData(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }

    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        pendingLoads = 4
        (TodayV2TableViewController.shared.dataSource(forType: .dashboard) as! DashboardTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .postings) as! PostingsTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .news) as! NewsTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .calendar) as! CalendarTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TimetableDataSource).loadData(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "postingsCell", for: indexPath)
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: "dashboardCell", for: indexPath)
        case 3:
            return tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath)
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
        case 5:
            return tableView.dequeueReusableCell(withIdentifier: "timetableCell", for: indexPath)
        default:
            return UITableViewCell()
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TodayV2TableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? NewsArticleViewController else { return }
        destination.delegate = self
        destination.segueData = segueData
    }
    
    func hasDismissed() {
        if statusBarShouldBeHidden || tabBarController?.tabBar.isHidden ?? false {
            statusBarShouldBeHidden = false
            tabBarController?.tabBar.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
            
            view.setNeedsDisplay()
        }
    }

    func didLoadData(_ sender: Any? = nil) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            if sender as? DashboardTableDataSource != nil {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? DashboardCell {
                    cell.reload()
                }
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 5, section: 0)) as? TimetableCell {
                    cell.reload()
                }
            } else if sender as? NewsTableDataSource != nil {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? NewsCell {
                    cell.reload()
                }
            } else if sender as? CalendarTableDataSource != nil {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? CalendarCell {
                    cell.reload()
                }
            } else if sender as? PostingsTableDataSource != nil {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? PostingsCell {
                    cell.reload()
                }
            }
            self.tableView.endUpdates()

            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }

        pendingLoads -= 1
        if pendingLoads == 0 {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func perform(segue: String, with data: Any?, presentModally: Bool = true) {
        if presentModally {
            statusBarShouldBeHidden = true
            tabBarController?.tabBar.isHidden = true
            
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }

        segueData = data
        performSegue(withIdentifier: segue, sender: self)
    }
}
