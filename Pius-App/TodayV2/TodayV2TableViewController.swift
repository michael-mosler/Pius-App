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

protocol TodayItemDataSourceProtocol {
    func needsShow() -> Bool
    func willTryLoading() -> Bool
    func isEmpty() -> Bool
    func loadData(_ observer: ItemContainerProtocol)
}

/*
 * This class is used to implement shared state of view controller as a singleton.
 */
class TodayViewSharedState {
    var controller: ItemContainerProtocol?
    fileprivate let dataSources: [DataSourceType : UITableViewDataSource] = [
        .dashboard : TodayDashboardDataSource<DashboardTableViewCell>(),
        .postings : PostingsTableDataSource(),
        .news : NewsTableDataSource(),
        .calendar : CalendarTableDataSource(),
        .timetable: TodayTimetableDataSource<TodayTimetableItemCell>()
    ]

    func dataSource(forType type: DataSourceType) -> UITableViewDataSource? {
        return dataSources[type]
    }
}

class TodayV2TableViewController: UITableViewController, ItemContainerProtocol {
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
    private var isLoadCancelled = true
    private var segueData: Any?
    
    private var newFunctionHelpPopoverViewController: NewFunctionOnboardingViewController?
    
    @IBAction
    func endOnboardingView(_ unwindSegue: UIStoryboardSegue) {
        if #available(iOS 13.0, *) {
            showFunctionHelpPopovers()
        }
    }
    
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
        newFunctionHelpPopoverViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewFunctionHelpPopover") as? NewFunctionOnboardingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func showFunctionHelpPopovers() {
        for cell in tableView.visibleCells {
            if let cell = cell as? TodayItemCell {
                DispatchQueue.main.async(execute: cell.showNewFunctionOnboardingPopover)
                break
            }
        }
    }
    
    // Starts load for all Today sub-views.
    private func loadData() {
        pendingLoads = 0
        isLoadCancelled = false
        TodayV2TableViewController.shared.dataSources.forEach({ item in
            let (_, dataSource) = item
            if let dataSource = dataSource as? TodayItemDataSourceProtocol, dataSource.willTryLoading() {
                pendingLoads += 1
            }
        })
        
        TodayV2TableViewController.shared.dataSources.forEach({ item in
            let (_, dataSource) = item
            if let dataSource = dataSource as? TodayItemDataSourceProtocol, dataSource.willTryLoading() {
                dataSource.loadData(self)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(exactly: 1)!, repeats: true, block: { timer in self.onTick(timer) })
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Config.showOnboarding {
            performSegue(withIdentifier: "toOnboarding", sender: self)
        } else {
            showFunctionHelpPopovers()
        }

        // When loads have been cancelled reload.
        if isLoadCancelled {
            loadData()
        }
    }
    
    // Invalidate timer, will be restarted when view appears again.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
        
        // If there are pending loads then mark loads as cancelled. This
        // will cause reload on viewDidAppear().
        isLoadCancelled = pendingLoads > 0
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
            if let dataSource = dataSource as? TodayItemDataSourceProtocol, !dataSource.needsShow(),
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
            cell.registerNewFunctionOnboardingPopover(viewController: newFunctionHelpPopoverViewController)
        }

        return cell
    }
}

// Extension that implements protocol TodayItemContainer.
extension TodayV2TableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? NewsArticleViewController {
            destination.segueData = segueData
        } else if let destination = segue.destination as? TodayScheduleItemDetailsViewController {
            destination.segueData = segueData
        }
    }
    
    private func rowNum(_ cellOrder: [String], forCellIdentifier id: String) -> Int? {
        return cellOrder.firstIndex(of: id)
    }
    
    func didLoadData(_ sender: Any? = nil) {
        DispatchQueue.main.async {
            if self.isLoadCancelled {
                return
            }

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
                    self.tableView.insertRows(at: [IndexPath(row: rowNum, section: 0)], with: .none)
                }
            })
            
            let deleted = cellOrderSet.subtracting(newCellOrderSet)
            deleted.forEach({ cellIdentifier in
                if let rowNum = self.rowNum(self.cellOrder, forCellIdentifier: cellIdentifier) {
                    self.tableView.deleteRows(at: [IndexPath(row: rowNum, section: 0)], with: .none)
                }
            })
            
            self.cellOrder = newCellOrder

            if sender as? TodayDashboardDataSource<DashboardTableViewCell> != nil {
                // Whenever a new substitution schedule has been loaded update timetable data source.
                let sender = sender as! TodayDashboardDataSource<DashboardTableViewCell>
                let timetableDataSource = TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TodayTimetableDataSource<TodayTimetableItemCell>
                timetableDataSource.substitutionSchedule = sender.substitutionSchedule
            }
            self.tableView.endUpdates()

            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()

            self.pendingLoads -= 1
            if self.pendingLoads == 0 {
                self.refreshControl?.endRefreshing()
                
                // Check that onboarding view controller is not shown.
                // Then give table view some time to reposition after drag to refresh.
                if self.presentedViewController == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: self.showFunctionHelpPopovers)
                }
            }
        }
    }
    
    func perform(segue: String, with data: Any?) {
        segueData = data
        performSegue(withIdentifier: segue, sender: self)
    }
}
