//
//  MetaDataCollectionViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 24.10.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class MetaDataCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var metaDataTextView: UITextView!
    @IBOutlet weak var textViewWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        let screenWidth = UIScreen.main.bounds.width;
        textViewWidthConstraint.constant = screenWidth - 2 * 16;        
    }
}
