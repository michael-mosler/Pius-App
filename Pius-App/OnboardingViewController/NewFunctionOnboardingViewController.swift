//
//  NewFunctionOnboardingViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 07.06.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class NewFunctionOnboardingViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var hasShownHelp: Bool = false

    @IBAction func ButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .popover
        popoverPresentationController?.delegate = self
    }

    func setSourceView(view: UIView) {
        popoverPresentationController?.permittedArrowDirections = .any
        popoverPresentationController?.sourceView = view
        popoverPresentationController?.sourceRect = view.bounds
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
