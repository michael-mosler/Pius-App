//
//  VertretungsplanViewController.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class VertretungsplanViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ExpandableHeaderViewDelegate {

    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var tickerTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var data: [Vertretungsplan] = [];

    /*
        Vertretungsplan(date: "Freitag, 09.03.2018", grades: ["5B", "6C"], expanded: false),
        Vertretungsplan(date: "Montag, 12.03.2018", grades: ["7A", "8C"], expanded: false)
    ];
    */
    
    private func getVertretungsplanFromWeb() {
        let baseUrl = URL(string: "https://pius-gateway.eu-de.mybluemix.net/vertretungsplan");
        
        let task = URLSession.shared.dataTask(with: baseUrl!) {
            (data, response, error) in
            if let data = data {
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                    if let json = jsonSerialized, let tickerText = json["tickerText"], let lastUpdate = json["lastUpdate"] {
                        DispatchQueue.main.async {
                            self.currentDateLabel.text = lastUpdate as? String;
                            self.tickerTextLabel.text = tickerText as? String;
                        }
                    }
                    
                    if let json = jsonSerialized, let dateItems = json["dateItems"] as? [Any] {
                        for dateItem in dateItems {
                            let dictionary = dateItem as! [String: Any];
                            let date = dictionary["title"] as! String;
                            
                            var grades: [String] = [];
                            for gradeItem in dictionary["gradeItems"] as! [Any] {
                                let dictionary = gradeItem as! [String: Any];
                                let grade = dictionary["grade"] as! String;
                                grades.append(grade);
                            }

                            self.data.append(Vertretungsplan(date: date, grades: grades, expanded: false));
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
        self.getVertretungsplanFromWeb();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count;
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].grades.count;
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
        cell.textLabel?.text = data[indexPath.section].grades[indexPath.row];
        return cell;
    }
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        data[section].expanded = !data[section].expanded;
        
        tableView.beginUpdates();
        for i in 0 ..< data[section].grades.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates();
    }
}
