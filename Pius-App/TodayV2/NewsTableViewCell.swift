//
//  NewsTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit
import Kingfisher

/*
 * A single news item table cell that is filled from a single
 * news item. Cell cares about setting of news text and image.
 */
class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsTextLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    
    private var _newsItem: NewsItem?
    
    var newsItem: NewsItem? {
        set(value) {
            _newsItem = value
            
            let itemText = NSMutableAttributedString(string: "")
            if let heading = value?.heading {
                let headingFont = UIFont.systemFont(ofSize: 15, weight: .bold)
                itemText.append(NSAttributedString(string: heading, attributes: [NSAttributedString.Key.font: headingFont]))
                itemText.append(NSAttributedString(string: "\n"))
            }
            itemText.append(NSAttributedString(string: value?.text ?? ""))
            newsTextLabel.attributedText = itemText

            if let imageUrl = value?.imgUrl {
                newsImageView.kf.setImage(with: URL(string: imageUrl))
            }
        }
        
        get {
            return _newsItem
        }
    }
    
    var href: String? {
        return newsItem?.href
    }
}

/*
 * Calendar item cell. This cell shows event text only as being used in
 * Today view. In this context date of an event should be clear.
 */
class CalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var calendarTextLabel: UILabel!
    
    var event: String? {
        set(value) {
            calendarTextLabel.text = value
        }
        get {
            return calendarTextLabel.text
        }
    }
}
