//
//  TodayPostingsTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 09.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayPostingsTableView: UITableView, UITableViewDelegate, UITableViewDataSource, TodaySubTableViewDelegate {
    var controller: TodayTableViewController?
    
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

    func needsShow() -> Bool {
        return data.count > 0;
    }

    /*
     * ====================================================
     *                  Data Loader
     * ====================================================
     */
    
    private func doUpdate(with postingsItems: PostingsItems?, online: Bool) {
        let hadError = postingsItems == nil;
        if !hadError, let postingsItems_ = postingsItems {
            self.postingsItems = postingsItems_;
        }
        
        DispatchQueue.main.async {
            self.parentTableView?.beginUpdates();
            self.reloadData();
            self.layoutIfNeeded();
            self.parentTableView?.endUpdates();
            self.controller?.doneLoadingSubTable();
        }
    }
    
    func loadData(controller: TodayTableViewController, sender: UITableView) {
        self.controller = controller;
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
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: "postingsItem") as! TodayPostingsDetailsCell;
        cell.setContent(message: data[indexPath.row].message, date: data[indexPath.row].timestamp);
        return cell;
    }
}
