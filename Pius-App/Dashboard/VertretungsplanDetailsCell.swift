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
        
        substitutionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureSelector)))
    }
    
    /**
     * When user taps on teacher label this action method shows info popup
     * for teacher.
     */
    @objc func tapGestureSelector(gestureRecognizer: UITapGestureRecognizer) {
        // No shortcut set, do not show popup.
        guard let substitution = substitution else { return }

        // Lookup substitution. If it cannot be resolved popup is not
        // shown.
        let staffLoader = StaffLoader()
        let staffDictionary = staffLoader.loadFromCache()
        guard let staffMember = staffDictionary[substitution] else { return }

        let popoverController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShortcutNamePopover") as! StaffPopoverViewController

        // Present popover in current view controller. Then update content.
        popoverController.setSourceView(view: substitutionLabel)
        viewController?.present(popoverController, animated: true, completion: nil)
        popoverController.setContent(staffMember.name, staffMember.subjects)
    }
}
