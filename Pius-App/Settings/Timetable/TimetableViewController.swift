//
//  TimetableViewController.swift
//
//  Created by Michael Mosler-Krings on 27.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit

/* ****************************************************************
 * Simple class that implements colouring of Week selection button.
 * ****************************************************************/
class WeekButton: UIButton {
    func select() {
        backgroundColor = UIColor(named: "piusBlue")
        setTitleColor(.white, for: .normal)
    }
    
    func deselect() {
        backgroundColor = .white
        setTitleColor(UIColor(named: "piusBlue"), for: .normal)
    }
}

/* ****************************************************************
 * Protocol needed to support drag of subjects onto timetable.
 * ****************************************************************/
protocol TimetableCollectionViewProtocol {
    func cell(forItemAt indexPath: IndexPath) -> UICollectionViewCell
    func dragItem(forIndexPath indexPath: IndexPath) -> [UIDragItem]
}

class TimetableViewController: UIViewController, TimetableViewDataDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    private let timetable: Timetable = AppDefaults.timetable
    weak private var scheduleItem: ScheduleItem?
    
    private var currentDay: Int {
        get {
            guard let scrollView = scheduleCollectionView else { return 0 }
            return Int((scrollView.contentOffset.x / CGFloat(IOSHelper.screenWidth)).rounded());
        }
    }
    
    @IBOutlet weak var courseCollectionView: CourseCollectionView!
    @IBOutlet weak var scheduleCollectionView: ScheduleCollectionView!
    @IBOutlet weak var scheduleCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var dayNameLabel: UILabel!
    
    @IBOutlet weak var weekSegmentControl: UISegmentedControl!
    @IBAction func weekSegmentControlAction(_ sender: Any) {
        if let week = Week(rawValue: weekSegmentControl.selectedSegmentIndex) {
            scheduleCollectionView.week = week
        } else {
            scheduleCollectionView.week = .A
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Löschen", message: "Was möchtest Du löschen?", preferredStyle: .actionSheet)
        
        let deleteDayAction = UIAlertAction(title: "Nur den aktuellen Tag", style: .default) { (action) in
            self.timetable.delete(forDay: self.currentDay)
            self.scheduleCollectionView.reloadData()
        }
        
        let deleteAllAction = UIAlertAction(title: "Alle Tage", style: .destructive) { (action) in
            self.timetable.delete()
            self.scheduleCollectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel)
        
        actionSheet.addAction(deleteDayAction)
        actionSheet.addAction(deleteAllAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weekSegmentControl.selectedSegmentIndex = Week.A.rawValue
        courseCollectionView.dragInteractionEnabled = true
        scheduleCollectionView.timetableViewDataDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Update subscription when app has push notifications enabled.
        if let deviceToken = Config.currentDeviceToken {
            let deviceTokenManager = DeviceTokenManager()
            deviceTokenManager.registerDeviceToken(token: deviceToken, subscribeFor: AppDefaults.gradeSetting, withCourseList: AppDefaults.courseList)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: scheduleCollectionView.frame.width, height: scheduleCollectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (collectionView as! TimetableCollectionViewProtocol).cell(forItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return (collectionView as! TimetableCollectionViewProtocol).dragItem(forIndexPath: indexPath)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Only for ScheduleCollectionView instance.
        guard scrollView == scheduleCollectionView else { return }
        dayNameLabel.text = Config.dayNames[currentDay]
    }
}

/* ****************************************************************
 * Extension that implements protocol TimetableViewDataDelegate.
 * ****************************************************************/
extension TimetableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? CourseDetailsViewController {
            destination.delegate = self
            destination.scheduleItem = scheduleItem
        }
    }

    func schedule(forWeek week: Week, forDay index: Int) -> ScheduleForDay {
        return timetable.schedule(forWeek: week, forDay: index)
    }
    
    func schedule(forSubject subject: String) -> [ScheduleItem] {
        return timetable.schedule(forSubject: subject)
    }

    func schedule(forSubject subject: String, forCourse course: String) -> ScheduleItem {
        return timetable.schedule(forSubject: subject, forCourse: course)
    }
    
    func schedule(updateWithWeek week: Week, updateWithDay day: Int, updateWithLesson lesson: Int, scheduleItem: ScheduleItem) {
        timetable.update(week, day: day, lesson: lesson, withScheduleItem: scheduleItem)
        scheduleCollectionView.reloadData()
    }
    
    func schedule(deleteForWeek week: Week, deleteForDay day: Int, deleteForLesson lesson: Int) {
        timetable.delete(forWeek: week, forDay: day, forLesson: lesson)
        scheduleCollectionView.reloadData()
    }
    
    func details(requestForItem item: ScheduleItem, sender: Any?) {
        scheduleItem = item
        performSegue(withIdentifier: "toCourseDetails", sender: sender)
    }
    
    func details(updateWithItem item: ScheduleItem, forOldItem oldItem: ScheduleItem, sender: Any?) {
        timetable.details(itemUpdated: item, oldItem: oldItem)
        scheduleCollectionView.reloadData()
    }
    
    func present(_ viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}
