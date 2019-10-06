//
//  TodayHeaderCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

/*
 * Today View header cell. This cell shows current date and week type (A/B)
 * and the static text "Heute".
 */
class TodayHeaderCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    
    let defaultSystemFont = UIFont.systemFont(ofSize: 14);
    let largeTitleFont = UIFont.systemFont(ofSize: 36, weight: .bold);
    let dateFormatter = DateFormatter();

    override func awakeFromNib() {
        super.awakeFromNib()

        let date = Date();
        
        dateFormatter.locale = Locale(identifier: "de_DE");
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, d. MMMM");
        let dateString = NSMutableAttributedString(string: dateFormatter.string(from: date) + " (" + DateHelper.week() + "-Woche)", attributes: [NSAttributedString.Key.font: defaultSystemFont]);
        let todayString = NSMutableAttributedString(string: "Heute", attributes: [NSAttributedString.Key.font: largeTitleFont]);
        dateString.append(NSMutableAttributedString(string: "\n"));
        dateString.append(todayString);
        headerLabel.attributedText = dateString;
    }
}
