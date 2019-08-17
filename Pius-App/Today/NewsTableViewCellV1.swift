//
//  NewTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 27.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import Kingfisher

class NewsTableViewCellV1: UITableViewCell {
    @IBOutlet weak var newsItemImageView: UIImageView!
    @IBOutlet weak var newsItemTextLabel: UILabel!

    var href: String?;
    
    // Sets image URL and loads images in background.
    func setImageUrl(imgUrl: String?) {
        guard let imgUrl = imgUrl else { return; }
        
        let url = URL(string: imgUrl);
        self.newsItemImageView.kf.setImage(with: url);
    }
}
