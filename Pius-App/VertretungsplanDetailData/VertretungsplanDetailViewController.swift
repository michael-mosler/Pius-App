//
//  VertretungsplanDetailViewController.swift
//  Pius-App
//
//  Created by Michael on 16.03.18.
//  Copyright © 2018-2021 Felix Krings. All rights reserved.
//

import UIKit

/// Substitution details for a given grade.
class VertretungsplanDetailViewController:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate
{

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
