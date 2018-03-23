//
//  VertretungsplanViewController.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class VertretungsplanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ExpandableHeaderViewDelegate {

    @IBOutlet weak var tickerTextScrollView: UIScrollView!
    @IBOutlet weak var additionalTextScrollView: UIScrollView!
    @IBOutlet weak var tickerTextPageControl: UIPageControl!
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var tickerTextLabel: UILabel!
    @IBOutlet weak var additionalTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var data: [Vertretungsplan] = [];
    var selected: IndexPath?;
    var currentHeader: ExpandableHeaderView?;

    private func getVertretungsplanFromWeb() {
        let baseUrl = URL(string: "https://pius-gateway.eu-de.mybluemix.net/vertretungsplan");
        
        let task = URLSession.shared.dataTask(with: baseUrl!) {
            (data, response, error) in
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any];
                    
                    // Extract ticker text and date of last update. Then dispatch update of label text.
                    if let json = jsonSerialized, let tickerText = json["tickerText"], let lastUpdate = json["lastUpdate"] {
                        DispatchQueue.main.async {
                            self.currentDateLabel.text = lastUpdate as? String;
                            self.tickerTextLabel.text = StringHelper.replaceHtmlEntities(input:  tickerText as? String);
                            self.tickerTextScrollView.contentSize = CGSize(width: 343, height: 70);
                        }
                    }
                    
                    if let json = jsonSerialized, let additionalText = json["_additionalText"] {
                        DispatchQueue.main.async {
                            self.additionalTextLabel.text = StringHelper.replaceHtmlEntities(input: additionalText as? String);
                            // self.additionalTextLabel.height
                            self.tickerTextScrollView.contentSize = CGSize(width: 686, height: 70);
                            self.additionalTextScrollView.contentSize = CGSize(width: 343, height: 140);
                        }
                    }
                    
                    // Extract date items...
                    if let json = jsonSerialized, let dateItems = json["dateItems"] as? [Any] {
                        // ... and iterate on all of them. This the top level of our Vertretungsplan.
                        for _dateItem in dateItems {
                            // Convert date item element to dictionary that is indexed by string.
                            let dictionary = _dateItem as! [String: Any];
                            let date = dictionary["title"] as! String;
                            
                            // Iterate on all grades for which a Vetretungsplan for the current date exists.
                            var gradeItems: [GradeItem] = [];
                            for _gradeItem in dictionary["gradeItems"] as! [Any] {
                                // Convert grade item into dictionary that is indexed by string.
                                let dictionary = _gradeItem as! [String: Any];
                                var gradeItem = GradeItem(grade: dictionary["grade"] as! String);
                                
                                // Iterate on all details of a particular Vetretungsplan elements
                                // which gives information on all lessons affected.
                                for _vertretungsplanItem in dictionary["vertretungsplanItems"] as! [Any] {
                                    // Convert vertretungsplan item into a dictionary indexed by string.
                                    // This is the bottom level of our data structure. Each element is
                                    // one of lesson, course, room, teacher (new and old) and an optional
                                    // remark.
                                    var detailItems: DetailItems = [];
                                    let dictionary = _vertretungsplanItem as! [String: Any];
                                    for detailItem in dictionary["detailItems"] as! [String] {
                                        detailItems.append(detailItem);
                                    }

                                    gradeItem.vertretungsplanItems.append(detailItems);
                                }
                                
                                // Done for the current grade.
                                gradeItems.append(gradeItem);
                            }

                            // Done for the current date.
                            self.data.append(Vertretungsplan(date: date, gradeItems: gradeItems, expanded: false));
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData();
                        }
                    }
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        task.resume();
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        self.tickerTextScrollView.delegate = self;
        self.getVertretungsplanFromWeb();
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
