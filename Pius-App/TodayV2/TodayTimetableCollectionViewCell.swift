//
//  TodayTimetableCollectionViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 25.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayTimetableCollectionViewCell: UICollectionViewCell, TimerDelegate {
    @IBOutlet weak var tableView: TodayTimetableTableView!
    @IBOutlet weak var timeMarkerView: UIView!
    @IBOutlet weak var timeMarkerLabel: UILabel!
    @IBOutlet weak var timeMarkerDotView: UIView!
    @IBOutlet weak var timeMarkerTopConstraint: NSLayoutConstraint!
    
    // This is the day of week the cell is displaying.
    var forDay: Int?
    
    override func awakeFromNib() {
        TodayV2TableViewController.shared.controller?.registerTimerDelegate(self)
        
        timeMarkerView.isHidden = true
        timeMarkerDotView.isHidden = true
        timeMarkerLabel.isHidden = true
    }
    
    func reload() {
        tableView.reloadData()
    }

    func onTick(_ timer: Timer?) {
        guard tableView.forWeek == DateHelper.week(), forDay == DateHelper.dayOfWeek(),
            let row = TimetableHelper.currentLesson()
        else {
                timeMarkerView.isHidden = true
                timeMarkerDotView.isHidden = true
                timeMarkerLabel.isHidden = true
                tableView.onTick(forRow: -1)
                return
            }
        
        guard row != Int.min && row != Int.max,
            let epochLessonStart = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[row]):00"),
            let epochLessonEnd = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[row + 1]):00")
        else {
            timeMarkerLabel.isHidden = true
            timeMarkerView.isHidden = true
            timeMarkerDotView.isHidden = true
            tableView.onTick(forRow: -1)
            return
        }

        let rowHeight = CGFloat(TodayScreenUnits.timetableRowHeight) // CGFloat((frame.height - 2 * CGFloat(TodayScreenUnits.timetableSpacing)) / CGFloat(lessons.count))
        let duration = CGFloat(epochLessonEnd - epochLessonStart)
        let lessonDuration = CGFloat(Date().timeIntervalSince1970 - epochLessonStart)
        let offset = CGFloat(row) * rowHeight + lessonDuration * rowHeight / duration
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "HH:mm"
        
        timeMarkerLabel.isHidden = false
        timeMarkerView.isHidden = false
        timeMarkerDotView.isHidden = false
        timeMarkerTopConstraint.constant = offset + 8
        timeMarkerLabel.text = dateFormatter.string(from: Date())

        // Cascade to cells.
        tableView.onTick(forRow: row)
        layoutIfNeeded()
    }
}
