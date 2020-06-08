//
//  StaffPopoverViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 05.06.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Configures the staff popover view and implements container class for
 * label outlets. Use setContent() and setSourceView() to set content
 * and view popover shall be shown for.
 */
class StaffPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectsLabel: UILabel!
    
    private var name: String = ""
    private var subjects: [String] = []
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
    }
    
    func setContent(_ name: String, _ subjects: [String]) {
        self.name = name
        self.subjects = subjects
    }
    
    func setSourceView(view: UIView, rect: CGRect, permittedArrowDirections: UIPopoverArrowDirection = .down) {
        popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        popoverPresentationController?.sourceView = view
        popoverPresentationController?.sourceRect = rect
    }

    override func viewDidLoad() {
        nameLabel.text = name
        subjectsLabel.text = subjects.joined(separator: ", ")
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

/**
 * Controller class which shows staff info popover. The class is instantiated
 * with shortCutName and view popover is requested for. Call present(inViewController)
 * to bring popover to display. Lookup of shortcut and creation of popover is
 * fully handled. If for any reason no info is available popover silently isn't
 * shown.
 */
class StaffInfoPopoverController: NSObject {
    private var shortCutName: String?
    private var view: UIView
    private var permittedArrowDirections: UIPopoverArrowDirection
    private var feedbackGenerator: UINotificationFeedbackGenerator

    required init(withShortcutName shortCutName: String?, onView view: UIView, permittedArrowDirections: UIPopoverArrowDirection = .down) {
        self.shortCutName = shortCutName
        self.view = view
        self.permittedArrowDirections = permittedArrowDirections
        self.feedbackGenerator = UINotificationFeedbackGenerator()
        self.feedbackGenerator.prepare()
    }
    
    func present(inViewController viewController: UIViewController?) {
        // No shortcut set, do not show popup.
        guard let shortCutName = shortCutName else { return }

        // Lookup substitution. If it cannot be resolved popup is not
        // shown.
        let staffLoader = StaffLoader()
        let staffDictionary = staffLoader.loadFromCache()
        guard let staffMember = staffDictionary[shortCutName] else { return }

        let popoverController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShortcutNamePopover") as! StaffPopoverViewController
        let rect = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: 12, height: view.bounds.height)

        // Present popover in current view controller. Then update content.
        popoverController.setSourceView(view: view, rect: rect, permittedArrowDirections: permittedArrowDirections)
        popoverController.setContent(staffMember.name, staffMember.subjects)
        feedbackGenerator.notificationOccurred(.success)
        viewController?.present(popoverController, animated: true, completion: nil)
    }
}
