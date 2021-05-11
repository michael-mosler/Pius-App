//
//  DashboardViewController.swift
//  Pius-App
//
//  Created by Michael on 28.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WidgetKit

/**
 * Basic Eva Table cell class. This class cares about setting insets and padding.
 * By default iOS adds some padding and insets which makes it hard to align text
 * with other elements.
 */
class EvaTableCell: UITableViewCell {
    var evaTextLabel: UITextView { UITextView() }

    override func layoutSubviews() {
        super.layoutSubviews()
        evaTextLabel.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        evaTextLabel.textContainer.lineFragmentPadding = 0
    }
}

/**
 * Container class for EVA text label in Dashboard tab.
 */
class DashboardEvaTableCell: EvaTableCell {
    @IBOutlet weak var evaTextLabelOutlet: UITextView!
    override var evaTextLabel: UITextView { return evaTextLabelOutlet }
}

/// Dashboard View Controller class
class DashboardViewController:
    ExpandableHeaderVPlanViewController,
    UITabBarControllerDelegate,
    ExpandableHeaderViewDelegate,
    VPlanLoaderDelegate
{
    
    @IBOutlet weak var evaButton: UIBarButtonItem!

    // private var vertretungsplan: Vertretungsplan?
    private var nextDate: String = ""
    
    private var canUseDashboard: Bool {
        get { AppDefaults.authenticated && AppDefaults.hasGrade }
    }

    // This dashboard is for this grade setting.
    private var grade: String = ""

    // That many rows per unfolded item.
    private let rowsPerItem = 5
    
    /// Initialise all properties after view has been loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        evaButton.isEnabled = false
        evaButton.tintColor = .white
        
        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged)
    }
    
    /// If dashboard can be used enable user interaction.
    /// - Parameter animated: Appear with animation when true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !canUseDashboard {
            tableView.isUserInteractionEnabled = false
            tableView.reloadData()
        } else {
            tableView.isUserInteractionEnabled = true
        }
    }
    
    /// When view did appear set title.
    /// - Parameter animated: Appear with animation when true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // This dashboard is for this grade setting.
        grade = AppDefaults.gradeSetting
        
        if data.count == 0 || title != grade {
            title = (grade != "") ? grade : "Dashboard"
            
            if canUseDashboard {
                getVertretungsplanFromWeb(forGrade: grade)
            }
        }
    }
    
    /// Implements VPlanLoaderDelegate protocol function onload.
    /// - Parameters:
    ///   - vertretungsplan: VPlan data
    ///   - online: Flag indicating if data was loaded online
    func onload(with vertretungsplan: Vertretungsplan?, online: Bool) {
        if vertretungsplan == nil {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()

                self.evaButton.tintColor = .white
                self.evaButton.isEnabled = false

                let alert = UIAlertController(title: "Vertretungsplan", message: "Die Daten konnten leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.vertretungsplan = vertretungsplan
            
            // What is actually next active substitution schedule date?
            let nextVertretungsplanForDate = vertretungsplan!.next
            if nextVertretungsplanForDate.count > 0 {
                nextDate = nextVertretungsplanForDate[0].date

                if let i = data.firstIndex(where: { $0.date == nextDate }) {
                    data[i].expanded = true
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.isHidden = false
                self.evaButton.tintColor = (AppDefaults.hasUpperGrade)
                    ? UIColor(named: "piusBlue")
                    : .white
                self.evaButton.isEnabled = AppDefaults.hasUpperGrade
                self.refreshControl?.endRefreshing()
            }
        }
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    /// Load VPlan data
    /// - Parameter grade: Load data for this grade
    private func getVertretungsplanFromWeb(forGrade grade: String) {
        nextDate = ""
        getVertretungsplanFromWeb(forGrade: grade, onLoadDelegate: self)
    }
    
    /// Reloads data from backend on pull-to-refresh action.
    /// - Parameter sender: Triggering refresh control
    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        guard canUseDashboard else {
            sender.endRefreshing()
            return
        }
        
        getVertretungsplanFromWeb(forGrade: grade)
    }
    
    /// Returns number of sections.
    /// - Parameter tableView: Table view which requests number of sections.
    /// - Returns: Number of sections of table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard canUseDashboard else { return 1 }
        return (data.count == 0) ? 0 : data.count + 2
    }
    
    /// Returns number of rows in table view section.
    /// - Parameters:
    ///   - tableView: tableView: Table view which requests information
    ///   - section: Section number
    /// - Returns: Number of rows in given section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        guard canUseDashboard && section >= 2 else { return 1 }
        return data[section - 2].expanded
            ? data[section - 2].gradeItems[0].vertretungsplanItems.count
            : 0
    }
    
    /// Computes height for row at index path.
    /// - Parameters:
    ///   - tableView: Table view which requests information
    ///   - indexPath: Path to cell
    /// - Returns: Hight of addressed cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard canUseDashboard else {
            return tableView.frame.height
                - (tabBarController?.tabBar.frame.height)!
                - (navigationController?.navigationBar.frame.height)!
        }

        return indexPath.section == 0 ? 128 : UITableView.automaticDimension
    }
    
    /// Computes height of section header.
    /// - Parameters:
    ///   - tableView: Table view which requests information
    ///   - section: Section number
    /// - Returns: Height of section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (section < 2) ? 0 : 35
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
        guard (section >= 2) else { return UITableViewHeaderFooterView() }

        let header = ExpandableHeaderView()
        header.customInit(userInteractionEnabled: (data[section - 2].gradeItems.count != 0), section: section, delegate: self)
        return header
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
        guard canUseDashboard else { return tableView.dequeueReusableCell(withIdentifier: "notLoggedIn")! }

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
            let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell") as? DashboardDetailsTableViewCell
            if let cell = cell {
                let gradeItem = data[indexPath.section - 2].gradeItems[0]
                let item = gradeItem.vertretungsplanItems[indexPath.row]
                
                cell.containingViewController = self

                let course = StringHelper.replaceHtmlEntities(input: item.course) ?? ""
                let lesson = item.lesson ?? ""
                
                cell.course = course != ""
                    ? String(format: "Fach/Kurs: %@, %@. Stunde", course, lesson)
                    : String(format: "%@. Stunde", lesson)
                cell.type = StringHelper.replaceHtmlEntities(input: item.type)
                cell.room = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: item.room))
                cell.teacher = StringHelper.replaceHtmlEntities(input: item.teacher)
                cell.comment = StringHelper.replaceHtmlEntities(input: item.comment)
                cell.eva = StringHelper.replaceHtmlEntities(input: item.eva)
            }
            
            return cell ?? UITableViewCell()
        }
    }

}
