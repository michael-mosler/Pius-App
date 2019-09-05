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

protocol TimerDelegate: NSObject {
    func onTick(_ timer: Timer?)
}

/*
 * This class is used to implement shared state of view controller as a singleton.
 */
class TodayViewSharedState {
    var controller: TodayItemContainer?
    fileprivate let dataSources: [DataSourceType : UITableViewDataSource] = [
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
    private let dataSourcesToCellPrototypes: [DataSourceType : String] = [
        .dashboard : "dashboardCell",
        .postings : "postingsCell",
        .news : "newsCell",
        .calendar : "calendarCell",
        .timetable : "timetableCell"
    ]

    // This is the final list of cells to show.
    private var cellOrder: [String] = []
    
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
    
    // Register a timer delegate.
    func registerTimerDelegate(_ delegate: TimerDelegate) {
        if let _ = timerDelegates.first(where: { registeredDelegate in return delegate === registeredDelegate }) {
            delegate.onTick(timer)
            return
        }
        timerDelegates.append(delegate)
        delegate.onTick(timer)
    }
    
    // Delegate timer tick to all registered delegates.
    private func onTick(_ timer: Timer) {
        timerDelegates.forEach({ delegate in delegate.onTick(timer) })
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        cellOrder = cellsToShow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        cellOrder = cellsToShow()
    }
    
    override func awakeFromNib() {
        TodayV2TableViewController.shared.controller = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged)
    }
    
    // Starts load for all Today sub-views.
    private func loadData() {
        pendingLoads = 0
        TodayV2TableViewController.shared.dataSources.forEach({ item in
            let (_, dataSource) = item
            if let dataSource = dataSource as? TodayItemDataSource, dataSource.willTryLoading() {
                pendingLoads += 1
            }
        })
        
        TodayV2TableViewController.shared.dataSources.forEach({ item in
            let (_, dataSource) = item
            if let dataSource = dataSource as? TodayItemDataSource, dataSource.willTryLoading() {
                dataSource.loadData(self)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 1)!, repeats: true, block: { timer in self.onTick(timer) })
        }

        loadData()
    }
    
    // Invalidate timer, will be restarted when view appears again.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    // Does nothing else than reload all sub-views.
    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        loadData()
    }
    
    private func cellsToShow() -> [String] {
        // Ask all data sources if show is needed. When not remove associated
        // it from cells to show.
        var newCellOrder = [
            "headerCell",
            dataSourcesToCellPrototypes[.postings],
            dataSourcesToCellPrototypes[.timetable],
            dataSourcesToCellPrototypes[.dashboard],
            dataSourcesToCellPrototypes[.calendar],
            dataSourcesToCellPrototypes[.news]
            ] as! [String]
        
        TodayV2TableViewController.shared.dataSources.forEach({ item in
            let (key, dataSource) = item
            if let dataSource = dataSource as? TodayItemDataSource, !dataSource.needsShow(),
                let cellPrototype = dataSourcesToCellPrototypes[key],
                let index = newCellOrder.firstIndex(of: cellPrototype) {
                newCellOrder.remove(at: index)
            }
        })
        
        return newCellOrder
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellOrder.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < 6 else { return UITableViewCell() }
        guard indexPath.row > 0 else { return tableView.dequeueReusableCell(withIdentifier: cellOrder[0], for: indexPath) }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellOrder[indexPath.row], for: indexPath)
        if let cell = cell as? TodayItemCell {
            cell.reload()
        }
        return cell
    }
}

// Extension that implements protocol TodayItemContainer.
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

    private func rowNum(_ cellOrder: [String], forCellIdentifier id: String) -> Int? {
        return cellOrder.firstIndex(of: id)
    }
    
    func didLoadData(_ sender: Any? = nil) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            
            // Need cells to be added or removed? This must
            // be done within beginUpdates()/endUpdates()
            // so that tableview knows about these changes.
            let newCellOrder = self.cellsToShow()
            let newCellOrderSet = Set<String>(newCellOrder)
            let cellOrderSet = Set<String>(self.cellOrder)
            
            let inserted = newCellOrderSet.subtracting(cellOrderSet)
            inserted.forEach({ cellIdentifier in
                if let rowNum = self.rowNum(newCellOrder, forCellIdentifier: cellIdentifier) {
                    self.tableView.insertRows(at: [IndexPath(row: rowNum, section: 0)], with: .fade)
                }
            })
            
            let deleted = cellOrderSet.subtracting(newCellOrderSet)
            deleted.forEach({ cellIdentifier in
                if let rowNum = self.rowNum(self.cellOrder, forCellIdentifier: cellIdentifier) {
                    self.tableView.deleteRows(at: [IndexPath(row: rowNum, section: 0)], with: .fade)
                }
            })
            
            self.cellOrder = newCellOrder
            
            if sender as? DashboardTableDataSource != nil {
                if let rowNum = self.rowNum(self.cellOrder, forCellIdentifier: "dashboardCell"), let cell = self.tableView.cellForRow(at: IndexPath(row: rowNum, section: 0)) as? TodayItemCell {
                    cell.reload()
                }
                if let rowNum = self.rowNum(self.cellOrder, forCellIdentifier: "timetableCell"), let cell = self.tableView.cellForRow(at: IndexPath(row: rowNum, section: 0)) as? TodayItemCell {
                    cell.reload()
                }
            } else if sender as? NewsTableDataSource != nil {
                if let rowNum = self.rowNum(self.cellOrder, forCellIdentifier: "newsCell"), let cell = self.tableView.cellForRow(at: IndexPath(row: rowNum, section: 0)) as? TodayItemCell {
                    cell.reload()
                }
            } else if sender as? CalendarTableDataSource != nil {
                if let rowNum = self.rowNum(self.cellOrder, forCellIdentifier: "calendarCell"), let cell = self.tableView.cellForRow(at: IndexPath(row: rowNum, section: 0)) as? TodayItemCell {
                    cell.reload()
                }
            } else if sender as? PostingsTableDataSource != nil {
                if let rowNum = self.rowNum(self.cellOrder, forCellIdentifier: "postingsCell"), let cell = self.tableView.cellForRow(at: IndexPath(row: rowNum, section: 0)) as? TodayItemCell {
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
