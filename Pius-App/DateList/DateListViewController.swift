//
//  DateListViewController.swift
//  Pius-App
//
//  Created by Michael on 24.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DateListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var monthListCollectionView: UICollectionView!
    @IBOutlet weak var dayListTableView: UITableView!
    
    private var config = Config();
    
    private struct tags {
        enum collectionView: Int {
            case monthButtonInCollectionViewCell = 1
        }
        enum tableView: Int {
            case dayLabelInTableViewCell = 1
            case eventLabelInTablewViewCell = 2
        }
    }

    private var selectedButton: MonthButton? = nil;
    private var selectedMonth: Int? = nil;
    private var calendar: Calendar = Calendar();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        getVCalendarFromWeb();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func changeSelectedButton(to button: MonthButton) {
        if (selectedButton != nil) {
            selectedButton!.isSelected = false;
        }
        
        selectedMonth = button.forMonth;
        button.isSelected = true;
        selectedButton = button;
        
        dayListTableView.reloadData();
    }

    @IBAction func monthButtonAction(_ sender: Any) {
        let button = sender as? MonthButton;
        changeSelectedButton(to: button!);
    }

    func doUpdate(with calendar: Calendar?, online: Bool) {
        if (calendar == nil) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Termine", message: "Der Kalender konnte leider nicht geladen werden.", preferredStyle: UIAlertControllerStyle.alert);
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true);
                }));
                self.present(alert, animated: true, completion: nil);
                
                /*
                if (self.offlineLabel != nil && self.offlineFooterView != nil) {
                    self.offlineLabel.isHidden = online;
                    self.offlineFooterView.isHidden = online;
                }
                */
            }
        } else {
            self.calendar = calendar!;
            DispatchQueue.main.async {
                self.monthListCollectionView.reloadData();
                self.activityIndicator.stopAnimating();
            }
        }
    }
    
    private func getVCalendarFromWeb() {
        let calendarLoad = CalendarLoader();
        
        // Clear all data and load calendar.
        selectedMonth = nil;
        calendarLoad.load(self.doUpdate);
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendar.monthItems.count;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = monthListCollectionView.dequeueReusableCell(withReuseIdentifier: "monthNameCell", for: indexPath);

        let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton;

        button.makeMonthButton(for: indexPath.row, with: calendar.monthItems[indexPath.row].name);
        
        // Selected button has become visible.
        if (indexPath.row == selectedMonth) {
            button.isSelected = true;
        } else if (selectedMonth == nil && indexPath.row == 0) {
            changeSelectedButton(to: button);
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard selectedMonth != nil else { return 0 };
        
        return calendar.monthItems[selectedMonth!].dayItems.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dayListTableView.dequeueReusableCell(withIdentifier: "DateEntry");
        let dayLabel = cell?.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel;
        let eventLabel = cell?.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel;

        let detailItems = calendar.monthItems[selectedMonth!].dayItems[indexPath.row].detailItems;
        
        dayLabel.attributedText = NSMutableAttributedString(string: detailItems[0], attributes: [NSAttributedStringKey.foregroundColor: config.colorPiusBlue]);
        eventLabel.attributedText = NSMutableAttributedString(string: detailItems[1]);

        return cell!;
    }
}
