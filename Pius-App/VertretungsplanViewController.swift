//
//  VertretungsplanViewController.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class VertretungsplanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ExpandableHeaderViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tickerTextScrollView: UIScrollView!
    @IBOutlet weak var additionalTextScrollView: UIScrollView!
    @IBOutlet weak var tickerTextPageControl: UIPageControl!
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var tickerTextLabel: UILabel!
    @IBOutlet weak var additionalTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var data: [VertretungsplanForDate] = [];
    var selected: IndexPath?;
    var currentHeader: ExpandableHeaderView?;

    func doUpdate(with vertretungsplan: Vertretungsplan) {
        self.data = vertretungsplan.vertretungsplaene;
        
        DispatchQueue.main.async {
            self.currentDateLabel.text = vertretungsplan.lastUpdate;
            self.tickerTextLabel.text = StringHelper.replaceHtmlEntities(input: vertretungsplan.tickerText);
            self.tickerTextScrollView.contentSize = CGSize(width: 343, height: 70);
            
            if (vertretungsplan.hasAdditionalText()) {
                self.additionalTextLabel.text = StringHelper.replaceHtmlEntities(input: vertretungsplan.additionalText);
                self.tickerTextScrollView.contentSize = CGSize(width: 686, height: 70);
                self.additionalTextScrollView.contentSize = CGSize(width: 343, height: 140);
                self.tickerTextPageControl.numberOfPages = 2;
            } else {
                self.tickerTextPageControl.numberOfPages = 1;
            }
            
            self.tableView.reloadData();
            self.activityIndicator.stopAnimating();
        }
    }
    
    private func getVertretungsplanFromWeb() {
        let vertretungsplanLoader = VertretungsplanLoader(forGrade: nil);
        
        // Clear all data.
        currentHeader = nil;
        selected = nil;
        
        vertretungsplanLoader.load(self.doUpdate);        
    }

    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        getVertretungsplanFromWeb();
        sender.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        self.tickerTextScrollView.delegate = self;
        self.getVertretungsplanFromWeb();
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControlEvents.valueChanged);
        scrollView.addSubview(refreshControl);
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tickerTextPageControl.currentPage = Int(scrollView.contentOffset.x / CGFloat(343));
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selected = indexPath;
        return indexPath;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vertretungsplanDetailViewController = segue.destination as? VertretungsplanDetailViewController, let selected = self.selected {
            vertretungsplanDetailViewController.gradeItem = data[selected.section].gradeItems[selected.row];
            vertretungsplanDetailViewController.date = data[selected.section].date;
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return data[section].gradeItems.count;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (data[indexPath.section].expanded) {
            return 44;
        } else {
            return 0;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView();
        header.customInit(title: data[section].date, section: section, delegate: self);
        return header;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")!;
        cell.textLabel?.text = data[indexPath.section].gradeItems[indexPath.row].grade;
        return cell;
    }
    
    // Toggles section headers. If a new header is expanded the previous one when different
    // from the current one is collapsed.
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        // If another than the current section is selected hide the current
        // section.
        if (currentHeader != nil && currentHeader != header) {
            let currentSection = currentHeader!.section!;
            data[currentSection].expanded = false;
            
            tableView.beginUpdates();
            for i in 0 ..< data[currentSection].gradeItems.count {
                tableView.reloadRows(at: [IndexPath(row: i, section: currentSection)], with: .automatic)
            }
            tableView.endUpdates();
        }

        // Expand/collapse the selected header depending on it's current state.
        currentHeader = header;
        data[section].expanded = !data[section].expanded;
        
        tableView.beginUpdates();
        for i in 0 ..< data[section].gradeItems.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates();
    }
}
