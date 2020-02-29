//
//  CourseDetailsViewController.swift
//  Playground
//
//  Created by Michael Mosler-Krings on 02.08.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit

/* ****************************************************************
 * This view allows to specifiy details for a sinagle schedule
 * item. The view is navigated to explicitely by performing
 * a segue operation from timetable view controller. When
 * performing schedule item to be edited must be set before
 * hand.
 * ****************************************************************/
class CourseDetailsViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var courseEdit: UITextField!
    @IBOutlet weak var courseTypePicker: UIPickerView!
    @IBOutlet weak var courseNumberPicker: UIPickerView!
    @IBOutlet weak var roomTextEdit: UITextField!
    @IBOutlet weak var teacherTextEdit: UITextField!
    @IBOutlet weak var examSwitch: UISwitch!
    @IBOutlet var tapGestureRecogizer: UITapGestureRecognizer!
    
    private var activeTextField: UITextField?

    var delegate:  TimetableViewDataDelegate?
    weak var scheduleItem: ScheduleItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        courseEdit.delegate = self
        roomTextEdit.delegate = self
        teacherTextEdit.delegate = self
        
        scrollView.addGestureRecognizer(tapGestureRecogizer)
        
        if let scheduleItem = scheduleItem {
            if let scheduleItem = scheduleItem as? ExtraScheduleItem {
                courseEdit.isEnabled = true
                courseEdit.text = (scheduleItem.isCustomized) ? scheduleItem.course : ""
            } else {
                courseEdit.text = scheduleItem.course
            }
            courseTypePicker.selectRow(scheduleItem.courseType, inComponent: 0, animated: false)
            courseNumberPicker.selectRow(scheduleItem.courseNumber, inComponent: 0, animated: false)
            roomTextEdit.text = scheduleItem.room
            teacherTextEdit.text = scheduleItem.teacher
            examSwitch.isOn = scheduleItem.courseItem.exam
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let scheduleItem = scheduleItem, let delegate = delegate else { return }
        let newCourseItem = CourseItem(course: courseEdit.text ?? "", teacher: teacherTextEdit.text ?? "", courseType: courseTypePicker.selectedRow(inComponent: 0), courseNumber: courseNumberPicker.selectedRow(inComponent: 0), exam: examSwitch.isOn)
        let newScheduleItem = (scheduleItem as? ExtraScheduleItem == nil)
            ? CustomScheduleItem(room: roomTextEdit.text ?? "", courseItem: newCourseItem)
            : ExtraScheduleItem(room: roomTextEdit.text ?? "", courseItem: newCourseItem)
        delegate.details(updateWithItem: newScheduleItem, forOldItem: scheduleItem, sender: self)
    }
    
    private func dismissKeyboard(fromTextField textField: UITextField?) {
        textField?.resignFirstResponder()
    }

    // Remember text field in which editing has begun.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    // Forget text field which was edited in as editing has ended.
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }

    // Dismiss keyboard on request.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(fromTextField: textField)
        return true
    }

    @IBAction func tapGestureAction(_ sender: Any) {
        guard activeTextField != nil else { return }
        dismissKeyboard(fromTextField: activeTextField)
    }
    
    // Keyboard was shown, we need to resize our scrollview to make sure that keyboard is visible
    // on any device.
    @objc func keyboardWasShown(notification: NSNotification) {
        guard activeTextField != nil else { return }

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    // Keyboard will hide; scroll view can be expanded again.
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
