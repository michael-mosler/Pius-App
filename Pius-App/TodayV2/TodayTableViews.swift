//
//  TodayTableViews.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

/* *************************************************************************
 * Base class for all embedded table views. This class makes sure
 * that table view and its containing views gets properly resized
 * when data has been loaded into table.
 * *************************************************************************/
class TodayItemTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}

/// News table view shows up to 6 news items with a preview image.
/// When selecting one item article is opened in a modal popover.
class NewsTableView: TodayItemTableView,
                     UITableViewDelegate,
                     UIPopoverPresentationControllerDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        dataSource = TodayV2TableViewController.shared.dataSource(forType: .news)
    }
    
    /// Opens a given URL with browser engine selected by user.
    /// - Parameters:
    ///   - selection:Browser engine to use.
    ///   - url: URL to open
    private func openUrl(selection: AppDefaults.BrowserSelection, url: URL) {
        if selection == .useInternal {
            TodayV2TableViewController.shared.controller?.perform(segue: "showNews", with: url, presentModally: true)
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    /// This function gets called whenever the use selects a news row.
    /// - Parameters:
    ///   - tableView: News table view
    ///   - indexPath: Index path of row that has been selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell, let href = cell.href, let url = URL(string: href) else { return }
        
        // Ask for browser engine to use. Once the selection is made onSelect-handler function
        // is called which will delegate open request to openURL function.
        let browserSelection = BrowserSelection(
            parentViewController: TodayV2TableViewController.shared.controller as? UIViewController,
            onSelect: { (url: URL) in
                return { (selection: AppDefaults.BrowserSelection) in
                    self.openUrl(selection: selection, url: url)
                }
            }(url))

        browserSelection.choice()
    }
}

/* *************************************************************************
 * Calendar tableview shows calendar items for current date.
 * *************************************************************************/
class CalendarTableView: TodayItemTableView {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = TodayV2TableViewController.shared.dataSource(forType: .calendar)
    }
}

/* *************************************************************************
 * Postings tableview shows postings items if there are any.
 * *************************************************************************/
class PostingsTableView: TodayItemTableView {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = TodayV2TableViewController.shared.dataSource(forType: .postings)
    }
}

/* *************************************************************************
 * Dashboard tableview shows substitution schedule entries for today.
 * *************************************************************************/
class DashboardTableView: TodayItemTableView {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = TodayV2TableViewController.shared.dataSource(forType: .dashboard)
    }
}

/* *************************************************************************
 * This table view is used in timetable collection view of today page.
 * Each collection view item holds exactly one tableview which shows
 * one day from timetable either of week A or B.
 * *************************************************************************/
class TodayTimetableTableView: TodayItemTableView, UITableViewDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = TodayV2TableViewController.shared.dataSource(forType: .timetable)
        delegate = self
        
        /*
        let popoverController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShortcutNameHelp") as! NewFunctionOnboardingViewController
        popoverController.setSourceView(view: self)
        let controller = TodayV2TableViewController.shared.controller as? UIViewController
        controller?.present(popoverController, animated: true)
        */
    }
    
    // The week that is shown by this tableview.
    var forWeek: Week {
        get {
            guard let dataSource = dataSource as? TodayTimetableDataSource<TodayTimetableItemCell> else { return .A }
            return dataSource.forWeek ?? .A
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(TodayScreenUnits.timetableRowHeight)
    }
    
    func onTick(forRow row: Int) {
        for i in 0...numberOfRows(inSection: 0) {
            if let cell = cellForRow(at: IndexPath(row: i, section: 0)) as? TodayTimetableItemCell {
                cell.onTick(forRow: row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TodayTimetableItemCell, let scheduleItem = cell.scheduleItem, scheduleItem.isSubstitution else {
            return
        }
        
        TodayV2TableViewController.shared.controller?.perform(segue: "showDetails", with: scheduleItem, presentModally: true)
    }
}
