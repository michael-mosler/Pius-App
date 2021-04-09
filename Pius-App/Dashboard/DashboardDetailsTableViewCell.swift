//
//  DashboardDetailsTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 08.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

/// Substitution item details table view cell.
class DetailsTableViewCell: UITableViewCell {
    
    var containingViewController: UIViewController?

    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var evaLabel: UILabel!
    
    var course: String? {
        set { courseLabel.text = newValue }
        get { courseLabel.text }
    }

    var type: String? {
        set { typeLabel.text = newValue }
        get { typeLabel.text }
    }
    
    var room: NSAttributedString? {
        set { roomLabel.attributedText = newValue }
        get { roomLabel.attributedText }
    }

    var teacher: String? {
        set { teacherLabel.text = newValue }
        get { teacherLabel.text }
    }

    var comment: String? {
        set { commentLabel.text = newValue }
        get { commentLabel.text }
    }
    
    var eva: String? {
        set { evaLabel.text = newValue }
        get { evaLabel.text }
    }
    
    /// Called when cell has been instantiated. Performs common
    /// initialisations.
    override func awakeFromNib() {
        teacherLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressSelector)))
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
            onView: teacherLabel,
            permittedArrowDirections: .any)
        staffInfoPopoverController.present(inViewController: containingViewController)
    }

}
