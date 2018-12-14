//
//  TodayPostingsDetailsCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 09.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayPostingsDetailsCell: UITableViewCell {
    @IBOutlet weak var postingLabel: UILabel!
    @IBOutlet weak var postingSubtitle: UILabel!
    
    func setContent(message: String, date: String) {
        let data = Data(message.utf8);
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil) {
            postingLabel.attributedText = attributedString;
        } else {
            postingLabel.attributedText = NSAttributedString(string: message);
        }
        postingSubtitle.text = date;
    }
}
