//
//  MyCoursesTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 21.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class MyCoursesTableViewCell: UITableViewCell {
    @IBOutlet weak var deleteButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    private var deleteButtonActionDelegate: (UIButton) -> Void = { _ in };
    
    public var row: Int {
        set(value) {
            deleteButton.tag = value;
        }
        
        get {
            return deleteButton.tag;
        }
    }

    func setContent(forRow row: Int, course: String, inEditMode: Bool) {
        self.row = row;
        label.text = course;
        deleteButtonLeading.constant = (inEditMode) ? 4 : -(deleteButton.frame.width + 4);
    }

    @objc func deleteButtonAction(sender: UIButton) {
        self.deleteButtonActionDelegate(sender);
    }

    func setDeleteAction(action: @escaping (UIButton) -> Void) {
        deleteButtonActionDelegate = action;
        deleteButton.addTarget(self, action: #selector(deleteButtonAction(sender:)), for: .touchUpInside);
    }
}
