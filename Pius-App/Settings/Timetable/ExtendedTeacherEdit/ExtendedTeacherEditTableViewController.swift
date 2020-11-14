//
//  ExtendedTeacherEditTableTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 26.09.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class ExtendedTeacherEditTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    private let searchController: UISearchController
    private let staffDictionary: StaffDictionary
    private var filteredStaffDictionary: StaffDictionary
    private var sortedKeys: [String]
    
    var resultDelegate: CourseDetailsViewController?

    /**
     * Constructor function: It ensures that popover properties are set correctly
     * before view controller is displayed.
     */
    required init?(coder: NSCoder) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false

        let staffLoader = StaffLoader();
        staffDictionary = staffLoader.loadFromCache()
        filteredStaffDictionary = staffDictionary
        sortedKeys = filteredStaffDictionary.sortdedKeys

        super.init(coder: coder)

        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
    }

    /**
     * When view is loaded adds search bar to table view and loads staff
     * dictionary from cache.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.isActive = true
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }

    /**
     * Returns the number of sections in table view. In this it is 1.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     * Returns the number of rows to show in table view.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStaffDictionary.count
    }

    /**
     * Returns table view cell for the given index path and section. The cell holds teacher shortname,
     * name and subject list.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "teacherCell", for: indexPath) as? ExtendedTeacherTableViewCell,
              indexPath.row < sortedKeys.count
        else { return UITableViewCell() }

        let shortname = sortedKeys[indexPath.row]
        cell.shortname = shortname
        cell.staffMember = filteredStaffDictionary[shortname]
        return cell
    }

    /**
     * When user selects a row this row is returned to lesson detail editor
     * and popover is dismissed.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ExtendedTeacherTableViewCell else { return }
        
        resultDelegate?.receiveResult(selectedShortname: cell.shortname)
        searchController.isActive = false
        dismiss(animated: true, completion: nil)
    }
    
    /**
     * Return style for popover as .none
     */
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    /**
     * Update tableview content when user types in search bar.
     */
    func updateSearchResults(for searchController: UISearchController) {
        filteredStaffDictionary = staffDictionary.filter(by: searchController.searchBar.text)
        sortedKeys = filteredStaffDictionary.sortdedKeys
        tableView.reloadData()
    }

    /**
     * Sets the source view on which this popover is displayed.
     */
    func setSourceView(view: UIView, rect: CGRect) {
        popoverPresentationController?.permittedArrowDirections = .any
        popoverPresentationController?.sourceView = view
        popoverPresentationController?.sourceRect = rect
    }
}
