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
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var tickerText: UITextView!
    @IBOutlet weak var additionalText: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var offlineLabel: UILabel!
    @IBOutlet weak var offlineFooterView: UIView!
    
    private var data: [VertretungsplanForDate] = [];
    private var selected: IndexPath?;
    private var currentHeader: ExpandableHeaderView?;
    
    private var tickerTextScrollViewWidth: Int?;

    func doUpdate(with vertretungsplan: Vertretungsplan?, online: Bool) {
        if (vertretungsplan == nil) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Vertretungsplan", message: "Die Daten konnten leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert);
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true);
                }));
                self.present(alert, animated: true, completion: nil);

                if (self.offlineLabel != nil && self.offlineFooterView != nil) {
                    self.offlineLabel.isHidden = online;
                    self.offlineFooterView.isHidden = online;
                }
            }
        } else {
            self.data = vertretungsplan!.vertretungsplaene;
            
            DispatchQueue.main.async {
                self.currentDateLabel.text = vertretungsplan!.lastUpdate;
                self.tickerText.text = StringHelper.replaceHtmlEntities(input: vertretungsplan!.tickerText);
                
                if (vertretungsplan!.hasAdditionalText()) {
                    self.additionalText.text = StringHelper.replaceHtmlEntities(input: vertretungsplan!.additionalText);
                    self.tickerTextScrollView.isScrollEnabled = true;
                    self.tickerTextPageControl.numberOfPages = 2;
                } else {
                    self.tickerTextScrollView.isScrollEnabled = false;
                    self.tickerTextPageControl.numberOfPages = 1;
                }
                
                self.tableView.reloadData();
                self.activityIndicator.stopAnimating();

                self.offlineLabel.isHidden = online;
                self.offlineFooterView.isHidden = online;
            }
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

    // After sub-views have been layouted content size of ticket text
    // scroll view can be set. As we do not add UIText programmatically
    // scroll view does not know about the correct size from story
    // board.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        tickerTextScrollView.contentSize = CGSize(width: 2 * tickerTextScrollViewWidth!, height: 70);
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        tickerTextScrollView.delegate = self;
        tickerTextScrollViewWidth = Config.screenWidth - 32;

        getVertretungsplanFromWeb();
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshScrollView(_:)), for: UIControl.Event.valueChanged);
        scrollView.addSubview(refreshControl);
    }

    // Sets current page of page control when ticker text is
    // scrolled horizontally.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView == tickerTextScrollView) {
            let currentPage = round(scrollView.contentOffset.x / CGFloat(tickerTextScrollViewWidth!));
            tickerTextPageControl.currentPage = Int(currentPage);
        }
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
        header.customInit(title: data[section].date, userInteractionEnabled: data[section].gradeItems.count > 0, section: section, delegate: self);
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
