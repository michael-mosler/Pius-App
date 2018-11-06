//
//  DateListViewController.swift
//  Pius-App
//
//  Created by Michael on 24.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DateListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, CalendarDataDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var monthListCollectionView: UICollectionView!
    @IBOutlet weak var monthListCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateListCollectionView: UICollectionView!
    @IBOutlet weak var dateListCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    // The active text field, is either webSizeUserNameField or webSitePasswordField.
    private var inSearchMode_: Bool = false;
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
    private var selectedMonth_: Int? = nil;
    private var hadSelectedMonth: Int? = nil;
    
    private var calendar: Calendar = Calendar();
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dateListCollectionViewFlowLayout.estimatedItemSize = CGSize(width: dateListCollectionView.frame.width - 10, height: dateListCollectionView.frame.height);
        getCalendarFromWeb();
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
    
    override func viewWillLayoutSubviews() {
        print("Will layout");
    }
    
    // Search button action: Store current state and activate search mode.
    @IBAction func searchButtonAction(_ sender: Any) {
        if !inSearchMode_ {
            //savedScrollPosition = dayListTableView.contentOffset;
            
            hadSelectedMonth = selectedMonth_;
            selectedMonth_ = nil;
            
            hadSelectedButton = selectedButton;
            selectedButton?.isSelected = false;
            selectedButton = nil;
            
            inSearchMode_ = true;
            dateListCollectionView.reloadData();

            showSearchBar();
        }
    }
    
    // Called whenever input in search bar is changed. Updates filter text
    // in calendar data and reloads date list. This applies the search text
    // to calendar items.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        calendar.filter = searchText;
        dateListCollectionView.reloadData();
    }

    // Cancel search. This restores the view from before search was started.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        inSearchMode_ = false;
        calendar.filter = nil;
        navigationItem.searchController = nil;
        monthListCollectionViewHeightConstraint.constant = 50;

        selectedMonth_ = hadSelectedMonth;
        hadSelectedMonth = nil;
        
        selectedButton = hadSelectedButton;
        hadSelectedButton = nil;
        
        // Restore original table view position as user might have scrolled
        // in search mode.
        UIView.animate(withDuration: 0, animations: {
            self.changeSelectedMonthButton(to: self.selectedButton!);
        }, completion: { (finished: Bool) in
            // self.dayListTableView.setContentOffset(self.savedScrollPosition!, animated: false);
        });
    }

    // Whenever a new month is selected this action load the corresponding dates into
    // day view table.
    @IBAction func monthButtonAction(_ sender: Any) {
        if let button = sender as? MonthButton {
            UIView.animate(withDuration: 0, animations: {
                self.changeSelectedMonthButton(to: button);
            }, completion: { (finished: Bool) in
                let indexPath = IndexPath(item: button.forMonth!, section: 0);
                self.dateListCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true);
            });
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
    private func getCalendarFromWeb() {
        let calendarLoader = CalendarLoader();
        
        // Clear all data and load calendar.
        selectedMonth_ = nil;
        calendarLoader.load(self.doUpdate);
    }
    
    // Called when selected month is to changed. Deselects previous month
    // and changes selection to the new button.
    func changeSelectedMonthButton(to button: MonthButton) {
        if (selectedButton != nil) {
            selectedButton!.isSelected = false;
        }
        
        selectedMonth_ = button.forMonth;
        button.isSelected = true;
        button.parentCell?.isSelected = true;
        selectedButton = button;
        
        dateListCollectionView.reloadData();
        
        if let _selectedMonth = selectedMonth_ {
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
        if (collectionView == monthListCollectionView) {
            let cell = monthListCollectionView.dequeueReusableCell(withReuseIdentifier: "monthNameCell", for: indexPath);
            let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton;
            button.makeMonthButton(for: indexPath.row, with: calendar.monthItems[indexPath.row].name, parentCell: cell);
            
            // Selected button has become visible or initial start of view. In latter case
            // activate default month indexed by 0.
            if (indexPath.row == selectedMonth_
                || selectedMonth_ == nil && hadSelectedMonth == nil && indexPath.row == 0) {
                changeSelectedMonthButton(to: button);
            }
            
            return cell;
        }

        // Date list cell; we should have a class for this collection view.
        let cell = dateListCollectionView.dequeueReusableCell(withReuseIdentifier: "dateListCell", for: indexPath) as! DateListCollectionViewCell;
        cell.customInit(delegate: self, forMonth: indexPath.row);
        return cell;
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let itemIndex = (scrollView.contentOffset.x / CGFloat(Config.screenWidth)).rounded();
        let indexPath = NSIndexPath(row: Int(itemIndex), section: 0);

        if let cell = monthListCollectionView.cellForItem(at: indexPath as IndexPath) {
            let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton;
            UIView.animate(withDuration: 0.5, animations: {
                self.changeSelectedMonthButton(to: button);
            }, completion: { (finished: Bool) in
                self.dateListCollectionView.reloadData();
            });
        }
    }

    func allItems() -> [Any] {
        return calendar.allItems;
    }
    
    func monthItems() -> [MonthItem] {
        return calendar.monthItems;
    }
    
    func inSearchMode() -> Bool {
        return inSearchMode_;
    }
    
    func selectedMonth() -> Int? {
        return selectedMonth_;
    }
}
