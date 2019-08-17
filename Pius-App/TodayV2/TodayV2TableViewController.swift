//
//  TodayV2TableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

protocol TodayItemContainer {
    func didLoadData(_ sender: Any?)
}

protocol TodayItem {
    var container: TodayItemContainer? { get set }
    
    func needsShow() -> Bool
    func willTryLoading() -> Bool
    func loadData(container: TodayItemContainer)
}

class TodayV2TableViewController: UITableViewController, TodayItemContainer {

    private var newsCell: NewsCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        newsCell?.loadData(container: self)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "headerCell", for: indexPath) as! TodayHeaderCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsCell
            newsCell = cell
            return cell
        default:
            cell = UITableViewCell()
            return cell
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
    func didLoadData(_ sender: Any? = nil) {
        NSLog("Done Loading")
        guard let itemTableView = sender as? UITableView else { return }
        // tableView.beginUpdates()
        itemTableView.reloadData()
        itemTableView.layoutSubviews()
        // tableView.endUpdates()
        tableView.setNeedsLayout()
        tableView.reloadData()
    }
}
