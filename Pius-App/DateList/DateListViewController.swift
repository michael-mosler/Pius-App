//
//  DateListViewController.swift
//  Pius-App
//
//  Created by Michael on 24.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DateListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate {
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
    
    @IBOutlet var swipeLeftGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var swipeRightGestureRecognizer: UISwipeGestureRecognizer!
    
    // The active text field, is either webSizeUserNameField or webSitePasswordField.
    private var activeTextField: UITextField?;
    
    private let piusGatewayReachability = ReachabilityChecker(forName: AppDefaults.baseUrl);

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

    // Move search bar into view when search button has been tapped in navigation
    // bar.
    private func showSearchBar(percentage: CGFloat) {
        searchBarTopConstraint.constant = -50 + min(percentage, 1) * 50;
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded();
        });
    }
    
    // Scroll offline label into view when offline mode is detected after in
    // viewDidLoad().
    private func showOfflineLabel(percentage: CGFloat) {
        offlineLabelBottomConstraint.constant = -16 + min(percentage, 1) * 16;
        offlineLabel.isHidden = offlineLabelBottomConstraint.constant == -16;
        offlineFooterView.isHidden = offlineLabel.isHidden;

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded();
        });
    }
    
    // Activate cancel button in search bar.
    private func activateSearchCancelButton() {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    // Search button action: Store current state and activate search mode.
    @IBAction func searchButtonAction(_ sender: Any) {
        if !inSearchMode {
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
    }
    
    // Called whenever input in search bar is changed. Updates filter text
    // in calendar data and reloads date list. This applies the search text
    // to calendar items.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        calendar.filter = searchText;
        dayListTableView.reloadData();
    }

    // Clicking search button in keyboard simply hides the keyboard.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder();
        activateSearchCancelButton();
    }
    
    // Cancel search. This restores the view from before search was started.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearchMode = false;
        calendar.filter = nil;
        
        showSearchBar(percentage: 0);
        searchBar.endEditing(true);
        searchBar.text = nil;
        
        selectedMonth = hadSelectedMonth;
        hadSelectedMonth = nil;
        
        selectedButton = hadSelectedButton;
        hadSelectedButton = nil;
        
        // Restore original table view position as user might have scrolled
        // in search mode.
        UIView.animate(withDuration: 0, animations: {
            self.changeSelectedMonthButton(to: self.selectedButton!);
        }, completion: { (finished: Bool) in
            self.dayListTableView.setContentOffset(self.savedScrollPosition!, animated: false); });
    }

    // Whenever a new month is selected this action load the corresponding dates into
    // day view table.
    @IBAction func monthButtonAction(_ sender: Any) {
        if let button = sender as? MonthButton {
            UIView.animate(withDuration: 0, animations: {
                self.changeSelectedMonthButton(to: button);
            }, completion: { (finished: Bool) in
                self.dayListTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false); });
        }
    }

    // Update view from calendar that just has been loaded.
    func doUpdate(with calendar: Calendar?, online: Bool) {
        // Error when loading calendar.
        if (calendar == nil) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Termine", message: "Der Kalender konnte leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert);
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
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
    
    // Loads calendar from middleware.
    private func getVCalendarFromWeb() {
        let calendarLoader = CalendarLoader();
        
        // Clear all data and load calendar.
        selectedMonth = nil;
        calendarLoader.load(self.doUpdate);
    }
    
    // Called when selected month is to changed. Deselects previous month
    // and changes selection to the new button.
    func changeSelectedMonthButton(to button: MonthButton) {
        if (selectedButton != nil) {
            selectedButton!.isSelected = false;
        }
        
        selectedMonth = button.forMonth;
        button.isSelected = true;
        button.parentCell?.isSelected = true;
        selectedButton = button;
        
        dayListTableView.reloadData();
        
        if let _selectedMonth = selectedMonth {
            let indexPath = IndexPath(item: _selectedMonth, section: 0);
            monthListCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true);
        }
    }
    
    // Returns the number of distinct months in the calendar.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendar.monthItems.count;
    }

    // Return a new month selection collection view cell.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = monthListCollectionView.dequeueReusableCell(withReuseIdentifier: "monthNameCell", for: indexPath);
        let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton;
        button.makeMonthButton(for: indexPath.row, with: calendar.monthItems[indexPath.row].name, parentCell: cell);
        
        // Selected button has become visible or initial start of view. In latter case
        // activate default month indexed by 0.
        if (indexPath.row == selectedMonth
            || selectedMonth == nil && hadSelectedMonth == nil && indexPath.row == 0) {
            changeSelectedMonthButton(to: button);
        }
        
        return cell;
    }
    
    // Returns the number of rows in the current day list table view. Actual calculation depends
    // on the mode the view is in.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard selectedMonth != nil || inSearchMode else { return 0 };
        return (inSearchMode) ? calendar.allItems.count : calendar.monthItems[selectedMonth!].dayItems.count;
    }
    
    // Return a cell of day list table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell;
        if (inSearchMode) {
            let _item = calendar.allItems[indexPath.row];
            if let item = _item as? String {
                cell = dayListTableView.dequeueReusableCell(withIdentifier: "MonthName")!;
                cell.textLabel?.text = item;
            } else {
                let item = _item as! DayItem;
                cell = dayListTableView.dequeueReusableCell(withIdentifier: "DateEntry")!;
                let dayLabel = cell.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel;
                let eventLabel = cell.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel;
                
                dayLabel.attributedText = NSMutableAttributedString(string: item.detailItems[0], attributes: [NSAttributedString.Key.foregroundColor: Config.colorPiusBlue]);
                
                // Event text; hightlight when range is given.
                let text = NSMutableAttributedString(string: item.detailItems[1]);
                if let _hightlight = item.highlight {
                    text.addAttribute(NSAttributedString.Key.backgroundColor, value: Config.colorYellow, range: _hightlight);
                }
                eventLabel.attributedText = text;
            }
        } else {
            cell = dayListTableView.dequeueReusableCell(withIdentifier: "DateEntry")!;
            let dayLabel = cell.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel;
            let eventLabel = cell.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel;

            let detailItems = calendar.monthItems[selectedMonth!].dayItems[indexPath.row].detailItems;
            
            dayLabel.attributedText = NSMutableAttributedString(string: detailItems[0], attributes: [NSAttributedString.Key.foregroundColor: Config.colorPiusBlue]);
            eventLabel.attributedText = NSMutableAttributedString(string: detailItems[1]);
        }
        
        return cell;
    }
    
    // Execute swipe action.
    private func doSwipe(direction: Int) {
        if let selectedCell = selectedButton?.parentCell {
            if var indexPath = monthListCollectionView.indexPath(for: selectedCell) {
                indexPath.item += direction;
                
                if let cell = monthListCollectionView.cellForItem(at: indexPath) {
                    let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton;
                    UIView.animate(withDuration: 0.5, animations: {
                        self.changeSelectedMonthButton(to: button);
                    }, completion: { (finished: Bool) in
                        self.dayListTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true); });
                }
            }
        }
    }

    // Swipe left
    @IBAction func swipeLeftAction(_ sender: Any) {
        doSwipe(direction: 1);
    }
    
    
    // Swipe right
    @IBAction func swipeRightAction(_ sender: Any) {
        doSwipe(direction: -1);
    }
}
