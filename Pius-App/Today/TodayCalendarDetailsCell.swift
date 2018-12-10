//
//  TodayCalendarDetailsCellTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 08.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayCalendarDetailsCell: UITableViewCell {
    @IBOutlet weak var eventItemLabel: UILabel!

    func setContent(event: String) {
        eventItemLabel.text = event;
    }
}
