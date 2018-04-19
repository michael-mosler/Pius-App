//
//  MyCoursesViewController.swift
//  Pius-App
//
//  Created by Michael on 19.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class MyCoursesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var addCoursesButton: UIBarButtonItem!
    @IBOutlet weak var myCoursesTableView: UITableView!
    var textField: UITextField?;
    
    let cellBgView = UIView();
    
    let config = Config();
    var inEditMode: Bool = false;
    
    var courseList: [String] = ["M GK1"];
    
    private func addCourseFromTextField() {
        let courseName: String! = textField?.text;
        courseList.append(courseName);
    }

    @IBAction func addCoursesButtonAction(_ sender: Any) {
        if (inEditMode) {
            addCourseFromTextField();
        }

        inEditMode = !inEditMode;
        addCoursesButton.title = (inEditMode) ? "Fertig" : "Hinzufügen";
        myCoursesTableView.reloadData();
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count + ((inEditMode) ? 1 : 0);
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?;
        
        if (indexPath.row == courseList.count && inEditMode) {
            cell = myCoursesTableView.dequeueReusableCell(withIdentifier: "addCourse")!;
            textField = cell!.subviews[0].subviews[0] as? UITextField;
            textField?.delegate = self;
            textField?.text = "";
        } else {
            cell = myCoursesTableView.dequeueReusableCell(withIdentifier: "course")!;
            cell!.textLabel?.text = courseList[indexPath.row];
            cell?.selectedBackgroundView = cellBgView;
            cell?.textLabel?.highlightedTextColor = UIColor.white;
        }

        return cell!;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cellBgView.backgroundColor = config.colorPiusBlue;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
