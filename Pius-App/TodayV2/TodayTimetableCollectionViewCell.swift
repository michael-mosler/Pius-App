//
//  TodayTimetableCollectionViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 25.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayTimetableCollectionViewCell: UICollectionViewCell, TimerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeMarkerView: UIView!
    @IBOutlet weak var timeMarkerTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        TodayV2TableViewController.shared.controller?.registerTimerDelegate(self)
    }
    
    func reload() {
        tableView.reloadData()
    }

    func onTick(_ timer: Timer) {
        NSLog("collection tick")
    }
}
