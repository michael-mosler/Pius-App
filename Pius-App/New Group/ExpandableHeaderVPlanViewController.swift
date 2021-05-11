//
//  ExpandableHeaderTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 11.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

/// This base class can be used to implement substitution schedule views which
/// make use of expandable headers.
class ExpandableHeaderVPlanViewController: UITableViewController {
    
    var vertretungsplan: Vertretungsplan?

    var data: [VertretungsplanForDate] {
        get {
            guard let vertretungsplan_ = vertretungsplan else { return [] }
            return vertretungsplan_.vertretungsplaene
        }
        
        set {
            if vertretungsplan != nil {
                vertretungsplan!.vertretungsplaene = newValue
            }
        }
    }
    
    /// Load vplan data.
    /// - Parameters:
    ///   - grade: If given load data for this grade otherwise load full plan data.
    ///   - onLoadDelegate: Delegate which will process data on receive
    func getVertretungsplanFromWeb(forGrade grade: String?, onLoadDelegate: VPlanLoaderDelegate) {
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: grade)
        vertretungsplanLoader.load(onLoadDelegate)
    }

    /// Toggles section headers. If a new header is expanded the previous one when different
    /// from the current one is collapsed.
    /// - Parameters:
    ///   - header: Selected header view
    ///   - section: Section of header
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        guard section >= 2 else { return }

        tableView.beginUpdates()
        for i in 2..<data.count + 2 {
            if i != section && data[i - 2].expanded {
                expandSection(i, with: false)
            }
        }

        expandSection(section, with: !data[section - 2].expanded)
        tableView.endUpdates()
    }
    
    /// Expands/collapses given section.
    /// - Parameters:
    ///   - section: Section to expand/collaps
    ///   - with: True indicated expand, false collapse
    private func expandSection(_ section: Int, with: Bool) {
        data[section - 2].expanded = with
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }

}
