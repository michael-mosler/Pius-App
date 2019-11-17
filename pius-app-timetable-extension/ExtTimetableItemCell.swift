//
//  ExtTimetableItemCellTableViewCell.swift
//  pius-app-timetable-extension
//
//  Created by Michael Mosler-Krings on 17.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

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
                 
                 isUserInteractionEnabled = scheduleItem.isSubstitution
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
                     // stackViewTopConstraint.constant = 0
                 }

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
