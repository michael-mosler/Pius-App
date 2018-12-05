//
//  VertretungsplanDetailsCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 31.10.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class VertretungsplanDetailsCell: UITableViewCell {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var substitutionLabel: UILabel!
    
    func setContent(type: NSAttributedString, room: NSAttributedString, substitution: NSAttributedString) {
        typeLabel.attributedText = type;
        roomLabel.attributedText = room;
        substitutionLabel.attributedText = substitution;
    }
}
