//
//  VertretungsplanViewController.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WidgetKit

/// VPlan View Controller class
class VertretungsplanViewController:
    ExpandableHeaderVPlanViewController,
    ExpandableHeaderViewDelegate,
    VPlanLoaderDelegate
{
    private var selected: IndexPath?
    
    /// Initialise all properties after view has been loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged)
        
        if AppDefaults.authenticated {
            getVertretungsplanFromWeb()
        }
    }
    
    /// If VPlan can be used enable user interaction.
    /// - Parameter animated: Appear with animation when true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if !AppDefaults.authenticated {
            tableView.isUserInteractionEnabled = false
            tableView.reloadData()
        } else {
            tableView.isUserInteractionEnabled = true
        }
    }
    
    /// Prepare for touch action on grade row. Segue will navigate to details view.
    /// - Parameters:
    ///   - segue: Segue to prepare
    ///   - sender: Triggering view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vertretungsplanDetailViewController = segue.destination as? VertretungsplanDetailViewController,
           let selected = self.selected {
            vertretungsplanDetailViewController.gradeItem = data[selected.section - 2].gradeItems[selected.row]
            vertretungsplanDetailViewController.date = data[selected.section - 2].date
        }
    }
    
    /// Implements VPlanLoaderDelegate protocol function onload.
    /// - Parameters:
    ///   - vertretungsplan: VPlan data
    ///   - online: Flag indicating if data was loaded online
    func onload(with vertretungsplan: Vertretungsplan?, online: Bool) {
        if (vertretungsplan == nil) {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                let alert = UIAlertController(title: "Vertretungsplan", message: "Die Daten konnten leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.vertretungsplan = vertretungsplan
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// Load VPlan data
    private func getVertretungsplanFromWeb() {
        selected = nil
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: nil)
        vertretungsplanLoader.load(self)
    }

    /// Reloads data from backend on pull-to-refresh action.
    /// - Parameter sender: Triggering refresh control
    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        guard AppDefaults.authenticated else {
            sender.endRefreshing()
            return
        }

        getVertretungsplanFromWeb()
    }

    /// Returns number of sections.
    /// - Parameter tableView: Table view which requests number of sections.
    /// - Returns: Number of sections of table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard AppDefaults.authenticated else { return 1 }
        return data.count == 0 ? 0 : data.count + 2
    }
    
    /// When row is being selected remembers index path to this row. The path is needed
    /// to perform segue navigation to details view.
    /// - Parameters:
    ///   - tableView: Table view which requests number of sections.
    ///   - indexPath: Index path of row which is going to be selected.
    /// - Returns: Given index path unchanged
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selected = indexPath
        return indexPath
    }
    
    /// Returns number of rows in section. The first two sections are fix and have one row only
    /// for all following sections the number of grade items defines the number of rows
    /// - Parameters:
    ///   - tableView: tableView: Table view which requests information
    ///   - section: Section number
    /// - Returns: Number of rows in given section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard AppDefaults.authenticated, section >= 2 else { return 1 }
        return data[section - 2].expanded ? data[section - 2].gradeItems.count : 0
    }
    
    /// Computes height for row at index path.
    /// - Parameters:
    ///   - tableView: Table view which requests information
    ///   - indexPath: Path to cell
    /// - Returns: Hight of addressed cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard AppDefaults.authenticated else {
            return tableView.frame.height
                - (tabBarController?.tabBar.frame.height)!
                - (navigationController?.navigationBar.frame.height)!
        }
        
        switch(indexPath.section) {
        case 0: return 128 // 85 (Cell height) + 42 (Page Control + Spacing) + 1
        case 1: return UITableView.automaticDimension
        default: return 35
        }
    }
    
    /// Computes height of section header.
    /// - Parameters:
    ///   - tableView: Table view which requests information
    ///   - section: Section number
    /// - Returns: Height of section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section) {
        case 0: return 0
        case 1: return 0
        default: return 35
        }
    }
    
    /// Computes height of section footer.
    /// - Parameters:
    ///   - tableView: Table view which requests information
    ///   - section: Section number
    /// - Returns: Height of footer
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section < 2) ? 0 : 2
    }
    
    /// Returns the view which shows up in section header.
    /// - Parameters:
    ///   - tableView: Table view which requests information
    ///   - section: Section number
    /// - Returns: UITableViewHeaderFooterView instance
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section < 2) {
            return UITableViewHeaderFooterView()
        } else {
            let header = ExpandableHeaderView()
            header.customInit(userInteractionEnabled: data[section - 2].gradeItems.count > 0, section: section, delegate: self)
            return header
        }
    }
    
    /// Returns the title for section header. Date of vplan record shown in section is used as title.
    /// - Parameters:
    ///   - tableView:
    ///   - section: Table view which requests information
    /// - Returns: Section header title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section < 2) ? "" : data[section - 2].date
    }
    
    /// Returns the cell for a given index path
    /// - Parameters:
    ///   - tableView: Table view which requests information
    ///   - indexPath: Index path which addresses the cell
    /// - Returns: Cell to display at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard AppDefaults.authenticated else {
            return tableView.dequeueReusableCell(withIdentifier: "notLoggedIn")!
        }
        
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "metaDataCell") as! MetaDataTableViewCell
            cell.setContent(tickerText: StringHelper.replaceHtmlEntities(input: vertretungsplan?.tickerText), additionalText: StringHelper.replaceHtmlEntities(input: vertretungsplan?.additionalText))
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "lastUpdateCell")!
            cell.textLabel?.text = vertretungsplan?.lastUpdate
            cell.detailTextLabel?.text = "Letzte Aktualisierung"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!
            cell.textLabel?.text = data[indexPath.section - 2].gradeItems[indexPath.row].grade
            return cell
        }
    }
    
}
