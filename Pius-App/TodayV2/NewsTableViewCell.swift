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

class PostingsTableViewCell: UITableViewCell {
    @IBOutlet weak var postingsTextLabel: UILabel!
    @IBOutlet weak var postingsDateLabel: UILabel!
    private var _item: PostingsItem?
    
    var item: PostingsItem? {
        set(value) {
            _item = value
            if let item = _item {
                let data = Data(item.message.utf8)
                if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil) {
                    postingsTextLabel.attributedText = attributedString
                } else {
                    postingsTextLabel.attributedText = NSAttributedString(string: item.message)
                }
                postingsDateLabel.text = DateHelper.formatIsoUTCDate(date: item.timestamp)
            } else {
                postingsTextLabel.attributedText = nil
                postingsDateLabel.text = nil
            }
        }
        get {
            return _item
        }
    }
}

class DashboardTableViewCell: UITableViewCell {
    @IBOutlet weak var courseTextLabel: UILabel!
    @IBOutlet weak var typeTextLabel: UILabel!
    @IBOutlet weak var roomTextLabel: UILabel!
    @IBOutlet weak var substitutionTextLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var evaTextLabel: UILabel!
    
    var _items: DetailItems?
    
    var item: DetailItems? {
        set(value) {
            _items = value
            if let items = _items {
                var text: String
                
                // 1. Course
                let lesson: String = items[0].trimmingCharacters(in: CharacterSet(charactersIn: " "))
                let course: String = StringHelper.replaceHtmlEntities(input: items[2])
                text = (course != "") ? String(format: "Fach/Kurs: %@, %@. Stunde", course, lesson) : String(format: "%@. Stunde", lesson)
                courseTextLabel.attributedText = NSAttributedString(string: text)
                
                // 2. Type
                typeTextLabel.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: items[1]))
                
                // 3. Room
                roomTextLabel.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: items[3]))
                
                // 4, Teacher
                substitutionTextLabel.attributedText = NSAttributedString(string:  StringHelper.replaceHtmlEntities(input: items[4]))
                
                // 5. Comment
                text = StringHelper.replaceHtmlEntities(input: items[6])
                if text.count > 0 {
                    commentTextLabel.attributedText = NSAttributedString(string: text)
                } else {
                    commentTextLabel.attributedText = nil
                }
                
                // 6. EVA
                if items.count >= 8 {
                    text = StringHelper.replaceHtmlEntities(input: items[6])
                    evaTextLabel.attributedText = NSAttributedString(string: text)
                } else {
                    evaTextLabel.attributedText = nil
                }
            } else {
                courseTextLabel.attributedText = nil
                typeTextLabel.attributedText = nil
                roomTextLabel.attributedText = nil
                substitutionTextLabel.attributedText = nil
                evaTextLabel.attributedText = nil
            }
        }
        get {
            return _items
        }
    }
}
