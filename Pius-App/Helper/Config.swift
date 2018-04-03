//
//  Config.swift
//  Pius-App
//
//  Created by Michael on 29.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

struct Config {
    let grades = ["keine", "Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9", "EF", "Q1", "Q2"];
    
    let classes = ["keine", "a", "b", "c", "d", "e"];

    func getGradeNameForSetting(setting: Int) -> String {
        return grades[setting];
    }
    
    func getClassNameForSetting(setting: Int) -> String {
        return classes[setting];
    }
}
