//
//  NewsCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayItemCell: UITableViewCell {
    func layoutIfNeeded(forFrameView view: UIView) {
        super.layoutIfNeeded()
        view.layer.borderColor = Config.colorPiusBlue.cgColor
        view.layer.borderWidth = 1.5
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = false;
    }
}

class NewsCell: TodayItemCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func layoutIfNeeded() {
        layoutIfNeeded(forFrameView: view)
    }
}

class CalendarCell: TodayItemCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func layoutIfNeeded() {
        layoutIfNeeded(forFrameView: view)
        // messageLabel.isHidden
    }
}
