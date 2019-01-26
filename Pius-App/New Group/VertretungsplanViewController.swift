//
//  VertretungsplanViewController.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class VertretungsplanViewController: UITableViewController, ExpandableHeaderViewDelegate {
    private var vertretungsplan: Vertretungsplan?;
    private var selected: IndexPath?;
    private var currentHeader: ExpandableHeaderView?;
    
    private var data: [VertretungsplanForDate] {
        get {
            if let vertretungsplan_ = vertretungsplan {
                return vertretungsplan_.vertretungsplaene;
            }
            return [];
        }
        
        set(newValue) {
            if (vertretungsplan != nil) {
                vertretungsplan!.vertretungsplaene = newValue;
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged);
        
        if AppDefaults.authenticated {
            getVertretungsplanFromWeb();
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);

        if !AppDefaults.authenticated {
            tableView.isUserInteractionEnabled = false;
            tableView.reloadData();
        } else {
            tableView.isUserInteractionEnabled = true;
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vertretungsplanDetailViewController = segue.destination as? VertretungsplanDetailViewController, let selected = self.selected {
            vertretungsplanDetailViewController.gradeItem = data[selected.section - 2].gradeItems[selected.row];
            vertretungsplanDetailViewController.date = data[selected.section - 2].date;
        }
    }
    
    /*
     * ===============================================================
     *                            Refresh
     * ===============================================================
     */

    func doUpdate(with vertretungsplan: Vertretungsplan?, online: Bool) {
        if (vertretungsplan == nil) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Vertretungsplan", message: "Die Daten konnten leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert);
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true);
                }));
                self.present(alert, animated: true, completion: nil);
            }
        } else {
            self.vertretungsplan = vertretungsplan;
            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
        }
    }
    
    private func getVertretungsplanFromWeb() {
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: nil);
        
        // Clear all data and reload.
        currentHeader = nil;
        selected = nil;
        vertretungsplanLoader.load(self.doUpdate);        
    }

    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        guard AppDefaults.authenticated else {
            sender.endRefreshing();
            return;
        }

        getVertretungsplanFromWeb();
        sender.endRefreshing()
    }

    /*
     * ===============================================================
     *                      Table View
     * ===============================================================
     */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard AppDefaults.authenticated else { return 1; }
        return (data.count == 0) ? 0 : data.count + 2;
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selected = indexPath;
        return indexPath;
    }
    
    // Returns number of rows in section. The first two sections are fix and have one row only
    // for all following sections the number of grade items defines the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard AppDefaults.authenticated else { return 1; }
        return (section < 2) ? 1 : data[section - 2].gradeItems.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard AppDefaults.authenticated else { return tableView.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!;  }
        
        switch(indexPath.section) {
        case 0: return 128; // 85 (Cell height) + 42 (Page Control + Spacing) + 1
        case 1: return UITableView.automaticDimension;
        default: return (data[indexPath.section - 2].expanded) ? UITableView.automaticDimension : 0;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch(section) {
        case 0: return 0;
        case 1: return 0;
        default: return 44;
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (section < 2) ? 0 : 2;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section < 2) {
            return UITableViewHeaderFooterView();
        } else {
            let header = ExpandableHeaderView();
            header.customInit(userInteractionEnabled: data[section - 2].gradeItems.count > 0, section: section, delegate: self);
            return header;
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section < 2) ? "" : data[section - 2].date;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard AppDefaults.authenticated else { return tableView.dequeueReusableCell(withIdentifier: "notLoggedIn")!; }
        
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "metaDataCell") as! MetaDataTableViewCell;
            cell.setContent(tickerText: StringHelper.replaceHtmlEntities(input: vertretungsplan?.tickerText), additionalText: StringHelper.replaceHtmlEntities(input: vertretungsplan?.additionalText))
            return cell;
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "lastUpdateCell")!;
            cell.textLabel?.text = vertretungsplan?.lastUpdate;
            cell.detailTextLabel?.text = "Letzte Aktualisierung";
            return cell;
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!;
            cell.textLabel?.text = data[indexPath.section - 2].gradeItems[indexPath.row].grade;
            return cell;
        }
    }
    
    // Toggles section headers. If a new header is expanded the previous one when different
    // from the current one is collapsed.
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        guard section >= 2 else { return }
        
        // If another than the current section is selected hide the current
        // section.
        if currentHeader != nil && currentHeader != header {
            if let currentSection = currentHeader?.section, currentSection >= 2 {
                data[currentSection - 2].expanded = false;
                
                tableView.beginUpdates();
                for i in 0 ..< data[currentSection - 2].gradeItems.count {
                    tableView.reloadRows(at: [IndexPath(row: i, section: currentSection)], with: .automatic)
                }
                tableView.endUpdates();
            }
        }

        // Expand/collapse the selected header depending on it's current state.
        currentHeader = header;
        data[section - 2].expanded = !data[section - 2].expanded;
        
        tableView.beginUpdates();
        for i in 0 ..< data[section - 2].gradeItems.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates();
    }
}
