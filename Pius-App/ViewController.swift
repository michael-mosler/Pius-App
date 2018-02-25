//
//  ViewController.swift
//  Pius-App
//
//  Created by Michael on 25.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var menuView: UIView!

    var menuIsOpen : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set color of navigation bar.
        self.navigationController?.navigationBar.barTintColor = UIColor.red;
        
        // Set menu shadow.
        self.menuView.layer.shadowOpacity = 1;
        self.menuView.layer.shadowRadius = 6;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     }
    
    // Toggle sidebar menu visibility.
    @IBAction func menuButtonAction(_ sender: Any) {
        if (menuIsOpen) {
            self.menuLeadingConstraint.constant = -180;
        } else {
            self.menuLeadingConstraint.constant = 0;
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })

        self.menuIsOpen = !self.menuIsOpen;
    }
}

