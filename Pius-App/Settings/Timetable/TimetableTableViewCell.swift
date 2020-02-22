//
//  ScheduleTableViewCell.swift
//
//  Created by Michael Mosler-Krings on 27.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit

/* ****************************************************************
 * A cell of the timetable view. Such a cell holds outlet to
 * display all information needed. It also knows about the
 * ScheduleItem instance associated with this cell, i.e. it
 * connects this cell to the model.
 * ****************************************************************/
class TimetableTableViewCell: UITableViewCell {
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lessonLabel: UILabel!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!

    private var _scheduleItem: ScheduleItem?
    private var _lesson: Int?
    
    var lesson: Int? {
        set(value) {
            guard let value = value, value < lessons.count else {
                lessonLabel.text = nil
                _lesson = nil
                return
            }
            
            _lesson = value
            lessonLabel.text = lessons[value]
        }
        get {
            return _lesson
        }
    }
    
    var scheduleItem: ScheduleItem? {
        get {
            return _scheduleItem
        }
        set(value) {
            _scheduleItem = value
            if let value = value {
                // For all items that can be deleted user interaction is enabled.
                isUserInteractionEnabled = value.canBeDeleted
                courseLabel.text = value.courseName
                
                if value.room.count > 0 {
                    roomLabel.text = "Raum: \(value.room)"
                } else {
                    roomLabel.text = nil
                }
                
                if value.teacher.count > 0 {
                    teacherLabel.text = "Lehrer \(value.teacher)"
                } else {
                    teacherLabel.text = nil
                }
            } else {
                isUserInteractionEnabled = false
                lessonLabel.text = nil
                courseLabel.text = nil
                roomLabel.text = nil
                teacherLabel.text = nil
            }

            if let bgColor = _scheduleItem?.color {
                backgroundColor = bgColor
            } else {
                if #available(iOS 13.0, *) {
                    backgroundColor = UIColor.systemGroupedBackground
                } else {
                    backgroundColor = UIColor.white
                }
            }
        }
    }
    var deleteHandler: (UITableViewCell) -> Void = { _ in };
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        deleteHandler(self)
    }
}
