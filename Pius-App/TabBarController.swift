//
//  TabBarControllerViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 01.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

protocol ChangeGradeDelegate {
    func setGrade(grade: String?);
}

class TabBarController: UITabBarController, ChangeGradeDelegate {
    private func changeDashboardItemTitle(newTitle: String?) {
        tabBar.items![2].title = (newTitle != nil && newTitle != "") ? newTitle : "Dashboard";
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        
        guard AppDefaults.hasGrade else { return; }
        changeDashboardItemTitle(newTitle: AppDefaults.gradeSetting);
    }
    
    func setGrade(grade: String?) {
        changeDashboardItemTitle(newTitle: grade);
    }
}
