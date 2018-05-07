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
    @IBOutlet weak var tickerTextPageControl: UIPageControl!
    
    @IBOutlet weak var tickerText: UITextView!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var additionalText: UITextView = UITextView()
    
    var data: [VertretungsplanForDate] = [];
    var selected: IndexPath?;
    var currentHeader: ExpandableHeaderView?;

    func doUpdate(with vertretungsplan: Vertretungsplan) {
        self.data = vertretungsplan.vertretungsplaene;
        
        DispatchQueue.main.async {
            self.currentDateLabel.text = vertretungsplan.lastUpdate;
            self.tickerText.text = StringHelper.replaceHtmlEntities(input: vertretungsplan.tickerText);
            
            if (true || vertretungsplan.hasAdditionalText()) {
                // Configure a text view for additional text and add it as sub-view to ticker
                self.additionalText.frame = CGRect(x: 343, y: 0, width: 343, height: 70);
                self.additionalText.font = .systemFont(ofSize: 15);
                self.additionalText.isEditable = false;
                
                //self.additionalText.text = StringHelper.replaceHtmlEntities(input: vertretungsplan.additionalText);
                self.additionalText.text = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";

                self.tickerTextScrollView.contentSize = CGSize(width: 686, height: 70);
                self.tickerTextScrollView.addSubview(self.additionalText);
                self.tickerTextPageControl.numberOfPages = 2;
            } else {
                self.tickerTextScrollView.contentSize = CGSize(width: 343, height: 70);
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == tickerTextScrollView) {
            let pageNumber = round(scrollView.contentOffset.x / CGFloat(343));
            tickerTextPageControl.currentPage = Int(pageNumber);
        }
    }
    
    @objc func refreshScrollView(_ sender: UIRefreshControl) {
        getVertretungsplanFromWeb();
        sender.endRefreshing()
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        tickerTextScrollView.delegate = self;
        getVertretungsplanFromWeb();
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControlEvents.valueChanged);
        scrollView.addSubview(refreshControl);
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
