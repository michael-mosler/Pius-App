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
    
    @IBOutlet weak var monthListCollectionView: UICollectionView!
    @IBOutlet weak var monthListCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dayListTableView: UITableView!
    
    @IBOutlet weak var dateListViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateListViewTrailingConstraint: NSLayoutConstraint!
    
    private var panGestureRecognizer: UIPanGestureRecognizer!

    // The active text field, is either webSizeUserNameField or webSitePasswordField.
    private var inSearchMode: Bool = false;
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
        
        panGestureRecognizer = UIPanGestureRecognizer();
        panGestureRecognizer.addTarget(self, action:#selector(DateListViewController.panAction(_:)));
        view.addGestureRecognizer(panGestureRecognizer)

        getVCalendarFromWeb();
    }

    // Move search bar into view when search button has been tapped in navigation
    // bar.
    private func showSearchBar() {
        let search = UISearchController(searchResultsController: nil);
        search.dimsBackgroundDuringPresentation = false;
        search.searchBar.delegate = self;
        navigationItem.searchController = search;
        navigationItem.hidesSearchBarWhenScrolling = false;
        monthListCollectionViewHeightConstraint.constant = 0;
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

            showSearchBar();
        }
    }
    
    // Called whenever input in search bar is changed. Updates filter text
    // in calendar data and reloads date list. This applies the search text
    // to calendar items.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        calendar.filter = searchText;
        dayListTableView.reloadData();
    }

    // Cancel search. This restores the view from before search was started.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearchMode = false;
        calendar.filter = nil;
        navigationItem.searchController = nil;
        monthListCollectionViewHeightConstraint.constant = 50;

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
                    self.dateListViewLeadingConstraint.constant -= CGFloat(Config.screenWidth);
                    self.dateListViewTrailingConstraint.constant -= CGFloat(Config.screenWidth);
                    let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton;
                    UIView.animate(withDuration: 0.5, animations: {
                        self.changeSelectedMonthButton(to: button);
                        self.view.layoutIfNeeded();
                    }, completion: { (finished: Bool) in
                        print("Finished");
                        self.dateListViewLeadingConstraint.constant = 0;
                        self.dateListViewTrailingConstraint.constant = 0;
                        self.view.layoutIfNeeded();
                        self.dayListTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true); });
                }
            }
        }
    }

    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        print("Pan");
    }
}
