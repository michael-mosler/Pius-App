//
//  Config.swift
//  Pius-App
//
//  Created by Michael on 29.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

struct Config {
    let colorPiusBlue = UIColor(red:0.337, green:0.631, blue:0.824, alpha:1.0);

    let grades = ["keine", "Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9", "EF", "Q1", "Q2"];
    let shortGrades = ["", "5", "6", "7", "8", "9", "EF", "Q1", "Q2"]
    
    let classes = ["keine", "a", "b", "c", "d", "e"];
    let shortClasses = ["", "A", "B", "C", "D", "E"];

    let courses = ["Mathematik", "Deutsch", "Englisch", "Französisch", "Latein", "Spanisch", "Hebräisch", "Erdkunde", "Biologie", "Physik", "Chemie", "Informatik", "Geschichte", "Religion", "Philosophie", "Musik", "Kunst", "Sport", "Literatur", "SOWI"];
    let coursesShortNames = ["M", "D", "E", "F", "L", "S", "H", "EK", "BI", "PH", "CH", "IF", "GE", "KR", "PL", "MU", "KU", "SP", "LI", "SOWI"];
    let courseTypes = ["GK", "LK", "ZK", "V", "P"];
    let courseNumbers = ["1", "2", "3", "4", "5"];
    
    let userDefaults = UserDefaults.standard;

    func getGradeNameForSetting(setting: Int) -> String {
        return grades[setting];
    }
    
    func getClassNameForSetting(setting: Int) -> String {
        return classes[setting];
    }
    
    // Gets current credentials from settings.
    func getCredentials() -> (String, String) {
        do {
            guard let webSiteUserName = userDefaults.string(forKey: "webSiteUserName"), !webSiteUserName.isEmpty else { return ("", "") };
            
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: KeychainConfiguration.accessGroup);

            var webSitePassword: String;
            try webSitePassword = passwordItem.readPassword();
            
            return (webSiteUserName, webSitePassword);
        }
        catch {
            fatalError("Die Anmeldedaten konnte nicht geladen werden - \(error)");
        }

    }
}
