//
//  ExtendedTeacherTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 26.09.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class ExtendedTeacherTableViewCell: UITableViewCell {

    @IBOutlet weak var shortnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectsLabel: UILabel!

    private var shortname_: String?
    private var staffMember_: StaffMember?
    
    var shortname: String? {
        get { shortname_ }
        set {
            shortname_ = newValue
            shortnameLabel.text = shortname_
        }
    }
    
    var staffMember: StaffMember? {
        get { staffMember_ }
        set {
            staffMember_ = newValue
            nameLabel.text = staffMember_?.name
            subjectsLabel.text = staffMember_?.subjectsList
        }
    }
}
