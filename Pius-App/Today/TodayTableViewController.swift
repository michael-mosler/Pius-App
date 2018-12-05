//
//  TodayTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 22.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

protocol ModalDismissDelegate {
    func hasDismissed();
}

class TodayTableViewController: UITableViewController, ShowNewsArticleDelegate, ModalDismissDelegate {
    private var statusBarShouldBeHidden: Bool = false;
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden;
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    @IBOutlet weak var headerLabel: UILabel!

    @IBOutlet weak var dashboardView: UIView!
    @IBOutlet weak var dashboardViewHeaderLabel: UILabel!
    @IBOutlet weak var dashboardTableView: TodayDashboardTableView!
    
    @IBOutlet weak var newViewHeaderLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var newsTableView: NewsTableView!
    
    var newsUrlToShow: URL?;
    
    override func viewDidLoad() {
        super.viewDidLoad();

        refreshControl!.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged);

        // Make background of status opaque; by default status bar is presented transparently.
        // When scrolling we do not want to shine through table content as text gets unreadable
        // in this case.
        let view = UIView();
        view.backgroundColor = .white;
        view.frame = UIApplication.shared.statusBarFrame;
        navigationController!.view.addSubview(view);
        
        // Set header content
        setHeaderCellContent();
        
        // Dashboard
        dashboardViewHeaderLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold);
        dashboardTableView.loadData(sender: tableView);
        setContentViewLayerProperties(forView: dashboardView);
        
        // Get content for calendar.
        newViewHeaderLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold);
        newsTableView.loadData(showNewsDelegate: self, sender: tableView);
        setContentViewLayerProperties(forView: newsView);
    }

    private func setContentViewLayerProperties(forView view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor;
        view.layer.borderWidth = 1;
        view.layer.shadowColor = UIColor.lightGray.cgColor;
        view.layer.shadowOffset = CGSize(width: 1, height: 3);
        view.layer.shadowOpacity = 0.7;
        view.layer.shadowRadius = 4;
        view.layer.masksToBounds = true;
    }

    /*
     * ====================================================
     *                Navigation
     * ====================================================
     */

    func prepareShow(of url: URL) {
        self.newsUrlToShow = url;
    }
    
    func show() {
        guard newsUrlToShow != nil else { return; }
        statusBarShouldBeHidden = true;

        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }

        performSegue(withIdentifier: "showNews", sender: self);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? NewsArticleViewController else { return; }
        destination.delegate = self;
        destination.urlToShow = newsUrlToShow;
    }

    func hasDismissed() {
        statusBarShouldBeHidden = false;
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */

    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        setHeaderCellContent();

        // Reload content.
        dashboardTableView.loadData(sender: tableView);
        newsTableView.loadData(showNewsDelegate: self, sender: tableView);

        sender.endRefreshing()
    }

    private func setHeaderCellContent() {
        let defaultSystemFont = UIFont.systemFont(ofSize: 14);
        let largeTitleFont = UIFont.systemFont(ofSize: 36, weight: .bold);
        let dateFormatter = DateFormatter();
        let date = Date();
        
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, d. MMMM");
        let dateString = NSMutableAttributedString(string: dateFormatter.string(from: date), attributes: [NSAttributedString.Key.font: defaultSystemFont]);
        let todayString = NSMutableAttributedString(string: "Heute", attributes: [NSAttributedString.Key.font: largeTitleFont]);
        dateString.append(NSMutableAttributedString(string: "\n"));
        dateString.append(todayString);
        headerLabel.attributedText = dateString;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0;
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(indexPath.row) {
        case 0: return 105;
        case 1: return (newsTableView.contentSize.height > 0) ? dashboardTableView.contentSize.height + 29 + 4 + 8 + 8: 100;
        case 2: return (newsTableView.contentSize.height > 0) ? newsTableView.contentSize.height + 29 + 4 + 8 + 8: 500;
        default: return 0;
        }
    }
}
