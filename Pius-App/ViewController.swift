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
    
    // Add Pius logo as navigation bar title on initial view.
    func addNavBarLogo() {
        let navigationController = self.navigationController!;
        let image = #imageLiteral(resourceName: "pius-logo-transparent");
        let imageView = UIImageView(image: image);
        
        let bannerWidth = navigationController.navigationBar.frame.size.width;
        let bannerHeight = navigationController.navigationBar.frame.size.height;
        
        let bannerX = bannerWidth / 2 - image.size.width / 2;
        let bannerY = bannerHeight / 2 - image.size.height / 2;
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: image.size.width, height: image.size.height);
        imageView.contentMode = .scaleAspectFit;

        navigationItem.titleView = imageView;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set color of navigation bar.
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.337, green:0.631, blue:0.824, alpha:1.0);
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white];
        
        self.addNavBarLogo();
        
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

