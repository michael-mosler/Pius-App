//
//  NewsTableDataSource.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 18.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

/*
 * Data source for news tablew view on Today page. This class also implements
 * UITableViewDataSource interface for this table.
 */
class NewsTableDataSource: NSObject, UITableViewDataSource, TodayItemDataSourceProtocol {
    
    private var observer: TodayItemContainer?
    private var newsItems: NewsItems = []
    private let newsLoader: NewsLoader = NewsLoader()
    
    private func doUpdate(with items: NewsItems?, online: Bool) {
        if let items = items {
            newsItems = items
        } else {
            newsItems = []
        }
        
        observer?.didLoadData(self)
    }
    
    func loadData(_ observer: TodayItemContainer) {
        self.observer = observer
        newsLoader.load(doUpdate)
    }

    func needsShow() -> Bool {
        return newsItems.count > 0
    }
    
    func willTryLoading() -> Bool {
        return true
    }

    func isEmpty() -> Bool {
        return newsItems.count == 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItemCell") as! NewsTableViewCell
        cell.newsItem = newsItems[indexPath.row]
        return cell
    }
}
