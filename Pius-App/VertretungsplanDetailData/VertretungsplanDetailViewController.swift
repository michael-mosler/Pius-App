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
    @IBOutlet weak var detaileCollectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var gradeItem: GradeItem?;
    var date: String?;
    var index: Int?;
    
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
        return 2 * (gradeItem?.vertretungsplanItems.count)!;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?;

        if (indexPath.row % 2 == 0) {
            index = indexPath.row / 2;

            cell = detailsTableView.dequeueReusableCell(withIdentifier: "course");
            cell?.textLabel?.text = "Fach/Kurs: " + StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[index!][2]);
            cell?.textLabel?.text! += ", ";
            cell?.textLabel?.text! += (gradeItem?.vertretungsplanItems[index!][0])!;
            cell?.textLabel?.text! += " Stunde";
        }

        if (indexPath.row % 2 == 1) {
            cell = detailsTableView.dequeueReusableCell(withIdentifier: "details");
        }

        return cell!;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3;
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detail", for: indexPath) as! DetailCollectionViewCell;
        
        switch indexPath.item {
        case 0:
            // Type
            cell.label.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[index!][1]));
        case 1:
            // Room
            cell.label.attributedText = getRoomText(room: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[index!][3]));
        default:
            // Teachers
            cell.label.attributedText = getTeacherText(oldTeacher: (gradeItem?.vertretungsplanItems[index!][5]), newTeacher: gradeItem?.vertretungsplanItems[index!][4])
        }

        return cell;
    }

}
