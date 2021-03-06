//
//  TodayTableViewCells.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit
import Kingfisher

/* *********************************************************************
 * A single news item table cell that is filled from a single
 * news item. Cell cares about setting of news text and image.
 * *********************************************************************/
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

/* *********************************************************************
 * Calendar item cell. This cell shows event text only as being used in
 * Today view. In this context date of an event should be clear.
 * *********************************************************************/
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

/* *********************************************************************
 * Postings item cell. This cell shows any kind of posting.
 * *********************************************************************/
class PostingsTableViewCell: UITableViewCell {
    @IBOutlet weak var postingsTextLabel: UITextView!
    @IBOutlet weak var postingsDateLabel: UILabel!
    private var _item: PostingsItem?
    
    var item: PostingsItem? {
        set(value) {
            _item = value
            if let item = _item {
                if let attributedMessage = item.attributedMessage {
                    postingsTextLabel.attributedText = attributedMessage
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
    
    override func layoutSubviews() {
        if #available(iOS 13.0, *) {
            postingsTextLabel.textColor = UIColor.label
        }
        super.layoutSubviews()

        // iOS adds padding to text view content. As this breaks our
        // layout we remove it.
        postingsTextLabel.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        postingsTextLabel.textContainer.lineFragmentPadding = 0
    }
}

/* ****************************************************************************
 * This cell shows dashboard items, aka the personalized substitution schedule
 * for today.
 * ****************************************************************************/
class DashboardTableViewCell: UITableViewCell, DashboardItemCellProtocol {
    
    @IBOutlet weak var courseTextLabel: UILabel!
    @IBOutlet weak var typeTextLabel: UILabel!
    @IBOutlet weak var roomTextLabel: UILabel!
    @IBOutlet weak var teacherTextLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var evaTextLabelContainer: UIView!
    @IBOutlet weak var evaTextLabel: UITextView!
    
    var _items: DetailItem?
    
    var items: DetailItem? {
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
                teacherTextLabel.attributedText = NSAttributedString(string:  StringHelper.replaceHtmlEntities(input: items[4]))
                teacherTextLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressSelector)))
                
                // 5. Comment
                text = StringHelper.replaceHtmlEntities(input: items[6])
                if text.count > 0 {
                    commentTextLabel.attributedText = NSAttributedString(string: text)
                } else {
                    commentTextLabel.attributedText = nil
                }
                
                // 6. EVA
                if items.count >= 8 {
                    // text = StringHelper.replaceHtmlEntities(input: items[7])
                    evaTextLabelContainer.isHidden = false
                    evaTextLabel.text = StringHelper.replaceHtmlEntities(input: items[7])
                    evaTextLabel.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
                    evaTextLabel.textContainer.lineFragmentPadding = 0
                } else {
                    evaTextLabelContainer.isHidden = true
                    evaTextLabel.text = nil
                }
            } else {
                courseTextLabel.attributedText = nil
                typeTextLabel.attributedText = nil
                roomTextLabel.attributedText = nil
                teacherTextLabel.attributedText = nil
                evaTextLabelContainer.isHidden = true
                evaTextLabel.text = nil
            }
        }
        get {
            return _items
        }
    }
    
    /**
     * Long press gesture callback. Gets label long press was on (teacher label), extracts shortcut name
     * and presents popover.
     */
    @objc func longPressSelector(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began,
            let teacherTextLabel = gestureRecognizer.view as? UILabel,
            let shortCutName = teacherTextLabel.attributedText?.string.trimmingCharacters(in: .whitespaces)
        else { return }

        let staffInfoPopoverController = StaffInfoPopoverController(withShortcutName: shortCutName, onView: teacherTextLabel, permittedArrowDirections: .any)
        staffInfoPopoverController.present(inViewController: TodayV2TableViewController.shared.controller as? UIViewController)
    }
}

/* *********************************************************************
 * Timetable cell which shows a timetable item for a given week type
 * and day of week.
 * *********************************************************************/
class TodayTimetableItemCell: UITableViewCell, TimetableItemCellProtocol {
    private var _scheduleItem: ScheduleItem?
    private var _lesson: Int?
    private var _row: Int?
    
    @IBOutlet weak var lessonTextLabel: UILabel!
    @IBOutlet weak var courseTextLabel: UILabel!
    @IBOutlet weak var roomTextLabel: UILabel!
    @IBOutlet weak var teacherTextLabel: UILabel!
    @IBOutlet weak var infoIconView: UIView!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    var scheduleItem: ScheduleItem? {
        set(value) {
            _scheduleItem = value
            if let scheduleItem = _scheduleItem {
                courseTextLabel.text = StringHelper.replaceHtmlEntities(input: scheduleItem.courseName)
                roomTextLabel.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: scheduleItem.room))
                teacherTextLabel.text = StringHelper.replaceHtmlEntities(input: scheduleItem.teacher)
                teacherTextLabel.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressSelector)))
                infoIconView.isHidden = !scheduleItem.isSubstitution
                
                if let bgcolor = scheduleItem.color {
                    backgroundColor = bgcolor
                } else {
                    if #available(iOS 13.0, *) {
                        backgroundColor = UIColor.systemBackground
                    } else {
                        backgroundColor = UIColor.white
                    }
                }
            }
        }
        get {
            return _scheduleItem
        }
    }
    
    var lesson: Int? {
        set(value) {
            _row = value
            if let lesson = value {
                // Add some extra space to top of first row.
                // This space is needed to display time marker.
                if _row == 0 {
                    stackViewTopConstraint.constant = 0
                }

                if lesson < 2 {
                    _lesson = lesson + 1
                    lessonTextLabel.text = "\(lesson + 1)."
                } else if lesson == 2 {
                    _lesson = nil
                    lessonTextLabel.text = nil
                } else if lesson < 6 {
                    _lesson = lesson
                    lessonTextLabel.text = "\(lesson)."
                } else if lesson == 6 {
                    _lesson = nil
                    lessonTextLabel.text = nil
                } else if lesson < 9 {
                    _lesson = lesson - 1
                    lessonTextLabel.text = "\(lesson - 1)."
                } else if lesson == 9 {
                    _lesson = nil
                    lessonTextLabel.text = nil
                } else {
                    _lesson = lesson - 2
                    lessonTextLabel.text = "\(lesson - 2)."
                }
            } else {
                lessonTextLabel.text = nil
            }
        }
        get {
            return _lesson
        }
    }
    
    /**
     * When user taps on teacher label this action method shows info popup
     * for teacher.
     */
    @objc func longPressSelector(gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began,
            let teacherTextLabel = gestureRecognizer.view as? UILabel,
            let shortCutName = teacherTextLabel.attributedText?.string.trimmingCharacters(in: .whitespaces)
        else { return }
        
        let staffInfoPopoverController = StaffInfoPopoverController(withShortcutName: shortCutName, onView: teacherTextLabel, permittedArrowDirections: .any)
        let viewController = TodayV2TableViewController.shared.controller as? UIViewController
        staffInfoPopoverController.present(inViewController: viewController)
    }

    /**
     * With each clock tick it must be checked if marker has reached this cell.
     * If so then lesson text label must be hidden as otherwise overlap will make
     * it unreadable and this looks ugly.
     */
    func onTick(forRow row: Int) {
        // For a break item no action is needed.
        guard let _ = _row else { return }
        
        if _row == row {
            if !lessonTextLabel.isHidden {
                lessonTextLabel.isHidden = true
            }
        } else {
            if lessonTextLabel.isHidden {
                lessonTextLabel.isHidden = false
            }
        }
    }
}
