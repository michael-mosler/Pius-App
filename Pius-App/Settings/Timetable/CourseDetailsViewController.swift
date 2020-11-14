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
    @IBOutlet weak var teacherLabel: UILabel!
    private var searchButton: UIButton?
    
    private var activeTextField: UITextField?
    private var feedbackGenerator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()

    var delegate:  TimetableViewDataDelegate?
    weak var scheduleItem: ScheduleItem?
    private var staffDictionary: StaffDictionary?
    
    /**
     * View did load: Fill all content and set up notifications and delegates.
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        feedbackGenerator.prepare()
        
        let staffLoader = StaffLoader()
        staffDictionary = staffLoader.loadFromCache()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(notification:)), name: UITextField.textDidChangeNotification, object: teacherTextEdit)

        courseEdit.delegate = self
        roomTextEdit.delegate = self
        teacherTextEdit.delegate = self
        
        addSearchButton(toTextField: teacherTextEdit, #selector(extendedTeacherEditAction(sender:)))
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

            updateTeacherLabel(fromShortname: scheduleItem.teacher)
        }
    }
    
    /**
     * Add a search button to the given text field. The button
     * is added as right view.
     */
    private func addSearchButton(toTextField textField: UITextField, _ searchAction: Selector) {
        let searchImage = UIImage(named: "search")

        if #available(iOS 14.0, *) {
            searchButton = UIButton()
        } else {
            searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        }

        searchButton?.setImage(searchImage, for: .normal)
        searchButton?.addTarget(self, action: searchAction, for: .touchDown)
        teacherTextEdit.rightView = searchButton
        teacherTextEdit.rightViewMode = .always
    }
    
    /**
     * Receives result from extended teacher edit search dialog.
     */
    func receiveResult(selectedShortname: String?) {
        teacherTextEdit.text = selectedShortname
        updateTeacherLabel(fromShortname: selectedShortname)
    }
    
    /**
     * Action function for search button in teacher text field.
     * This action shows a comprehensive list of all teachers with
     * a search function. The user may select one entry by tapping.
     */
    @objc private func extendedTeacherEditAction(sender: UIButton) {
        guard let popoverController =
                UIStoryboard(name: "TimetableStoryboard", bundle: nil)
                .instantiateViewController(withIdentifier: "ExtendedTeacherEditTableViewController") as? ExtendedTeacherEditTableViewController,
              let searchButton = searchButton
        else { return }

        let rect = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: 12, height: view.bounds.height)

        popoverController.resultDelegate = self
        popoverController.setSourceView(view: searchButton, rect: rect)
        feedbackGenerator.notificationOccurred(.success)
        self.present(popoverController, animated: true, completion: nil)
    }

    /**
     * View will disappear: Save data.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let scheduleItem = scheduleItem, let delegate = delegate else { return }
        let newCourseItem = CourseItem(course: courseEdit.text ?? "", teacher: teacherTextEdit.text ?? "", courseType: courseTypePicker.selectedRow(inComponent: 0), courseNumber: courseNumberPicker.selectedRow(inComponent: 0), exam: examSwitch.isOn)
        let newScheduleItem = (scheduleItem as? ExtraScheduleItem == nil)
            ? CustomScheduleItem(room: roomTextEdit.text ?? "", courseItem: newCourseItem)
            : ExtraScheduleItem(room: roomTextEdit.text ?? "", courseItem: newCourseItem)
        delegate.details(updateWithItem: newScheduleItem, forOldItem: scheduleItem, sender: self)
    }

    /**
     * Update teacher name in teacher label from shortname in text
     * edit. This requires staff dictionary to have been loaded when
     * view is loaded.
     */
    private func updateTeacherLabel(fromShortname shortname: String?) {
        guard let staffDictionary = staffDictionary,
              let shortname = shortname,
              let staffMember = staffDictionary[shortname]
        else {
            teacherLabel.text = ""
            return
        }
        
        teacherLabel.text = staffMember.name
    }

    /**
     * Remember text field in which editing has begun.
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    /**
     * Forget text field which was edited in as editing has ended.
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }

    /**
     * Dismiss keyboard on request.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /**
     * User has tapped somewhere on the screen, dismiss keyboard.
     */
    @IBAction func tapGestureAction(_ sender: Any) {
        guard activeTextField != nil else { return }
        activeTextField?.resignFirstResponder()
    }
    
    /**
     * Keyboard was shown, we need to resize our scrollview to make sure that keyboard is visible.
     * on any device.
     */
    @objc func keyboardWasShown(notification: NSNotification) {
        guard activeTextField != nil else { return }

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }

    /**
     * Keyboard will hide; scroll view can be expanded again.
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    /**
     * Processes text edit change in teacher text edit. Each change
     * causes an update of teacher name label content.
     */
    @objc func textDidChange(notification: NSNotification) {
        guard let textField = notification.object as? UITextField else { return }
        updateTeacherLabel(fromShortname: textField.text ?? "")
    }
}
