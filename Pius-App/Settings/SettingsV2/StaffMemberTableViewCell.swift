//
//  StaffTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 29.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class StaffMemberTableViewCell: UITableViewCell {
    @IBOutlet weak var shorthandSymbolView: UITextView!
    @IBOutlet weak var nameView: UITextView!
    @IBOutlet weak var subjectsView: UITextView!
    @IBOutlet weak var emailView: UITextView!
    
    func customInit(_ shorthandSymbol: String, with staffMember: StaffMember) {
        shorthandSymbolView.text = shorthandSymbol
        nameView.text = staffMember.name
        subjectsView.text = staffMember.subjectsList
        
        if let email = staffMember.email {
            emailView.text = email
            emailView.isHidden = false
        } else {
            emailView.text = nil
            emailView.isHidden = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
