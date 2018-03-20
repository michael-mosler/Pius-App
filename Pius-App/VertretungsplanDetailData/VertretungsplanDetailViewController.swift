//
//  VertretungsplanDetailViewController.swift
//  Pius-App
//
//  Created by Michael on 16.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class VertretungsplanDetailViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var gradeItem: GradeItem?;
    var date: String?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = gradeItem!.grade;
        dateLabel.text = date;

        detailsTableView.delegate = self;
        detailsTableView.dataSource = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 * (gradeItem?.vertretungsplanItems.count)!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?;
        let itemIndex: Int = indexPath.row / 3;

        if (indexPath.row % 3 == 0) {
            cell = detailsTableView.dequeueReusableCell(withIdentifier: "course");
            cell?.textLabel?.text = "Fach/Kurs: " + StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][2]);
            cell?.textLabel?.text! += ", ";
            cell?.textLabel?.text! += (gradeItem?.vertretungsplanItems[itemIndex][0])!;
            cell?.textLabel?.text! += " Stunde";
        }

        if (indexPath.row % 3 == 1) {
            cell = detailsTableView.dequeueReusableCell(withIdentifier: "details");
            if (cell != nil) {
                // This is the itemIndex this cell is know displaying.
                (cell as! DetailsCellTableViewCell).itemIndex = itemIndex;

                // Reload content for this cell when it had already been used.
                (cell as! DetailsCellTableViewCell).collectionView?.reloadData();
            }
        }

        if (indexPath.row % 3 == 2) {
            let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6]);
            cell = detailsTableView.dequeueReusableCell(withIdentifier: "comment");
            cell?.textLabel?.text = text;
        }

        return cell!;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height : CGFloat;
        
        if (indexPath.row % 3 == 0) {
            height = 36;
        } else if (indexPath.row % 3 == 2) {
            let itemIndex: Int = indexPath.row / 3;
            let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6]);
            height = (text == "") ? 0 : 30;
        } else {
            height = 30;
        }
        
        return height;
    }

    func getTeacherText(oldTeacher: String?, newTeacher: String?) -> NSAttributedString {
        guard let oldTeacher = oldTeacher, let newTeacher = newTeacher else { return NSMutableAttributedString()  }

        let textRange = NSMakeRange(0, oldTeacher.count);
        let attributedText = NSMutableAttributedString(string: oldTeacher + " → " + newTeacher);
        attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: textRange);
        return attributedText;
        
    }

    func getRoomText(room: String?) -> NSAttributedString {
        guard let room = room, room != "" else { return NSAttributedString(string: "") }

        let attributedText = NSMutableAttributedString(string: room);

        let index = room.index(of: "→");
        if (index != nil) {
            let length = room.distance(from: room.startIndex, to: room.index(before: index!));
            let strikeThroughRange = NSMakeRange(0, length);
            attributedText.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: strikeThroughRange);
        }
        
        return attributedText;
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detail", for: indexPath) as! DetailCollectionViewCell;
        
        // The cell this collection view is in knows about the item index we need to display.
        let detailsCellTableViewCell = collectionView.superview?.superview as! DetailsCellTableViewCell;
        let itemIndex = detailsCellTableViewCell.itemIndex!;

        // We also need to tell the cell which collection view it is working with.
        detailsCellTableViewCell.collectionView = collectionView;
        
        switch indexPath.item {
        case 0:
            // Type
            cell.label.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][1]));
        case 1:
            // Room
            cell.label.attributedText = getRoomText(room: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][3]));
        default:
            // Teachers
            cell.label.attributedText = getTeacherText(oldTeacher: (gradeItem?.vertretungsplanItems[itemIndex][5]), newTeacher: gradeItem?.vertretungsplanItems[itemIndex][4])
        }

        return cell;
    }

}
