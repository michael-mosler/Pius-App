//
//  MyCoursesViewController.swift
//  Pius-App
//
//  Created by Michael on 19.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class MyCoursesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIScrollViewDelegate {
    @IBOutlet weak var addCoursesButton: UIBarButtonItem!
    @IBOutlet weak var myCoursesTableView: UITableView!
    @IBOutlet weak var coursePickerView: UIView!
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var courseTypePicker: UIPickerView!
    @IBOutlet weak var courseNumberPicker: UIPickerView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var coursePickerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var coursePickerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editTopConstraint: NSLayoutConstraint!
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var courseEditField: UITextField!

    let cellBgView = UIView();
    var inEditMode: Bool = false;
    var courseList: [String] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCoursePicker(false);
        
        tabBarController?.tabBar.isHidden = true;
        
        cellBgView.backgroundColor = Config.colorPiusBlue;
        let savedCourseList: [String]? = AppDefaults.courseList;
        
        myCoursesTableView.allowsSelection = false;
        courseList = (savedCourseList != nil) ? savedCourseList! : [];
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(tapGestureRecognizer);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        tabBarController?.tabBar.isHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        tabBarController?.tabBar.isHidden = false;

        AppDefaults.courseList = courseList;
        
        // Update subscription when app has push notifications enabled.
        if let deviceToken = Config.currentDeviceToken {
            let deviceTokenManager = DeviceTokenManager();
            deviceTokenManager.registerDeviceToken(token: deviceToken, subscribeFor: AppDefaults.gradeSetting, withCourseList: AppDefaults.courseList);
        }
    }
    
    /*
     * ============================================================
     *                   Picker and Button
     * ============================================================
     */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // Returns number of rows in picker view components.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView) {
        case coursePicker!: return Config.courses.count;
        case courseTypePicker!: return Config.courseTypes.count;
        case courseNumberPicker!: return Config.courseNumbers.count;
        default: return 0;
        }
    }
    
    // Return content for the named row and picker view.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView) {
        case coursePicker!: return Config.courses[row];
        case courseTypePicker!: return Config.courseTypes[row];
        case courseNumberPicker!: return Config.courseNumbers[row];
        default: return "";
        }
    }
    

    // Appends selected course from picker to course list.
    private func addCourseFromPickers() {
        var realCourseName: String;

        if activeTextField != nil, let courseName = courseEditField.text, courseName != "" {
            realCourseName = courseName;
            courseEditField.text = "";
            dismissKeyboard(fromTextField: activeTextField);
        } else {
            let courseName = Config.coursesShortNames[(coursePicker?.selectedRow(inComponent: 0))!]
            let courseType = Config.courseTypes[(courseTypePicker?.selectedRow(inComponent: 0))!];
            let courseNumber = Config.courseNumbers[(courseNumberPicker?.selectedRow(inComponent: 0))!];
            
            if (courseType == "P" || courseType == "V") {
                realCourseName = String(format: "%@%@%@", courseType, courseName, courseNumber);
            } else {
                realCourseName = String(format: "%@ %@%@", courseName, courseType, courseNumber);
            }
        }
        
        courseList.append(realCourseName);
        
        let indexPath = IndexPath(row: courseList.count - 1, section: 0);
        myCoursesTableView.reloadData();
        myCoursesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true);
    }

    // Show or hide course picker view.
    private func showCoursePicker(_ visible: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.coursePickerViewHeightConstraint.constant = (visible) ? 150 : 0;
            self.editTopConstraint.constant = (visible) ? 8 : 0;
            self.coursePickerView.isHidden = !visible;
            self.coursePickerView.layoutIfNeeded()
        });
    }

    @IBAction func addCoursesButtonAction(_ sender: Any) {
        inEditMode = !inEditMode;
        myCoursesTableView.allowsSelection = inEditMode;
        
        addCoursesButton.title = (inEditMode) ? "Fertig" : "Bearbeiten";
        showCoursePicker(inEditMode);
    }

    @IBAction func okAction(sender: UIButton) {
        addCourseFromPickers();
        myCoursesTableView.reloadData();
    }

    /*
     * ============================================================
     *                      Table View
     * ============================================================
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myCoursesTableView.dequeueReusableCell(withIdentifier: "course")!;
        cell.textLabel?.text = courseList[indexPath.row];
        cell.selectedBackgroundView = cellBgView;
        cell.textLabel?.highlightedTextColor = UIColor.white;

        return cell;
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return (inEditMode) ? .delete : .none;
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            courseList.remove(at: indexPath.row);
            myCoursesTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    /*
     * ============================================================
     *                      Keyboard handling
     * ============================================================
     */
    
    private var activeTextField: UITextField?;
    @IBOutlet weak var myCoursesBottomConstraint: NSLayoutConstraint!
    
    // Dismiss keyboard on tap gesture somwwhere into view controller.
    @IBAction func tapGestureAction(_ sender: Any) {
        dismissKeyboard(fromTextField: activeTextField);
    }
    
    private func dismissKeyboard(fromTextField textField: UITextField?) {
        if (textField != nil) {
            textField?.resignFirstResponder();
        }
    }
    
    // Remember text field in which editing has begun.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField;
    }
    
    // Forget text field which was edited in as editing has ended.
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil;
    }
    
    // Dismiss keyboard on request.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addCourseFromPickers();
        dismissKeyboard(fromTextField: textField);
        return true;
    }
    
    // Keyboard was shown, we need to resize our scrollview to make sure that keyboard is visible
    // on any device.
    @objc func keyboardWillShow(notification: NSNotification) {
        guard activeTextField != nil else { return };
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            myCoursesTableView.contentInset.bottom = keyboardSize.height;
        }
    }
    
    // Keyboard will hide; scroll view can be expanded again.
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero;
        myCoursesTableView.contentInset = contentInsets;
        myCoursesTableView.scrollIndicatorInsets = contentInsets;
    }
}
