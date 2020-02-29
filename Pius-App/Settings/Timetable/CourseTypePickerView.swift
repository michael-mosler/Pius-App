//
//  CourseTypePickerView.swift
//  Playground
//
//  Created by Michael Mosler-Krings on 02.08.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit

/* ****************************************************************
 * Picker view base class for Course Type and Course Number picker.
 * It implements all methods required by protocol and must be
 * feeded with actual data to present only to create a particular
 * instance.
 * ****************************************************************/
class CourseDetailsBasePickerView: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var data: [String] = []
    
    func awakeFromNib(withData data: [String]) {
        super.awakeFromNib()
        dataSource = self
        delegate = self
        self.data = data
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row]
    }
}

/* ****************************************************************
 * Course Type picker view.
 * ****************************************************************/
class CourseTypePickerView: CourseDetailsBasePickerView  {
    override func awakeFromNib() {
        super.awakeFromNib(withData: courseTypes)
    }
}

/* ****************************************************************
 * Course Number picker view.
 * ****************************************************************/
class CourseNumberPickerView: CourseDetailsBasePickerView {
    override func awakeFromNib() {
        super.awakeFromNib(withData: courseNumbers)
    }
}
