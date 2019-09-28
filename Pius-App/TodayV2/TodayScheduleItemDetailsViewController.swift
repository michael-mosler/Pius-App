//
//  TodayScheduleItemDetailsViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 26.09.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayScheduleItemDetailsViewController: UIViewController {

    var delegate: ModalDismissDelegate?
    var segueData: Any?
    
    @IBOutlet weak var contentView: UIView!
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.hasDismissed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.borderColor = Config.colorPiusBlue.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = false;

    }
}
