//
//  DashboardViewController.swift
//  Pius-App
//
//  Created by Michael on 28.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ExpandableHeaderViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tickerTextPageControl: UIPageControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tickerTextScrollView: UIScrollView!
    @IBOutlet weak var additionalTextScrollView: UIScrollView!
    
    @IBOutlet weak var tickerTextLabel: UILabel!
    @IBOutlet weak var additionalTextLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    var data: [VertretungsplanForDate] = [];
    var selected: IndexPath?;
    var currentHeader: ExpandableHeaderView?;

    let rowsPerItem = 4;
    
    func doUpdate(with vertretungsplan: Vertretungsplan) {
        self.data = vertretungsplan.vertretungsplaene;
        
        DispatchQueue.main.async {
            self.currentDateLabel.text = vertretungsplan.lastUpdate;
            self.tickerTextLabel.text = vertretungsplan.tickerText;
            self.tickerTextScrollView.contentSize = CGSize(width: 343, height: 70);
            
            if (vertretungsplan.hasAdditionalText()) {
                self.additionalTextLabel.text = vertretungsplan.additionalText;
                self.tickerTextScrollView.contentSize = CGSize(width: 686, height: 70);
                self.additionalTextScrollView.contentSize = CGSize(width: 343, height: 140);
                self.tickerTextPageControl.numberOfPages = 2;
            } else {
                self.tickerTextPageControl.numberOfPages = 1;
            }
            
            self.tableView.reloadData();
            self.activityIndicator.stopAnimating();
        }
    }
    
    private func getVertretungsplanFromWeb() {
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: "7B");
        
        // Clear all data.
        currentHeader = nil;
        selected = nil;
        
        vertretungsplanLoader.load(self.doUpdate);
    }

    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        getVertretungsplanFromWeb();
        sender.endRefreshing()
    }

    func toggleSection(header: ExpandableHeaderView, section: Int) {
        // If another than the current section is selected hide the current
        // section.
        if (currentHeader != nil && currentHeader != header) {
            let currentSection = currentHeader!.section!;
            data[currentSection].expanded = false;
            
            tableView.beginUpdates();
            for i in 0 ..< data[currentSection].gradeItems[0].vertretungsplanItems.count {
                tableView.reloadRows(at: [IndexPath(row: i, section: currentSection)], with: .automatic)
            }
            tableView.endUpdates();
        }
        
        // Expand/collapse the selected header depending on it's current state.
        currentHeader = header;
        data[section].expanded = !data[section].expanded;
        
        tableView.beginUpdates();
        for i in 0 ..< data[section].gradeItems[0].vertretungsplanItems.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates();
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (data[section].gradeItems.count == 0) {
            return 0;
        }

        return 4 * data[section].gradeItems[0].vertretungsplanItems.count;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (data[indexPath.section].expanded) {
            return 44;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView();
        header.customInit(title: data[section].date, section: section, delegate: self);
        return header;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?;
        let itemIndex: Int = indexPath.row / 4;
        let gradeItem: GradeItem? = data[indexPath.section].gradeItems[0];

        switch indexPath.row % rowsPerItem {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "course")!;
            cell?.textLabel?.text = "Fach/Kurs: " + StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][2]);
            cell?.textLabel?.text! += ", ";
            cell?.textLabel?.text! += (gradeItem?.vertretungsplanItems[itemIndex][0])!;
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "details");
            if (cell != nil) {
                // This is the itemIndex this cell is know displaying.
                (cell as! DetailsCellTableViewCell).section = indexPath.section;
                (cell as! DetailsCellTableViewCell).itemIndex = itemIndex;
                
                // Reload content for this cell when it had already been used.
                (cell as! DetailsCellTableViewCell).collectionView?.reloadData();
            }

        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "comment")!;
        }

        return cell!;
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
        let section = detailsCellTableViewCell.section!;
        let gradeItem: GradeItem? = data[section].gradeItems[0];

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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tickerTextScrollView.delegate = self;
        self.getVertretungsplanFromWeb();
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControlEvents.valueChanged);
        scrollView.addSubview(refreshControl);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
