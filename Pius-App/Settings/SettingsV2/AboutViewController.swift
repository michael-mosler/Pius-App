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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setVersionLabel()
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
