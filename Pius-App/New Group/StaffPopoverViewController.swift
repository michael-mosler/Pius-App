//
//  StaffPopoverViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 05.06.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class StaffPopoverViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subjectsLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .popover
        popoverPresentationController?.permittedArrowDirections = .down
        popoverPresentationController?.delegate = self
    }
    
    func setContent(_ name: String, _ subjects: [String]) {
        nameLabel.text = name
        subjectsLabel.text = subjects.joined(separator: ", ")
    }
    
    func setSourceView(view: UIView, rect: CGRect? = nil) {
        let rect = rect ?? CGRect(x: view.bounds.minX, y: view.bounds.minY, width: 12, height: view.bounds.height)
        popoverPresentationController?.sourceView = view
        popoverPresentationController?.sourceRect = rect
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
