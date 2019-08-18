//
//  NewsTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

/*
 * Base class for all embedded table views. This class makes sure
 * that table view and its containing views gets properly resized
 * when data has been loaded into table.
 */
class TodayItemTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            invalidateIntrinsicContentSize()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}

/*
 * News table view show up to 6 news items with a preview image.
 * When selecting one item article is opened in a modal popover.
 */
class NewsTableView: TodayItemTableView, UITableViewDelegate, UIPopoverPresentationControllerDelegate {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
        dataSource = TodayV2TableViewController.shared.dataSource(forType: .news)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NewsTableViewCell, let href = cell.href, let url = URL(string: href) else { return }
        TodayV2TableViewController.shared.controller?.perform(segue: "showNews", with: url, presentModally: true)
        cell.isSelected = false
    }
}

class CalendarTableView: TodayItemTableView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = TodayV2TableViewController.shared.dataSource(forType: .calendar)
    }
}
