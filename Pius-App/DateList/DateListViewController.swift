//
//  DateListViewController.swift
//  Pius-App
//
//  Created by Michael on 24.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DateListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, CalendarDataDelegate {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var monthListCollectionView: UICollectionView!
    @IBOutlet weak var monthListCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var dateListCollectionView: UICollectionView!
    @IBOutlet weak var dateListCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var dateListSearchTableView: UITableView!
    
    // The active text field, is either webSizeUserNameField or webSitePasswordField.
    private var inSearchMode_: Bool = false
    private var activeTextField: UITextField?
    private var savedScrollPosition: CGPoint?
    
    private struct tags {
        enum collectionView: Int {
            case monthButtonInCollectionViewCell = 1
        }
        enum tableView: Int {
            case dayLabelInTableViewCell = 1
            case eventLabelInTablewViewCell = 2
        }
    }

    private var collectionViewItemSize: CGSize = CGSize(width: 0, height: 0)
    private var selectedButton: MonthButton? = nil
    private var hadSelectedButton: MonthButton? = nil
    private var selectedMonth_: Int? = nil
    private var hadSelectedMonth: Int? = nil
    private var scrollToIndexPath: NSIndexPath?
    
    private var calendar: Calendar = Calendar()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.delegate = self
        navigationItem.searchController = search

        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController?.isActive = true
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController?.searchBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionViewItemSize = CGSize(width: dateListCollectionView.frame.width - 10, height: dateListCollectionView.frame.height)
        getCalendarFromWeb()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        hadSelectedMonth = selectedMonth_
        selectedMonth_ = nil
        hadSelectedButton = selectedButton
        selectedButton?.isSelected = false
        selectedButton = nil
        inSearchMode_ = true

        dateListSearchTableView.isHidden = false
        dateListSearchTableView.reloadData()
    }

    /**
     * Called whenever input in search bar is changed. Updates filter text
     * in calendar data and reloads date list. This applies the search text
     * to calendar items.
     */
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        calendar.filter = searchText
        dateListSearchTableView.reloadData()
    }

    /**
     * Cancel search. This restores the view from before search was started.
     */
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dateListSearchTableView.isHidden = true

        inSearchMode_ = false
        calendar.filter = nil
        selectedMonth_ = hadSelectedMonth
        hadSelectedMonth = nil
        selectedButton = hadSelectedButton
        hadSelectedButton = nil
        
        // Restore original table view position as user might have scrolled
        // in search mode.
        if let selectedButton = self.selectedButton {
            UIView.animate(withDuration: 0, animations: {
                self.changeSelectedMonthButton(to: selectedButton)
            }, completion: { (finished: Bool) in
                let indexPath = IndexPath(item: selectedButton.forMonth!, section: 0)
                self.dateListCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            })
        }
    }

    /**
     * Whenever a new month is selected this action load the corresponding dates into
     * day view table.
     */
    @IBAction func monthButtonAction(_ sender: Any) {
        if let button = sender as? MonthButton {
            UIView.animate(withDuration: 0, animations: {
                self.changeSelectedMonthButton(to: button)
            }, completion: { (finished: Bool) in
                let indexPath = IndexPath(item: button.forMonth!, section: 0)
                self.dateListCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
            })
        }
    }

    /**
     * Update view from calendar that just has been loaded.
     */
    func doUpdate(with calendar: Calendar?, online: Bool) {
        // Error when loading calendar.
        if (calendar == nil) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Termine", message: "Der Kalender konnte leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.calendar = calendar!

            DispatchQueue.main.async {
                self.monthListCollectionView.reloadData()
                let indexPath = NSIndexPath(row: 0, section: 0)
                
                self.monthListCollectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: false)
                self.monthListCollectionView.layoutIfNeeded()

                self.dateListCollectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: false)
                self.dateListCollectionView.layoutIfNeeded()

                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    /**
     * Loads calendar from middleware.
     */
    private func getCalendarFromWeb() {
        let calendarLoader = CalendarLoader()
        
        // Clear all data and load calendar.
        selectedMonth_ = nil
        calendarLoader.load(self.doUpdate)
    }
    
    /**
     * Called when selected month is about to change. Deselects previous month
     * and changes selection to the new button.
     */
    func changeSelectedMonthButton(to button: MonthButton) {
        if (selectedButton != nil) {
            selectedButton!.isSelected = false
        }
        
        selectedMonth_ = button.forMonth
        button.isSelected = true
        button.parentCell?.isSelected = true
        selectedButton = button
        
        dateListCollectionView.reloadData()
        
        if let _selectedMonth = selectedMonth_ {
            let indexPath = IndexPath(item: _selectedMonth, section: 0)
            monthListCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    /**
     * Returns the number of distinct months in the calendar.
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendar.monthItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (collectionView == monthListCollectionView) {
            return CGSize(width: monthListCollectionViewFlowLayout.itemSize.width, height: monthListCollectionViewFlowLayout.itemSize.height)
        }
        
        return collectionViewItemSize
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if (collectionView == dateListCollectionView) {
            return CGSize(width: collectionView.frame.size.width - 20, height: collectionView.frame.height)
        }
        
        return CGSize(width: 90, height: 50)
    }
    
    /**
     * Return a new month selection collection view cell.
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == monthListCollectionView) {
            let cell = monthListCollectionView.dequeueReusableCell(withReuseIdentifier: "monthNameCell", for: indexPath)
            let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton
            button.makeMonthButton(for: indexPath.row, with: calendar.monthItems[indexPath.row].name, parentCell: cell)
            
            // Nothing selected yet, select first month.
            if (selectedMonth_ == nil && hadSelectedMonth == nil && indexPath.row == 0) {
                changeSelectedMonthButton(to: button)
            }
            
            return cell
        }

        // Date list cell; we should have a class for this collection view.
        let cell = dateListCollectionView.dequeueReusableCell(withReuseIdentifier: "dateListCell", for: indexPath) as! DateListCollectionViewCell
        cell.customInit(delegate: self, forMonth: indexPath.row)
        return cell
    }
    
    /**
     * Scrolling to another month did end.
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView == dateListCollectionView) {
            let itemIndex = (scrollView.contentOffset.x / CGFloat(IOSHelper.screenWidth)).rounded()
            let indexPath = NSIndexPath(row: Int(itemIndex), section: 0)
            
            if let cell = monthListCollectionView.cellForItem(at: indexPath as IndexPath) {
                // Month button that must be highlighted. If it is already selected then user has
                // tapped on button and not used swipe gesture. In this case no select action
                // must be triggered. Reloading would destroy any scroll action already started.
                let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton
                if !button.isSelected {
                    UIView.animate(withDuration: 0.5, animations: {
                        self.changeSelectedMonthButton(to: button)
                    }, completion: { (finished: Bool) in
                        self.dateListCollectionView.reloadData()
                    })
                }
            } else {
                scrollToIndexPath = indexPath
                monthListCollectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
                monthListCollectionView.layoutIfNeeded()
            }
        }
    }
    
    /**
     * Scroll animation has ended.
     */
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if (scrollView == monthListCollectionView && scrollToIndexPath != nil) {
            if let cell = monthListCollectionView.cellForItem(at: scrollToIndexPath! as IndexPath) {
                let button = cell.viewWithTag(tags.collectionView.monthButtonInCollectionViewCell.rawValue) as! MonthButton
                UIView.animate(withDuration: 0.5, animations: {
                    self.changeSelectedMonthButton(to: button)
                }, completion: { (finished: Bool) in
                    self.dateListCollectionView.reloadData()
                })
            }
            scrollToIndexPath = nil
        }
    }

    /**
     * Returns the number of rows in the current day list table view. Actual calculation depends
     * on the mode the view is in.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allItems().count
    }
    
    /**
     * Return a cell of day list table view.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let _item = self.allItems()[indexPath.row]
        if let item = _item as? String {
            cell = dateListSearchTableView.dequeueReusableCell(withIdentifier: "MonthName")!
            cell.textLabel?.text = item
        } else {
            let item = _item as! DayItem
            cell = dateListSearchTableView.dequeueReusableCell(withIdentifier: "DateEntry")!
            let dayLabel = cell.viewWithTag(tags.tableView.dayLabelInTableViewCell.rawValue) as! UILabel
            let eventLabel = cell.viewWithTag(tags.tableView.eventLabelInTablewViewCell.rawValue) as! UILabel
            
            dayLabel.attributedText = NSMutableAttributedString(string: item.detailItems[0], attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "piusBlue")!])
            
            // Event text; hightlight when range is given.
            let text = NSMutableAttributedString(string: item.detailItems[1])
            item.highlight.forEach({ range in
                text.addAttribute(NSAttributedString.Key.backgroundColor, value: Config.colorYellow, range: range)
            })
            eventLabel.attributedText = text
        }
        
        return cell
    }
}

/*
 * Calendat Data protocol methods.
 */
extension DateListViewController {
    func allItems() -> [Any] {
        return calendar.allItems
    }
    
    func monthItems() -> [MonthItem] {
        return calendar.monthItems
    }
    
    func inSearchMode() -> Bool {
        return inSearchMode_
    }
    
    func selectedMonth() -> Int? {
        return selectedMonth_
    }
}
