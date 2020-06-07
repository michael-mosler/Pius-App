//
//  LaunchScreenViewController.swift
//  Pius-App
//
//  Created by Michael on 13.05.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Shows Onboarding Screen usually once for each new version.
 */
class OnboardingViewController: UIViewController {
    @IBAction func startAppAction(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }

    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var newInVersionText: UILabel!
    @IBOutlet weak var feature1Text: UILabel!
    @IBOutlet weak var feature2Text: UILabel!
    @IBOutlet weak var feature3Text: UILabel!
    @IBOutlet weak var feature4Text: UILabel!
    @IBOutlet weak var feature5Text: UILabel!
    @IBOutlet weak var functionOverviewText: UILabel!
    
    override func viewDidLoad() {
        // For iOS >= 13.0 we need to make some preparations due to dark mode.
        if #available(iOS 13.0, *) {
            welcomeText.textColor = UIColor.label
            newInVersionText.textColor = UIColor.label
            feature1Text.textColor = UIColor.label
            feature2Text.textColor = UIColor.label
            feature3Text.textColor = UIColor.label
            feature4Text.textColor = UIColor.label
            feature5Text.textColor = UIColor.label
            functionOverviewText.textColor = UIColor.label
        }
        
        if let nsObject = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject?,
            let version = nsObject as? String {
            newInVersionText.text?.append(version)
        }
    }
}
