//
//  SubstitutionTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 02.05.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

/// Substitution item details table view cell.
class SubstitutionDetailsTableViewCell: UITableViewCell {
    
    var containingViewController: UIViewController?

    weak var courseLabelOutlet: UILabel!
    weak var typeLabelOutlet: UILabel!
    weak var roomLabelOutlet: UILabel!
    weak var teacherLabelOutlet: UILabel!
    weak var commentLabelOutlet: UILabel!
    weak var evaLabelOutlet: UILabel!

    var course: String? {
        set { courseLabelOutlet.text = newValue }
        get { courseLabelOutlet.text }
    }

    var type: String? {
        set { typeLabelOutlet.text = newValue }
        get { typeLabelOutlet.text }
    }
    
    var room: NSAttributedString? {
        set { roomLabelOutlet.attributedText = newValue }
        get { roomLabelOutlet.attributedText }
    }

    var teacher: String? {
        set { teacherLabelOutlet.text = newValue }
        get { teacherLabelOutlet.text }
    }

    var comment: String? {
        set { commentLabelOutlet.text = newValue }
        get { commentLabelOutlet.text }
    }
    
    var eva: String? {
        set { evaLabelOutlet.text = newValue }
        get { evaLabelOutlet.text }
    }
    
    /// Called when cell has been instantiated. Performs common
    /// initialisations.
    override func awakeFromNib() {
        teacherLabelOutlet.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressSelector)))
    }

    /// When user taps on teacher label this action method shows info popup
    /// for teacher.
    ///- Parameter gestureRecognizer: Gesture recognizer that had triggered event
    @objc func longPressSelector(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began,
            let shortCutName = teacher?.trimmingCharacters(in: .whitespaces)
        else { return }
        
        let staffInfoPopoverController = StaffInfoPopoverController(
            withShortcutName: shortCutName,
            onView: teacherLabelOutlet,
            permittedArrowDirections: .any)
        staffInfoPopoverController.present(inViewController: containingViewController)
    }

}
