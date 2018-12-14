//
//  TodayTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 22.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

protocol TodaySubTableViewDelegate {
    var controller: TodayTableViewController? { get set };
    
    func needsShow() -> Bool;
    func loadData(controller: TodayTableViewController, sender: UITableView);
}

protocol TodaySubTableLoadedDelegate {
    func doneLoadingSubTable();
}

class TodayTableViewController: UITableViewController, ShowNewsArticleDelegate, ModalDismissDelegate, TodaySubTableLoadedDelegate {
    private var pendingLoads: Int = 4;
    private var statusBarShouldBeHidden: Bool = false;
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden;
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var postingsHeaderLabel: UILabel!
    @IBOutlet weak var postingsView: UIView!
    @IBOutlet weak var postingsTableView: TodayPostingsTableView!
    
    @IBOutlet weak var dashboardViewHeaderLabel: UILabel!
    @IBOutlet weak var dashboardView: UIView!
    @IBOutlet weak var dashboardTableView: TodayDashboardTableView!
    
    @IBOutlet weak var calendarViewHeaderLabel: UILabel!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var calendarTableView: TodayCalendarTableView!
    
    @IBOutlet weak var newViewHeaderLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    @IBOutlet weak var newsTableView: NewsTableView!
    
    var newsUrlToShow: URL?;
    
    func doneLoadingSubTable() {
        pendingLoads -= 1;
        
        if pendingLoads <= 0 {
            refreshControl?.endRefreshing();
            activityIndicator.stopAnimating();
        }
    }
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
        
        // Postings
        postingsHeaderLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold);
        postingsTableView.loadData(controller: self, sender: tableView);
        
        // Dashboard
        dashboardViewHeaderLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold);
        dashboardTableView.loadData(controller: self, sender: tableView);
        
        // Calendar
        calendarViewHeaderLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold);
        calendarTableView.loadData(controller: self, sender: tableView);
        
        // Get content for calendar.
        newViewHeaderLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold);
        newsTableView.loadData(controller: self, sender: tableView);
    }

    private func setContentViewLayerProperties(forView view: UIView) {
        let shadowPath = UIBezierPath(rect: view.bounds)

        view.layer.borderColor = UIColor.lightGray.cgColor;
        view.layer.borderWidth = 1;
        view.layer.shadowColor = UIColor.lightGray.cgColor;
        view.layer.shadowOffset = CGSize(width: 0, height: 0.5);
        view.layer.shadowOpacity = 0.7;
        view.layer.shadowRadius = 4;
        view.layer.shadowPath = shadowPath.cgPath;
        view.layer.masksToBounds = false;
    }

    override func viewWillLayoutSubviews() {
        setContentViewLayerProperties(forView: postingsView);
        setContentViewLayerProperties(forView: dashboardView);
        setContentViewLayerProperties(forView: calendarView);
        setContentViewLayerProperties(forView: newsView);
    }

    /*
     * ====================================================
     *                Navigation
     * ====================================================
     */

    func show(url: URL) {
        newsUrlToShow = url;
        statusBarShouldBeHidden = true;
        tabBarController?.tabBar.isHidden = true;

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
        tabBarController?.tabBar.isHidden = false;
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }

        view.setNeedsDisplay();
    }

    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */

    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        setHeaderCellContent();

        pendingLoads = 4;
        
        // Reload content.
        postingsTableView.loadData(controller: self, sender: tableView);
        dashboardTableView.loadData(controller: self, sender: tableView);
        calendarTableView.loadData(controller: self, sender: tableView);
        newsTableView.loadData(controller: self, sender: tableView);
    }

    private func setHeaderCellContent() {
        let defaultSystemFont = UIFont.systemFont(ofSize: 14);
        let largeTitleFont = UIFont.systemFont(ofSize: 36, weight: .bold);
        let dateFormatter = DateFormatter();
        let date = Date();
        
        dateFormatter.locale = Locale(identifier: "de-DE");
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
        return 5;
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
        case 1:
            if postingsTableView.needsShow() {
                return (postingsTableView.contentSize.height > 0) ? postingsTableView.contentSize.height + 29 + 4 + 8 + 8: 54;
            } else {
                return 0;
            }
        case 2:
            if dashboardTableView.needsShow() {
                return (dashboardTableView.contentSize.height > 0) ? dashboardTableView.contentSize.height + 29 + 4 + 8 + 8: 54;
            } else {
                return 0;
            }
        case 3:
            if calendarTableView.needsShow() {
                return (calendarTableView.contentSize.height > 0) ? calendarTableView.contentSize.height + 29 + 4 + 8 + 8: 54;
            } else {
                return 0;
            }
        case 4:
            if newsTableView.needsShow() {
                return (newsTableView.contentSize.height > 0) ? newsTableView.contentSize.height + 29 + 4 + 8 + 8: 500;
            } else {
                return 0;
            }
        default: return 0;
        }
    }
}
