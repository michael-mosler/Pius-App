//
//  TodayPostingsTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 09.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayPostingsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    private var hadError = false;
    private var parentTableView: UITableView?;
    private var postingsItems: PostingsItems?
    
    private var data: [PostingsItem] {
        get {
            if let postingsItems_ = postingsItems {
                return postingsItems_;
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
    
    private func doUpdate(with postingsItems: PostingsItems?, online: Bool) {
        hadError = postingsItems == nil;
        if !hadError, let postingsItems_ = postingsItems {
            self.postingsItems = postingsItems_;
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
        
        let postingsLoader = PostingsLoader();
        postingsLoader.load(doUpdate);
    }

    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count;
        return (hadError || data.count == 0) ? 1 : data.count;
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.rowHeight;
    }
 */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if hadError {
            return UITableViewCell();
            let cell = dequeueReusableCell(withIdentifier: "loadError")!;
            return cell;
        }
        
        if data.count == 0 {
            return UITableViewCell();
            let cell = dequeueReusableCell(withIdentifier: "noItems")!;
            return cell;
        }
        
        let cell = dequeueReusableCell(withIdentifier: "postingsItem") as! TodayPostingsDetailsCell;
        cell.setContent(message: data[indexPath.row].message, date: data[indexPath.row].timestamp);
        return cell;
    }

}
