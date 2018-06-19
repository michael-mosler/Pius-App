//
//  DateListViewController.swift
//  Pius-App
//
//  Created by Michael on 24.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DateListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var offlineLabel: UILabel!
    @IBOutlet weak var offlineFooterView: UIView!
    @IBOutlet weak var offlineLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    private var inSearchMode: Bool = false;
    
    @IBOutlet weak var monthListCollectionView: UICollectionView!
    @IBOutlet weak var dayListTableView: UITableView!
    
    // The active text field, is either webSizeUserNameField or webSitePasswordField.
    private var activeTextField: UITextField?;
    
    private var config = Config();
    private let piusGatewayReachability = ReachabilityChecker(forName: "https://pius-gateway.eu-de.mybluemix.net");

    private var savedScrollPosition: CGPoint?;
    
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
    private var hadSelectedButton: MonthButton? = nil;
    private var selectedMonth: Int? = nil;
    private var hadSelectedMonth: Int? = nil;
    
    private var calendar: Calendar = Calendar();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        if (piusGatewayReachability.isNetworkReachable()) {
            showOfflineLabel(percentage: 0);
        }

        getVCalendarFromWeb();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func showSearchBar(percentage: CGFloat) {
        searchBarTopConstraint.constant = -50 + min(percentage, 1) * 50;
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded();
        });
    }
    
    private func showOfflineLabel(percentage: CGFloat) {
        offlineLabelBottomConstraint.constant = -16 + min(percentage, 1) * 16;
        offlineLabel.isHidden = offlineLabelBottomConstraint.constant == -16;
        offlineFooterView.isHidden = offlineLabel.isHidden;

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded();
        });
    }
    
    private func activateSearchCancelButton() {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        savedScrollPosition = dayListTableView.contentOffset;
        
        hadSelectedMonth = selectedMonth;
        selectedMonth = nil;
        
        hadSelectedButton = selectedButton;
        selectedButton?.isSelected = false;
        selectedButton = nil;
        
        inSearchMode = true;
        dayListTableView.reloadData();

        showSearchBar(percentage: 100);
        activateSearchCancelButton();
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        calendar.filter = searchText;
        dayListTableView.reloadData();
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
        activateSearchCancelButton();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearchMode = false;
        calendar.filter = nil;
        
        showSearchBar(percentage: 0);
        searchBar.endEditing(true);
        searchBar.text = nil;
        
        selectedMonth = hadSelectedMonth;
        hadSelectedMonth = nil;
        
        selectedButton = hadSelectedButton;
        selectedButton?.isSelected = true;
        hadSelectedButton = nil;
        
        // Restore original table view position as user might have scrolled
        // in search mode.
        UIView.animate(withDuration: 0, animations: {
            self.changeSelectedButton(to: self.selectedButton!);
        }, completion: { (finished: Bool) in
            self.dayListTableView.setContentOffset(self.savedScrollPosition!, animated: false); });
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
                
                if (self.offlineLabel != nil && self.offlineFooterView != nil) {
                    self.showOfflineLabel(percentage: (online ? 0 : 1));
                }
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
    
    func changeSelectedButton(to button: MonthButton) {
        if (selectedButton != nil) {
            selectedButton!.isSelected = false;
        }
        
        selectedMonth = button.forMonth;
        button.isSelected = true;
        selectedButton = button;
        
        dayListTableView.reloadData();
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendar.monthItems.count;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = monthListCollectionView.dequeueReusableCell(withReuseIdentifier: "monthNameCell", for: indexPath);
        let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton;
        button.makeMonthButton(for: indexPath.row, with: calendar.monthItems[indexPath.row].name);
        
        // Selected button has become visible or initial start of view. In latter case
        // activate default month indexed by 0.
        if (indexPath.row == selectedMonth
            || selectedMonth == nil && hadSelectedMonth == nil && indexPath.row == 0) {
            changeSelectedButton(to: button);
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard selectedMonth != nil || inSearchMode else { return 0 };
        
        if (inSearchMode) {
            return calendar.allItems.count;
            // return calendar.monthItems.reduce(calendar.monthItems.count, { x, y in x + y.dayItems.count });
        } else {
            return calendar.monthItems[selectedMonth!].dayItems.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (inSearchMode) {
            var cell: UITableViewCell;
            let _item = calendar.allItems[indexPath.row];
            if let item = _item as? String {
                cell = dayListTableView.dequeueReusableCell(withIdentifier: "MonthName")!;
                cell.textLabel?.text = item;
            } else {
                let item = _item as! DetailItems;
                cell = dayListTableView.dequeueReusableCell(withIdentifier: "DateEntry")!;
                let dayLabel = cell.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel;
                let eventLabel = cell.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel;
                
                dayLabel.attributedText = NSMutableAttributedString(string: item[0], attributes: [NSAttributedStringKey.foregroundColor: config.colorPiusBlue]);
                eventLabel.attributedText = NSMutableAttributedString(string: item[1]);
            }
            
            return cell;
        } else {
            let cell = dayListTableView.dequeueReusableCell(withIdentifier: "DateEntry");
            let dayLabel = cell?.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel;
            let eventLabel = cell?.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel;

            let detailItems = calendar.monthItems[selectedMonth!].dayItems[indexPath.row].detailItems;
            
            dayLabel.attributedText = NSMutableAttributedString(string: detailItems[0], attributes: [NSAttributedStringKey.foregroundColor: config.colorPiusBlue]);
            eventLabel.attributedText = NSMutableAttributedString(string: detailItems[1]);

            return cell!;
        }
    }
}
