//
//  VertretungsplanDetailViewController.swift
//  Pius-App
//
//  Created by Michael on 16.03.18.
//  Copyright © 2018-2021 Felix Krings. All rights reserved.
//

import UIKit

/// Substitution details for a given grade.
class VertretungsplanDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
        
    public var gradeItem: GradeItem?
    public var date: String?
    
    /// When view was loaded required initialisations are run here.
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = date

        detailsTableView.delegate = self
        detailsTableView.dataSource = self
    }
    
    /// Returns number of rows in table view.
    /// - Parameters:
    ///   - tableView: The table view in view controller.
    ///   - section: Section for which number of rows is wanted (ignored)
    /// - Returns: Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gradeItem?.vertretungsplanItems.count ?? 0
    }
    
    /// Return tablew view cell for given row in section.
    /// - Parameters:
    ///   - tableView: The table view in view controller
    ///   - indexPath: Position of row
    /// - Returns: Table view cell for position
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell") as? DetailsTableViewCell
        if let cell = cell,
           let item = gradeItem?.vertretungsplanItems[indexPath.row] {
            
            cell.containingViewController = self
            
            let grade = StringHelper.replaceHtmlEntities(input: item[2]) ?? ""
            
            if grade != "" {
                cell.course = String(format: "Fach/Kurs: %@, %@. Stunde", grade, item[0])
            } else {
                cell.course = String(format: "%@. Stunde", item[0])
            }
            
            cell.type = StringHelper.replaceHtmlEntities(input: item[1])
            cell.room = FormatHelper.roomText(
                room: StringHelper.replaceHtmlEntities(input: item[3])
            )
            cell.teacher = StringHelper.replaceHtmlEntities(input: item[4])
            cell.comment = StringHelper.replaceHtmlEntities(input: item[6])
            
            var eva: String?
            if item.count == 8 {
                eva = StringHelper.replaceHtmlEntities(input: item[7])
            }
            
            cell.eva = eva
        }

        return cell ?? UITableViewCell()
    }
    
}
