//
//  NewTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 27.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    @IBOutlet weak var newsItemImageView: UIImageView!
    @IBOutlet weak var newsItemTextLabel: UILabel!
    
    var href: String?;    
}
