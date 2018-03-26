//
//  VertretungsplanLoader.swift
//  Pius-App
//
//  Created by Michael on 26.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation
import UIKit;

class VertretungsplanLoader {
    var forGrade: String?
    let baseUrl = URL(string: "https://pius-gateway.eu-de.mybluemix.net/vertretungsplan");

    init(forGrade: String? = nil) {
        self.forGrade = forGrade;
    }
    
    func load(_ update: @escaping (Vertretungsplan) -> Void) {
        let task = URLSession.shared.dataTask(with: baseUrl!) {
            (data, response, error) in
            if let data = data {
                var vertretungsplan: Vertretungsplan = Vertretungsplan();
                
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any];
                    
                    // Extract ticker text and date of last update. Then dispatch update of label text.
                    if let json = jsonSerialized, let _tickerText = json["tickerText"], let _lastUpdate = json["lastUpdate"] {
                        vertretungsplan.tickerText = _tickerText as? String;
                        vertretungsplan.lastUpdate = _lastUpdate as! String;
                    }
                    
                    if let json = jsonSerialized, let _additionalText = json["_additionalText"] {
                        vertretungsplan.additionalText = _additionalText as? String;
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
                            vertretungsplan.vertretungsplaene.append(VertretungsplanForDate(date: date, gradeItems: gradeItems, expanded: false));
                        }
                    }
                    
                    update(vertretungsplan);
                }  catch let error as NSError {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        task.resume();
    }
}
