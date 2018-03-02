//
//  EinstellungenViewController.swift
//  Pius-App
//
//  Created by Michael on 28.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class EinstellungenViewController: UIViewController, UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var gradePickerView: UIPickerView!
    @IBOutlet weak var classPickerView: UIPickerView!
    
    let userDefaults = UserDefaults.standard;
    
    let grades = ["keine", "Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9", "EF", "Q1", "Q2"];
    
    let classes = ["keine", "a", "b", "c", "d", "e"];
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == gradePickerView) {
            return grades[row];
        }
        return classes[row];
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == gradePickerView) {
            return grades.count;
        }
        return classes.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == gradePickerView) {
            userDefaults.set(row, forKey: "selectedGradeRow");
        } else {
            userDefaults.set(row, forKey: "selectedClassRow");
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad();

        var row : Int;
        row = userDefaults.integer(forKey: "selectedGradeRow");
        gradePickerView.selectRow(row, inComponent: 0, animated: false)

        row = userDefaults.integer(forKey: "selectedClassRow");
        classPickerView.selectRow(row, inComponent: 0, animated: false);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

