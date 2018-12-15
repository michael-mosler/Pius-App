//
//  NewsTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 27.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

protocol ShowNewsArticleDelegate {
    func show(url: URL);
}

class NewsTableView: UITableView, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, TodaySubTableViewDelegate {
    var controller: TodayTableViewController?
    
    private var parentTableView: UITableView?;
    private let newsLoader = NewsLoader();
    private var newsItems: NewsItems?;

    /*
     * ====================================================
     *                  Data Loader
     * ====================================================
     */
    
    func needsShow() -> Bool {
        return true;
    }

    func willTryLoading() -> Bool {
        return true;
    }

    private func doUpdate(with newsItems: NewsItems?, online: Bool) {
        if newsItems == nil {
            self.newsItems = [];
        } else {
            self.newsItems = newsItems;
        }
        
        DispatchQueue.main.async {
            self.dataSource = self;
            self.delegate = self;

            self.parentTableView?.beginUpdates();
            self.reloadData();
            self.layoutSubviews();
            self.parentTableView?.endUpdates();
            self.controller?.doneLoadingSubTable();
        }
    }

    func loadData(controller: TodayTableViewController, sender: UITableView) {
        self.controller = controller;
        parentTableView = sender;
        newsLoader.load(doUpdate);
    }

    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let newsItems = self.newsItems else { return 0; }
        return newsItems.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newsItems = self.newsItems, let text = newsItems[indexPath.row].text else { return UITableViewCell(); }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItem") as! NewsTableViewCell;
        cell.setImageUrl(imgUrl: newsItems[indexPath.row].imgUrl);

        let itemText = NSMutableAttributedString(string: "");
        if let heading = newsItems[indexPath.row].heading {
            let headingFont = UIFont.systemFont(ofSize: 15, weight: .bold);
            itemText.append(NSAttributedString(string: heading, attributes: [NSAttributedString.Key.font: headingFont]));
            itemText.append(NSAttributedString(string: "\n"));
        }
        itemText.append(NSAttributedString(string: text));
        cell.newsItemTextLabel.attributedText = itemText;
        
        cell.href = newsItems[indexPath.row].href;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell, let href = cell.href, let url = URL(string: href) else { return; };
        controller?.show(url: url);
    }
}
