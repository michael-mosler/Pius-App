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
    
    var gradeItem: GradeItem?;
    var index: Int?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = gradeItem!.grade;

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
            cell?.textLabel?.text = "Fach/Kurs: " + (gradeItem?.vertretungsplanItems[index!][2])!;
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
        return 4;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detail", for: indexPath) as! DetailCollectionViewCell;
        
        var detailIndex: Int;
        switch indexPath.item {
        case 0:
            detailIndex = 1;
            break;
        case 1:
            detailIndex = 3;
            break;
        case 2:
            detailIndex = 4;
            break;
        default:
            detailIndex = 5;
            break;
        }

        cell.label.text = gradeItem?.vertretungsplanItems[index!][detailIndex];
        return cell;
    }

}
