//
//  DashboardDetailsTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 08.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

class DashboardDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var evaLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var course: String? {
        set { courseLabel.text = newValue }
        get { courseLabel.text }
    }
    
}
