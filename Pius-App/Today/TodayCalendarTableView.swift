//
//  TodayCalendarTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 08.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayCalendarTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    private var hadError = false;
    private var parentTableView: UITableView?;
    private var calendar: Calendar?

    private var data: [DayItem] {
        get {
            if let calendar_ = calendar, calendar_.monthItems.count > 0 {
                return calendar_.monthItems[0].dayItems;
            } else {
                return [];
            }
        }
    }

    /*
     * ====================================================
     *                  Data Loader
     * ====================================================
     */
    
    private func doUpdate(with calendar: Calendar?, online: Bool) {
        hadError = calendar == nil;
        if !hadError, let calendar_ = calendar {
            // Date to filter for. Reduce schedules to the one with the given date.
            let date = Date();
            
            /*
            let dateString = "2018-12-19" // change to your date format
            let dateFormatter1 = DateFormatter()
            dateFormatter1.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter1.date(from: dateString)!
            */
            
            let dateFormatter = DateFormatter();
            
            // 1. Filter month
            dateFormatter.locale = Locale(identifier: "de-DE");
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy");
            var filterDate = dateFormatter.string(from: date);

            var monthItems_ = calendar_.monthItems.filter { $0.fullName == filterDate };
            
            // When list not empty filter first month item's day list.
            if monthItems_.count > 0 {
                dateFormatter.setLocalizedDateFormatFromTemplate("EEEEEE dd.MM.");
                filterDate = dateFormatter.string(from: date);
                let index1 = filterDate.index(filterDate.startIndex, offsetBy: 2);
                let index2 = filterDate.index(after: index1);
                filterDate = filterDate.replacingCharacters(in: index1..<index2, with: "")
                monthItems_[0].dayItems = monthItems_[0].dayItems.filter { $0.detailItems[0] == filterDate }
            }
            
            calendar_.monthItems = monthItems_;
            self.calendar = calendar_;
        }

        DispatchQueue.main.async {
            self.parentTableView?.beginUpdates();
            self.reloadData();
            self.layoutIfNeeded();
            self.parentTableView?.endUpdates();
        }
    }

    func loadData(sender: UITableView) {
        parentTableView = sender;
        delegate = self;
        dataSource = self;
        
        let calendarLoader = CalendarLoader();
        calendarLoader.load(doUpdate);
    }

    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (hadError || data.count == 0) ? 1 : data.count;
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight;
    }
 */

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hadError {
            let cell = dequeueReusableCell(withIdentifier: "loadError")!;
            return cell;
        }
        
        if data.count == 0 {
            let cell = dequeueReusableCell(withIdentifier: "noItems")!;
            return cell;
        }
        
        let cell = dequeueReusableCell(withIdentifier: "calendarItem") as! TodayCalendarDetailsCell;
        cell.setContent(event: data[indexPath.row].detailItems[1]);
        return cell;
    }
}
