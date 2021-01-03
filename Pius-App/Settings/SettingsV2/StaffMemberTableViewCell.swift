//
//  StaffTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 29.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

/// Base class for staff member table view. This calls implements
/// actual logic. It receives outlets from sub-class awakeFromNib()
/// call.
class StaffMemberBaseTableViewCell: UITableViewCell {

    weak var shorthandSymbolView: UITextView?
    weak var nameView: UITextView?
    weak var subjectsView: UITextView?
    weak var emailView: UITextView?

    /// Initialise table view cell data from staff member.
    /// - Parameters:
    ///   - shorthandSymbol: Shorthand symbol for member
    ///   - staffMember: Staff object for member
    func customInit(_ shorthandSymbol: String, with staffMember: StaffMember) {
        shorthandSymbolView?.text = shorthandSymbol
        nameView?.text = staffMember.name
        subjectsView?.text = staffMember.subjectsList
        
        if let email = staffMember.email {
            emailView?.text = email
            emailView?.isHidden = false
        } else {
            emailView?.text = nil
            emailView?.isHidden = true
        }
    }
}

/// Model for unfiltered staff view.
class StaffMemberTableViewCell: StaffMemberBaseTableViewCell {

    @IBOutlet weak var shorthandSymbolOutlet: UITextView!
    @IBOutlet weak var nameOutlet: UITextView!
    @IBOutlet weak var subjectsOutlet: UITextView!
    @IBOutlet weak var emailOutlet: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shorthandSymbolView = shorthandSymbolOutlet
        nameView = nameOutlet
        subjectsView = subjectsOutlet
        emailView = emailOutlet
    }
}

/// Model for filtered staff view.
class StaffMemberSearchTableViewCell: StaffMemberBaseTableViewCell {

    @IBOutlet weak var shorthandSymbolOutlet: UITextView!
    @IBOutlet weak var nameOutlet: UITextView!
    @IBOutlet weak var subjectsOutlet: UITextView!
    @IBOutlet weak var emailOutlet: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        shorthandSymbolView = shorthandSymbolOutlet
        nameView = nameOutlet
        subjectsView = subjectsOutlet
        emailView = emailOutlet
    }
}
