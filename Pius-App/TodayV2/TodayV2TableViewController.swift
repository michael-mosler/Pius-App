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
}

/*
 * Observer protocol for data loaders. Data loaders must call didLoadData() when
 * data has been loaded from backend.
 */
protocol TodayItemContainer {
    func didLoadData(_ sender: Any?)
    func perform(segue: String, with data: Any?, presentModally: Bool)
}

protocol TodayItemDataSource {
    func needsShow() -> Bool
    func willTryLoading() -> Bool
    func loadData(_ observer: TodayItemContainer)
}

/*
 * This class is used to implement shared state of view controller as a singleton.
 */
class TodayViewSharedState {
    var controller: TodayItemContainer?
    private var dataSources: [DataSourceType : UITableViewDataSource] = [ .news : NewsTableDataSource(), .calendar : CalendarTableDataSource() ]

    func dataSource(forType type: DataSourceType) -> UITableViewDataSource? {
        return dataSources[type]
    }
}

class TodayV2TableViewController: UITableViewController, TodayItemContainer, ModalDismissDelegate {

    private var statusBarShouldBeHidden: Bool = false;
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden;
    }

    private static var sharedState: TodayViewSharedState = TodayViewSharedState()
    class var shared: TodayViewSharedState {
        return sharedState
    }
    
    private var pendingLoads = 0
    private var segueData: Any?
    
    override func awakeFromNib() {
        TodayV2TableViewController.shared.controller = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pendingLoads = 2
        (TodayV2TableViewController.shared.dataSource(forType: .news) as! NewsTableDataSource).loadData(self)
        (TodayV2TableViewController.shared.dataSource(forType: .calendar) as! CalendarTableDataSource).loadData(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath)
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath)
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath)
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
            
            if sender as? NewsTableDataSource != nil {
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
            } else if sender as? CalendarTableDataSource != nil {
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            }
            self.tableView.endUpdates()
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }

        pendingLoads -= 1
        if pendingLoads == 0 {
            NSLog("Will reload")
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
