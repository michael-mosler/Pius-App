//
//  DashboardDetailsTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 08.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

/// Substitution item details table view cell for
/// common schedule details view.
class DetailsTableViewCell: SubstitutionDetailsTableViewCell {
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var evaLabel: UILabel!

    /// Called when cell has been instantiated. Performs common
    /// initialisations.
    override func awakeFromNib() {
        courseLabelOutlet = courseLabel
        typeLabelOutlet = typeLabel
        roomLabelOutlet = roomLabel
        teacherLabelOutlet = teacherLabel
        commentLabelOutlet = commentLabel
        evaLabelOutlet = evaLabel
        super.awakeFromNib()
    }

}
