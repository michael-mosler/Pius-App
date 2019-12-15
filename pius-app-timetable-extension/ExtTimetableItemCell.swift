//
//  ExtTimetableItemCellTableViewCell.swift
//  pius-app-timetable-extension
//
//  Created by Michael Mosler-Krings on 17.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Timetable cell item for iOS Today view. This class is subject to refactoring as it
 * implements some logic that also is present in App's today view.
 */
class ExtTimetableItemCell: UITableViewCell, TimetableItemCellProtocol {
    private var _scheduleItem: ScheduleItem?
    private var _lesson: Int?
    private var _row: Int?

    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var infoIconImage: UIImageView!
    @IBOutlet weak var infoIconView: UIView!

    var scheduleItem: ScheduleItem? {
         set(value) {
            _scheduleItem = value
            if let scheduleItem = _scheduleItem {
                courseLabel.text = StringHelper.replaceHtmlEntities(input: scheduleItem.courseName)
                roomLabel.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: scheduleItem.room))
                teacherLabel.text = StringHelper.replaceHtmlEntities(input: scheduleItem.teacher)
                
                infoIconImage.isHidden = !scheduleItem.isSubstitution
                
                // If this cell has a special color assigned set text color.
                // For iOS 12 and above we must consider dark mode. Default
                // color would not work well.
                if let bgcolor = scheduleItem.color {
                    var textColor: UIColor
                    if #available(iOSApplicationExtension 12.0, *) {
                        textColor = self.traitCollection.userInterfaceStyle == .dark ? .white : .black
                    } else {
                        textColor = .white
                    }
                    
                    lessonLabel.textColor = textColor
                    courseLabel.textColor = textColor
                    roomLabel.textColor = textColor
                    teacherLabel.textColor = textColor
                    backgroundColor = bgcolor
                } else {
                    // Default background color on iOS 13 and above. Use
                    // white text color. Fits best in dark and normal mode.
                    // On elder versions simply use white background.
                    if #available(iOS 13.0, *) {
                        lessonLabel.textColor = .white
                        courseLabel.textColor = .white
                        roomLabel.textColor = .white
                        teacherLabel.textColor = .white
                        backgroundColor = nil
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
     
    // Effective lesson: Here breaks do not count and, thus, get no label.
    var lesson: Int? {
        set(value) {
            _row = value
            if let lesson = value {
                if lesson < 2 {
                    _lesson = lesson + 1
                    lessonLabel.text = "\(lesson + 1)."
                } else if lesson == 2 {
                    _lesson = nil
                    lessonLabel.text = nil
                } else if lesson < 6 {
                    _lesson = lesson
                    lessonLabel.text = "\(lesson)."
                } else if lesson == 6 {
                    _lesson = nil
                    lessonLabel.text = nil
                } else if lesson < 9 {
                    _lesson = lesson - 1
                    lessonLabel.text = "\(lesson - 1)."
                } else if lesson == 9 {
                    _lesson = nil
                    lessonLabel.text = nil
                } else {
                    _lesson = lesson - 2
                    lessonLabel.text = "\(lesson - 2)."
                }
            } else {
                lessonLabel.text = nil
            }
        }
        get {
            return _lesson
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
