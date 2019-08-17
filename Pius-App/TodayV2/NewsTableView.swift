//
//  NewsTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class NewsTableView: UITableView, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, TodayItem {
    var container: TodayItemContainer?
    
    private let newsLoader = NewsLoader()
    private var newsItems: NewsItems?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = self
        delegate = self
    }
    /*
     * ====================================================
     *                  Data Loader
     * ====================================================
     */
    
    func needsShow() -> Bool {
        // When newItems is nil load has not returned yet. In this case
        // we suppose that news must be shown. When load fails
        // newsItems will be set to empty array and number of
        // items in table becomes 0.
        // Without this logic due to fixed image size a constraint
        // error would be thrown on start up.
        return newsItems?.count ?? 1 > 0
    }
    
    func willTryLoading() -> Bool {
        return true
    }
    
    private func doUpdate(with newsItems: NewsItems?, online: Bool) {
        if newsItems == nil {
            self.newsItems = []
        } else {
            self.newsItems = newsItems
        }
        
        DispatchQueue.main.async {
            // self.parentTableView?.beginUpdates()
            // self.reloadData()
            // self.layoutSubviews()
            // self.parentTableView?.endUpdates()
            self.container?.didLoadData(self)
        }
    }
    
    func loadData(container: TodayItemContainer) {
        self.container = container
        newsLoader.load(doUpdate)
    }
    
    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let newsItems = self.newsItems else { return 0 }
        NSLog("#items = \(newsItems.count)")
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newsItems = newsItems else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItemCell") as! NewsTableViewCell
        cell.newsItem = newsItems[indexPath.row]
        return cell
    }
    
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell, let href = cell.href, let url = URL(string: href) else { return }
        container?.show(url: url)
    }
    */
}
