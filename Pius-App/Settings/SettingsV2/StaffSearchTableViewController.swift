//
//  StaffSearchTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 03.01.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

/// Displays staff search result for settings staff page.
class StaffSearchTableViewController: UITableViewController {
    
    private var staffDictionary: StaffDictionary?
    private var staffKeys: [String]?
    
    var filteredStaffDictionary: StaffDictionary? {
        set(value) {
            staffDictionary = value
            staffKeys = staffDictionary?.sortdedKeys
        }
        get { staffDictionary }
    }
    
    /// Returns number of rows in section.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - section: Section number
    /// - Returns: Number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStaffDictionary?.count ?? 0
    }
    
    /// Returns table view cell for index path.
    /// - Parameters:
    ///   - tableView: Table view
    ///   - indexPath: Index path
    /// - Returns: Table view cell to show at index path
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "staffMember", for: indexPath) as! StaffMemberSearchTableViewCell

        if let shorthandSymbol = staffKeys?[indexPath.row],
           let staffMember = staffDictionary?[shorthandSymbol] {
            cell.customInit(shorthandSymbol, with: staffMember)
        }
        
        return cell
    }
}
