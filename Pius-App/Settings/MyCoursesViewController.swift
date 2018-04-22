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
    var coursePicker: UIPickerView?;
    var courseTypePicker: UIPickerView?;
    var courseNumberPicker: UIPickerView?;
    var okButton: UIButton?;
    
    let cellBgView = UIView();
    
    let config = Config();
    var inEditMode: Bool = false;
    
    var courseList: [String] = [];
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch(pickerView) {
        case coursePicker!: return config.courses.count;
        case courseTypePicker!: return config.courseTypes.count;
        case courseNumberPicker!: return config.courseNumbers.count;
        default: fatalError("Invalid picker type");
        }
    }
    
    // Return content for the named row and picker view.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch(pickerView) {
        case coursePicker!: return config.courses[row];
        case courseTypePicker!: return config.courseTypes[row];
        case courseNumberPicker!: return config.courseNumbers[row];
        default: fatalError("Invalid picker type");
        }
    }
    

    private func addCourseFromPickers() {
        var realCourseName: String;
        let courseName = config.coursesShortNames[(coursePicker?.selectedRow(inComponent: 0))!]
        let courseType = config.courseTypes[(courseTypePicker?.selectedRow(inComponent: 0))!];
        let courseNumber = config.courseNumbers[(courseNumberPicker?.selectedRow(inComponent: 0))!];
        
        if (courseType == "P" || courseType == "V") {
            realCourseName = String(format: "%@%@%@", courseType, courseName, courseNumber);
        } else {
            realCourseName = String(format: "%@ %@%@", courseName, courseType, courseNumber);
        }
        
        courseList.append(realCourseName);
    }

    @IBAction func addCoursesButtonAction(_ sender: Any) {
        inEditMode = !inEditMode;
        addCoursesButton.title = (inEditMode) ? "Fertig" : "Hinzufügen";
        myCoursesTableView.reloadData();
        
        if (!inEditMode) {
            config.userDefaults.set(courseList, forKey: "dashboardCourseList");
        }
    }

    @objc func okAction(sender: UIButton) {
        addCourseFromPickers();
        myCoursesTableView.reloadData();
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count + ((inEditMode) ? 1 : 0);
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Height for picker view row when visible.
        if (indexPath.row == 0 && inEditMode) {
            return 100;
        }
        
        // Default height.
        return 30;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?;
        
        if (indexPath.row == 0 && inEditMode) {
            cell = myCoursesTableView.dequeueReusableCell(withIdentifier: "coursePickerCell")!;
            coursePicker = cell!.subviews[0].subviews[0] as? UIPickerView;
            courseTypePicker = cell!.subviews[0].subviews[1] as? UIPickerView;
            courseNumberPicker = cell!.subviews[0].subviews[2] as? UIPickerView;
            okButton = cell!.subviews[0].subviews[3] as? UIButton;
            
            coursePicker?.delegate = self;
            coursePicker?.dataSource = self;
            courseTypePicker?.delegate = self;
            courseTypePicker?.dataSource = self;
            courseNumberPicker?.delegate = self;
            courseNumberPicker?.dataSource = self;
            okButton?.addTarget(self, action: #selector(okAction), for: UIControlEvents.touchUpInside);
        } else {
            let realRow = indexPath.row - ((inEditMode) ? 1 : 0);
            cell = myCoursesTableView.dequeueReusableCell(withIdentifier: "course")!;
            cell!.textLabel?.text = courseList[realRow];
            cell?.selectedBackgroundView = cellBgView;
            cell?.textLabel?.highlightedTextColor = UIColor.white;
        }

        return cell!;
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let realRow = indexPath.row - ((inEditMode) ? 1 : 0);
            courseList.remove(at: realRow);
            myCoursesTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellBgView.backgroundColor = config.colorPiusBlue;
        let savedCourseList: [String]? = config.userDefaults.array(forKey: "dashboardCourseList") as? [String];
        
        courseList = (savedCourseList != nil) ? savedCourseList! : [];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
