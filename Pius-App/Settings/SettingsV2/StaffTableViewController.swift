//
//  StaffTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 28.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class StaffTableViewController: UITableViewController, ExpandableHeaderViewDelegate {
    private var staffDictionary: StaffDictionary = StaffDictionary()
    private var teacherDictionary: StaffDictionary = StaffDictionary()
    private var teacherKeys: [String] = []
    private var nonTeacherDictionary: StaffDictionary = StaffDictionary()
    private var nonTeacherKeys: [String] = []
    
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
        var sections = 0
        
        if teacherDictionary.count > 0 {
            sections += 1
        }
        
        if nonTeacherDictionary.count > 0 {
            sections += 1
        }

        return sections
    }
    
    /// Returns number of rows in section.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - section: Section for which number of rows is requested
    /// - Returns: Number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return teacherDictionary.count
        case 1:
            return nonTeacherDictionary.count
        default:
            return 0
        }
    }
    
    /// Return section header view. Here we use ExpandableHeaderView as section header.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - section: Section which header is needed for
    /// - Returns: Header view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        var enabled: Bool
        
        switch section {
        case 0:
            enabled = teacherDictionary.count > 0
        case 1:
            enabled = nonTeacherDictionary.count > 0
        default:
            enabled = false
        }
        
        header.customInit(
            userInteractionEnabled: enabled,
            section: section,
            delegate: self)
        return header
    }

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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
        if scrollView.contentOffset.y <= 0 {
            self.navigationItem.largeTitleDisplayMode = .always
        } else {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        self.navigationController?.navigationBar.setNeedsLayout()
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0.25, animations: {
            self.navigationController?.navigationBar.layoutIfNeeded()
            self.view.layoutIfNeeded()
        })
        */
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        return
    }
}
