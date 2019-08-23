//
//  PostingsTableDataSource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 19.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

class PostingsTableDataSource: NSObject, UITableViewDataSource, TodayItemDataSource {
    private var observer: TodayItemContainer?
    private var _postingsItems: PostingsItems?
    private let postingsLoader: PostingsLoader = PostingsLoader()

    private var data: [PostingsItem] {
        get {
            if let postingsItems = _postingsItems {
                return postingsItems
            } else {
                return []
            }
        }
    }

    private func doUpdate(with postingsItems: PostingsItems?, online: Bool) {
        let hadError = postingsItems == nil
        if !hadError, let postingsItems = postingsItems {
            _postingsItems = postingsItems
        } else {
            _postingsItems = nil
        }
        
        observer?.didLoadData(self)
    }
    
    func needsShow() -> Bool {
        return data.count > 0
    }
    
    func willTryLoading() -> Bool {
        return true
    }
    
    func loadData(_ observer: TodayItemContainer) {
        self.observer = observer
        postingsLoader.load(doUpdate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postingsItemCell") as! PostingsTableViewCell
        cell.item = data[indexPath.row]
        return cell

    }
}
