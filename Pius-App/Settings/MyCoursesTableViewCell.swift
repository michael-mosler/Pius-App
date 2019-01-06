//
//  MyCoursesTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 21.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class MyCoursesTableViewCell: MGSwipeTableCell { //} UITableViewCell {
    @IBOutlet weak var deleteButtonLeading: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    private var deleteButtonActionDelegate: (MGSwipeTableCell) -> Void = { _ in };
    
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

        self.rightButtons = [
            MGSwipeButton(title: "Löschen", backgroundColor: .red) { (sender: MGSwipeTableCell!) -> Bool in
                self.deleteButtonActionDelegate(sender);
                return true;
            }
        ];
        self.rightSwipeSettings.transition = .drag;
    }

    @objc func deleteButtonAction(sender: UIButton) {
        self.showSwipe(.rightToLeft, animated: true);
    }

    func setDeleteAction(action: @escaping (MGSwipeTableCell) -> Void) {
        deleteButtonActionDelegate = action;
        deleteButton.addTarget(self, action: #selector(deleteButtonAction(sender:)), for: .touchUpInside);
    }
}
