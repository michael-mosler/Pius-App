//
//  DateListCollectionViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 05.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

protocol CalendarDataDelegate {
    func allItems() -> [Any]
    func monthItems() -> [MonthItem]
    func inSearchMode() -> Bool
    func selectedMonth() -> Int?
}

class DateListCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    private struct tags {
        enum tableView: Int {
            case dayLabelInTableViewCell = 1
            case eventLabelInTablewViewCell = 2
        }
    }
    
    @IBOutlet weak var dateListTableView: UITableView!
    private var calendarDataDelegate: CalendarDataDelegate?;
    private var forMonth: Int?;
    
    func customInit(delegate: CalendarDataDelegate, forMonth month: Int) {
        calendarDataDelegate = delegate;
        forMonth = month;
        dateListTableView.reloadData();
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: layoutAttributes.frame.height)
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.required)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        autoLayoutAttributes.frame = autoLayoutFrame

        return autoLayoutAttributes
    }

    // Returns the number of rows in the current day list table view. Actual calculation depends
    // on the mode the view is in.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let delegate = calendarDataDelegate, let _forMonth = forMonth  else { return 0 };
        return (delegate.inSearchMode()) ? delegate.allItems().count : delegate.monthItems()[_forMonth].dayItems.count;
    }

    // Return a cell of day list table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let delegate = calendarDataDelegate else { return UITableViewCell(); }

        var cell: UITableViewCell;
        if (delegate.inSearchMode()) {
            let _item = delegate.allItems()[indexPath.row];
            if let item = _item as? String {
                cell = dateListTableView.dequeueReusableCell(withIdentifier: "MonthName")!;
                cell.textLabel?.text = item;
            } else {
                let item = _item as! DayItem;
                cell = dateListTableView.dequeueReusableCell(withIdentifier: "DateEntry")!;
                let dayLabel = cell.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel;
                let eventLabel = cell.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel;
                
                dayLabel.attributedText = NSMutableAttributedString(string: item.detailItems[0], attributes: [NSAttributedString.Key.foregroundColor: Config.colorPiusBlue]);
                
                // Event text; hightlight when range is given.
                let text = NSMutableAttributedString(string: item.detailItems[1]);
                if let _hightlight = item.highlight {
                    text.addAttribute(NSAttributedString.Key.backgroundColor, value: Config.colorYellow, range: _hightlight);
                }
                eventLabel.attributedText = text;
            }
        } else {
            cell = dateListTableView.dequeueReusableCell(withIdentifier: "DateEntry")!;
            let dayLabel = cell.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel;
            let eventLabel = cell.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel;
            
            let detailItems = delegate.monthItems()[forMonth!].dayItems[indexPath.row].detailItems;
            
            dayLabel.attributedText = NSMutableAttributedString(string: detailItems[0], attributes: [NSAttributedString.Key.foregroundColor: Config.colorPiusBlue]);
            eventLabel.attributedText = NSMutableAttributedString(string: detailItems[1]);
        }
        
        return cell;
    }
}
