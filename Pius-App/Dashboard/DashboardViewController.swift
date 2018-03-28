//
//  DashboardViewController.swift
//  Pius-App
//
//  Created by Michael on 28.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tickerTextPageControl: UIPageControl!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tickerTextScrollView: UIScrollView!
    @IBOutlet weak var additionalTextScrollView: UIScrollView!
    
    @IBOutlet weak var tickerTextLabel: UILabel!
    @IBOutlet weak var additionalTextLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
