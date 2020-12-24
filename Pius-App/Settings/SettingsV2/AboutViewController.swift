//
//  AboutViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 24.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    
    /// Initialize view controller after loading.
    override func viewDidLoad() {
        super.viewDidLoad()

        setVersionLabel()
    }
    
    /// Set label colour of app text box on iOS 13. This is needed in
    /// dark mode.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 13.0, *) {
            infoTextView.textColor = UIColor.label
        }
    }
    
    /// Sets the version label.
    private func setVersionLabel() {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        let versionString = String(format: "Pius-App für iOS Version %@", version)

        versionLabel.text = versionString
    }
}
