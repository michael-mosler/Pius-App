//
//  NewFunctionOnboardingViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 07.06.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Implements an instance of a New Function Help popover. This can be used
 * to explain new functions with small popovers.
 * By tracking display in hasShownHelpProperty the same instance of a
 * popover can be attached multiple times. After it has been shown once
 * it then will be not be displayed a second time.
 */
class NewFunctionOnboardingViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    let functionHelpCategory = "staffPopover"
    var _hasShownHelp: Bool = false
    var hasShownHelp: Bool {
        set {
            var hasShownFunctionHelp = AppDefaults.hasShownFunctionHelp
            hasShownFunctionHelp[functionHelpCategory] = newValue
            AppDefaults.hasShownFunctionHelp = hasShownFunctionHelp
            _hasShownHelp = newValue
        }
        get { (AppDefaults.hasShownFunctionHelp[functionHelpCategory] ?? false) && (!Config.alwaysShowOnboarding || _hasShownHelp) }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
    }

    func setSourceView(view: UIView) {
        popoverPresentationController?.permittedArrowDirections = .any
        popoverPresentationController?.canOverlapSourceViewRect = true
        popoverPresentationController?.sourceView = view
        popoverPresentationController?.sourceRect = view.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
