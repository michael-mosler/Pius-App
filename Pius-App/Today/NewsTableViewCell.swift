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
    
    // Sets image URL and loads images in background.
    func setImageUrl(imgUrl: String?) {
        guard let imgUrl = imgUrl else { return; }
        
        let url = URL(string: imgUrl);
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf : url!);
                let image = UIImage(data: data);
                
                DispatchQueue.main.async {
                    self.newsItemImageView.image = image;
                }
            }
            catch {
                print("Failed to load image from \(imgUrl)");
            }
        }
    }
}
