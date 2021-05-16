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
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var subjectsTextView: UITextView!
    @IBOutlet weak var emailTextView: UITextView!

    var staffMember: StaffMember?
    
    var sourceView: UIView? {
        get { popoverPresentationController?.sourceView }
        set { popoverPresentationController?.sourceView = newValue }
    }
    
    var permittedArrowDirections: UIPopoverArrowDirection? {
        get { popoverPresentationController?.permittedArrowDirections }
        set { popoverPresentationController?.permittedArrowDirections =
            newValue ?? .any
        }
    }
    
    /// Standard constructor sets basic properties of view controller.
    /// - Parameter coder: Coder for view controller, we don't care.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
    }
    
    /// Copies staff member information to view when
    /// view has been loaded.
    override func viewDidLoad() {
        nameTextView.text = staffMember?.name
        subjectsTextView.text = staffMember?.subjectsList
        emailTextView.text = staffMember?.email
        emailTextView.isHidden = staffMember?.email == nil
    }
    
    /// When view will appear preferred content size
    /// is set to minimum aka compressed. By this
    /// popover will exactly fit content size.
    /// - Parameter animated: Popover will appear with animation when true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preferredContentSize = view.systemLayoutSizeFitting(
                UIView.layoutFittingCompressedSize)
    }
    
    /// Returns presentation style, .none in this case.
    /// - Parameter controller: Presentation controller
    /// - Returns: Always .none
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
    
    /// Constructor sets basic properties of controller instance.
    /// - Parameters:
    ///   - shortCutName: Teacher shortcut popover is shown for.
    ///   - view: View on which popover is presented
    ///   - permittedArrowDirections: Permitted popover arrow directions
    required init(
        withShortcutName shortCutName: String?, onView view: UIView,
        permittedArrowDirections: UIPopoverArrowDirection = .down)
    {
        self.shortCutName = shortCutName
        self.view = view
        self.permittedArrowDirections = permittedArrowDirections
        self.feedbackGenerator = UINotificationFeedbackGenerator()
        self.feedbackGenerator.prepare()
    }
    
    /// Present the given view controller as popover.
    /// - Parameter viewController: View controller to present as popover
    func present(inViewController viewController: UIViewController?) {
        // No shortcut set, do not show popup.
        guard let shortname = shortCutName else { return }

        // Lookup substitution. If it cannot be resolved popup is not
        // shown.
        let staffLoader = StaffLoader()
        let staffDictionary = staffLoader.loadFromCache()

        guard let staffMember = staffDictionary[shortname] else { return }

        let popoverController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ShortcutNamePopover")
            as! StaffPopoverViewController
        popoverController.staffMember = staffMember
        
        // Present popover in current view controller. Then update content.
        popoverController.sourceView = view
        popoverController.permittedArrowDirections = permittedArrowDirections

        feedbackGenerator.notificationOccurred(.success)
        viewController?.present(popoverController, animated: false, completion: nil)
    }
}
