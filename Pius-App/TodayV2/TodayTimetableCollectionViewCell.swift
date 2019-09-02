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
    @IBOutlet weak var timeMarkerTopConstraint: NSLayoutConstraint!
    
    private let epochFor0755 = DateHelper.epoch(forTime: "07:55:00")
    private var lessonEndTimes: [TimeInterval] = []
    
    // This is the day of week the cell is displaying.
    var forDay: Int?
    
    override func awakeFromNib() {
        TodayV2TableViewController.shared.controller?.registerTimerDelegate(self)
        
        for i in 0..<lessonsWithAllEndTimes.count-1 {
            if let epochLessonStart = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[i]):00"),
                let epochLessonEnd = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[i+1]):00") {
                if i == 0 {
                    lessonEndTimes.append(epochLessonEnd - epochLessonStart)
                } else {
                    lessonEndTimes.append(lessonEndTimes[i-1] + epochLessonEnd - epochLessonStart)
                }
            }
        }
    }
    
    func reload() {
        tableView.reloadData()
    }

    func onTick(_ timer: Timer?) {
        guard forDay == DateHelper.dayOfWeek(), let epochFor0755 = epochFor0755 else {
            timeMarkerView.isHidden = true
            timeMarkerLabel.isHidden = true
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.dateFormat = "HH:mm"

        let epochSince1970 = Date().timeIntervalSince1970 - 7200
        
        // This is the number of seconds since 07:55h today.
        // row is the row which is covered by the lesson addressed
        // by secondsSince0755. If row is out of scope hide markers.
        let secondsSince0755 = epochSince1970 - epochFor0755
        
        guard let row = lessonEndTimes.firstIndex(where: { lessonEndTime in return secondsSince0755 <= lessonEndTime }),
            let epochLessonStart = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[row]):00"),
            let epochLessonEnd = DateHelper.epoch(forTime: "\(lessonsWithAllEndTimes[row + 1]):00")
        else {
            timeMarkerLabel.isHidden = true
            timeMarkerView.isHidden = true
            return
        }
        
        let rowHeight = CGFloat((frame.height - 2 * CGFloat(TodayScreenUnits.timetableSpacing)) / CGFloat(lessons.count))
        let duration = CGFloat(epochLessonEnd - epochLessonStart)
        let lessonDuration = CGFloat(epochSince1970 - epochLessonStart)
        let offset = CGFloat(row) * rowHeight + lessonDuration * rowHeight / duration
        
        timeMarkerLabel.isHidden = false
        timeMarkerView.isHidden = false
        timeMarkerTopConstraint.constant = offset + 8
        timeMarkerLabel.text = dateFormatter.string(from: Date())

        // Cascade to cells.
        tableView.onTick(forRow: row)
        layoutIfNeeded()
    }
}
