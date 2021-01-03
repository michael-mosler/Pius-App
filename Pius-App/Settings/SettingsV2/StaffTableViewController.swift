//
//  StaffTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 28.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class StaffTableViewController: UITableViewController, ExpandableHeaderViewDelegate, EmbeddedSettingsViewController {

    private(set) var searchController: UISearchController?
    private var staffDictionary: StaffDictionary = StaffDictionary()
    private var teacherDictionary: StaffDictionary = StaffDictionary()
    private var teacherKeys: [String] = []
    private var nonTeacherDictionary: StaffDictionary = StaffDictionary()
    private var nonTeacherKeys: [String] = []
    
    private lazy var sectionHeaders: [ExpandableHeaderView] = {
        return [
            ExpandableHeaderView(),
            ExpandableHeaderView()
        ]
    }()
    
    /// Retutns number of rows in given section.
    /// - Parameter section: Section number
    /// - Returns: Nunber of rows in section
    private func numberOfRowsInSection(_ section: Int) -> Int {
        switch section {
        case 0:
            return teacherDictionary.count
        case 1:
            return nonTeacherDictionary.count
        default:
            return 0
        }
    }
    
    /// Required constructor initializes search control.
    /// - Parameter coder: Coder
    required init?(coder: NSCoder) {
        let searchViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StaffSeachResult")
        searchController = UISearchController(searchResultsController: searchViewController)
        searchController?.obscuresBackgroundDuringPresentation = false

        super.init(coder: coder)

        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
    }
    
    /// Initialize all values that cannot be initialized in constructor.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let staffLoader = StaffLoader()
        staffDictionary = staffLoader.loadFromCache()
        
        teacherDictionary = staffDictionary.filter(isTeacher: true)
        teacherKeys = teacherDictionary.sortdedKeys
        
        nonTeacherDictionary = staffDictionary.filter(isTeacher: false)
        nonTeacherKeys = nonTeacherDictionary.sortdedKeys
    }
    
    /// Returns the number of sections to show.
    /// - Parameter tableView: Table view
    /// - Returns: Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /// Returns number of rows in section.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - section: Section for which number of rows is requested
    /// - Returns: Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < 2, sectionHeaders[section].expanded else { return 0 }
        return numberOfRowsInSection(section)
    }
    
    /// Return section header view. Here we use ExpandableHeaderView as section header.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - section: Section which header is needed for
    /// - Returns: Header view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < 2 else { return ExpandableHeaderView() }
        
        let header = sectionHeaders[section]
        let enabled = numberOfRowsInSection(section) > 0
                
        header.customInit(
            userInteractionEnabled: enabled,
            section: section,
            delegate: self)
        return header
    }
    
    /// Returns height for section footer. This adds some space between
    /// section headers
    /// - Parameters:
    ///   - tableView: Table view
    ///   - section: Section number
    /// - Returns: Height for section footer
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section < 2 ? 2 : 0
    }

    /// Return title for section.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - section: Section which title is needed for
    /// - Returns: Section title
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Lehrer"
        case 1:
            return "Betreuung"
        default:
            return nil
        }
    }
    
    /// Tables data source function; returns rows for each section.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - indexPath: Address of the row fow which a cell must be returned.
    /// - Returns: Table view cell to use at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "staffMember", for: indexPath) as! StaffMemberTableViewCell
        var shorthandSymbol: String
        var staffMember: StaffMember?

        switch indexPath.section {
        case 0:
            shorthandSymbol = teacherKeys[indexPath.row]
            staffMember = teacherDictionary[shorthandSymbol]
            
        case 1:
            shorthandSymbol = nonTeacherKeys[indexPath.row]
            staffMember = nonTeacherDictionary[shorthandSymbol]
        default:
            shorthandSymbol = ""
            staffMember = nil
        }
        
        if let staffMember = staffMember {
            cell.customInit(shorthandSymbol, with: staffMember)
        }
        
        return cell
    }
    
    /// Toggles expansion of a given section.
    /// - Parameters:
    ///   - header: Header view for section
    ///   - section: Section to toggle
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
     }
}

extension StaffTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    /// Update search result when user types into search field.
    /// - Parameter searchController: Search controller
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchViewController = searchController.searchResultsController as? StaffSearchTableViewController else { return }
        
        let searchText = searchController.searchBar.text
        let filteredResult = staffDictionary.filter(by: searchText)
        
        searchViewController.filteredStaffDictionary = filteredResult
        searchViewController.tableView.reloadData()
    }
}
