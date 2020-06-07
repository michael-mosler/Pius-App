//
//  VertretungsplanDetailsCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 31.10.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Presents details of a substitution in Dashboard view. The class
 * has properties for substitution type, room and teacher. It installs
 * a tap gesture for teacher which shows a popup with teacher's name
 * and subjects.
 */
class VertretungsplanDetailsCell: UITableViewCell, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var substitutionLabel: UILabel!
    
    private var substitution: String?
    
    var viewController: UIViewController?
    
    func setContent(type: NSAttributedString, room: NSAttributedString, substitution: NSAttributedString) {
        self.substitution = substitution.string.trimmingCharacters(in: .whitespaces)
        typeLabel.attributedText = type;
        roomLabel.attributedText = room;
        substitutionLabel.attributedText = substitution;
        
        substitutionLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressSelector)))
    }
    
    /**
     * When user taps on teacher label this action method shows info popup
     * for teacher.
     */
    @objc func longPressSelector(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        let staffInfoPopoverController = StaffInfoPopoverController(withShortcutName: substitution, onView: substitutionLabel, permittedArrowDirections: .any)
        staffInfoPopoverController.present(inViewController: viewController)
    }
}
