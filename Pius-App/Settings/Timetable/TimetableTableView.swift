//
//  TimetableTablewView.swift
//
//  Created by Michael Mosler-Krings on 28.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit

/* ****************************************************************
 * Usually a view controller implements this protocol which is
 * needed by timetable view in order to perform editing operations.
 * ****************************************************************/
protocol TimetableViewDataDelegate {
    func schedule(forWeek week: Week, forDay index: Int) -> ScheduleForDay
    func schedule(forSubject subject: String) -> [ScheduleItem]
    func schedule(forSubject subject: String, forCourse course: String) -> ScheduleItem
    func schedule(updateWithWeek week: Week, updateWithDay day: Int, updateWithLesson lesson: Int, scheduleItem: ScheduleItem)
    func schedule(deleteForWeek week: Week, deleteForDay day: Int, deleteForLesson lessin: Int)
    func details(requestForItem item: ScheduleItem, sender: Any?)
    func details(updateWithItem item: ScheduleItem, forOldItem oldItem: ScheduleItem, sender: Any?)
    func present(_ viewController: UIViewController)
}

class TimetableTableView: UITableView, UITableViewDelegate, UITableViewDataSource, UITableViewDropDelegate {
    var dataDelegate: TimetableViewDataDelegate?
    var forWeek: Week = Week.A
    var forDay: Int = 0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
    }
    
    private func deleteHandler(for cell: UITableViewCell) {
        if let indexPath = self.indexPath(for: cell) {
            dataDelegate?.schedule(deleteForWeek: forWeek, deleteForDay: forDay, deleteForLesson: indexPath.row)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let schedule = dataDelegate?.schedule(forWeek: forWeek, forDay: forDay) {
            return schedule.numberOfItems
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let schedule = dataDelegate?.schedule(forWeek: forWeek, forDay: forDay) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeLesson") as! TimetableTableViewCell
            let scheduleItem = schedule.item(forLesson: indexPath.row)
            cell.lesson = indexPath.row
            cell.scheduleItem = scheduleItem
            cell.deleteHandler = deleteHandler;
            cell.deleteButton.isHidden = !scheduleItem.canBeDeleted
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        if let indexPath = coordinator.destinationIndexPath {
            let dropItem = coordinator.items[0]
            dropItem.dragItem.itemProvider.loadObject(ofClass: NSString.self) { string, error in
                if let subject = string as? String {
                    let scheduleItems = self.dataDelegate?.schedule(forSubject: subject)
                    switch scheduleItems!.count {
                    case 0:
                        // There is no item yet. Create a dummy item for the subject. Usually user will edit this an thereby create a course item.
                        DispatchQueue.main.async {
                            let scheduleItem = (subject.count > 0) ? CustomScheduleItem(courseItem: CourseItem(course: subject)) : ExtraScheduleItem(courseItem: CourseItem(course: subject))
                            self.dataDelegate?.schedule(updateWithWeek: self.forWeek, updateWithDay: self.forDay, updateWithLesson: indexPath.row, scheduleItem: scheduleItem)
                        }
                        break

                    case 1:
                        // There is one fully qualified course item for the subject. Use it.
                        DispatchQueue.main.async {
                            self.dataDelegate?.schedule(updateWithWeek: self.forWeek, updateWithDay: self.forDay, updateWithLesson: indexPath.row, scheduleItem: scheduleItems![0])
                        }
                        break

                    default:
                        // There is more than one fully qualified course item for the subject.
                        // Ask which shall be used. User cannot cancel operation at this point.
                        DispatchQueue.main.async {
                            let actionSheet = UIAlertController(title: "Kurs hinzufügen", message: "Welchen der Kurse möchtest Du hinzufügen?", preferredStyle: .actionSheet)
                            scheduleItems?.forEach({ scheduleItem in
                                let action = UIAlertAction(title: scheduleItem.courseName, style: .default, handler: { (action) in
                                    if let newScheduleItem = self.dataDelegate?.schedule(forSubject: subject, forCourse: action.title!) {
                                        self.dataDelegate?.schedule(updateWithWeek: self.forWeek, updateWithDay: self.forDay, updateWithLesson: indexPath.row, scheduleItem: newScheduleItem)
                                    }
                                })
                                actionSheet.addAction(action)
                            })
                            
                            self.dataDelegate?.present(actionSheet)
                        }
                        break
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        guard let indexPath = destinationIndexPath else { return UITableViewDropProposal(operation: .forbidden) }
        if let cell = cellForRow(at: indexPath) as? TimetableTableViewCell, let scheduleItem = cell.scheduleItem {
            if !scheduleItem.canBeReplaced {
                return UITableViewDropProposal(operation: .forbidden)
            } else {
                cell.isUserInteractionEnabled = true
                cell.setHighlighted(true, animated: true)
                cell.setNeedsDisplay()
                return UITableViewDropProposal(operation: .copy, intent: .insertIntoDestinationIndexPath)
            }
        }
        return UITableViewDropProposal(operation: .forbidden)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = cellForRow(at: indexPath) as? TimetableTableViewCell, let scheduleItem = cell.scheduleItem {
            dataDelegate?.details(requestForItem: scheduleItem, sender: cell)
        }
    }
}
