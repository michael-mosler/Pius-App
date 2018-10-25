//
//  MyCoursesViewController.swift
//  Pius-App
//
//  Created by Michael on 19.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class MyCoursesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
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
    
    let cellBgView = UIView();
    var inEditMode: Bool = false;
    var courseList: [String] = [];
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // Returns number of rows in picker view components.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView) {
        case coursePicker!: return Config.courses.count;
        case courseTypePicker!: return Config.courseTypes.count;
        case courseNumberPicker!: return Config.courseNumbers.count;
        default: fatalError("Invalid picker type");
        }
    }
    
    // Return content for the named row and picker view.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView) {
        case coursePicker!: return Config.courses[row];
        case courseTypePicker!: return Config.courseTypes[row];
        case courseNumberPicker!: return Config.courseNumbers[row];
        default: fatalError("Invalid picker type");
        }
    }
    

    // Appends selected course from picker to course list.
    private func addCourseFromPickers() {
        var realCourseName: String;
        let courseName = Config.coursesShortNames[(coursePicker?.selectedRow(inComponent: 0))!]
        let courseType = Config.courseTypes[(courseTypePicker?.selectedRow(inComponent: 0))!];
        let courseNumber = Config.courseNumbers[(courseNumberPicker?.selectedRow(inComponent: 0))!];
        
        if (courseType == "P" || courseType == "V") {
            realCourseName = String(format: "%@%@%@", courseType, courseName, courseNumber);
        } else {
            realCourseName = String(format: "%@ %@%@", courseName, courseType, courseNumber);
        }
        
        courseList.append(realCourseName);
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
        //myCoursesTableView.reloadData();
        
        if (!inEditMode) {
            showCoursePicker(false);
            AppDefaults.courseList = courseList;
            
            // Update subscription when app has push notifications enabled.
            if let deviceToken = Config.currentDeviceToken {
                let deviceTokenManager = DeviceTokenManager();
                deviceTokenManager.registerDeviceToken(token: deviceToken, subscribeFor: AppDefaults.gradeSetting, withCourseList: AppDefaults.courseList);
            }
        } else {
            showCoursePicker(true);
        }
    }

    @IBAction func okAction(sender: UIButton) {
        addCourseFromPickers();
        myCoursesTableView.reloadData();
    }

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
            let realRow = indexPath.row - ((inEditMode) ? 1 : 0);
            courseList.remove(at: realRow);
            myCoursesTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCoursePicker(false);

        cellBgView.backgroundColor = Config.colorPiusBlue;
        let savedCourseList: [String]? = AppDefaults.courseList;
        
        myCoursesTableView.allowsSelection = false;
        courseList = (savedCourseList != nil) ? savedCourseList! : [];
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
