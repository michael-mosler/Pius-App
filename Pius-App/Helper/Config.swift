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
    private static let userDefaults = UserDefaults();

    // The current device token. This is for transporting device token to Settings view controller only.
    // Settings view controller will update subscription when grade setting is changed.
    static var currentDeviceToken: String? {
        set(deviceToken) {
            Config.userDefaults.set(deviceToken, forKey: "currentDeviceToken");
        }
        get {
            return Config.userDefaults.string(forKey: "currentDeviceToken");
        }
    }

    static var colorPiusBlue: UIColor {
        get {
            return UIColor(red:0.337, green:0.631, blue:0.824, alpha:1.0);
        }
    }

    static var colorOfflineRed: UIColor {
        get {
            return UIColor(red: 0.843, green: 0.369, blue: 0.337, alpha: 1.0);
        }
    }

    // Grades and Classes
    static var grades: [String] {
        get {
            return ["keine", "Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9", "EF", "Q1", "Q2", "IK"];
        }
    }
    
    static var shortGrades: [String] {
        get {
            return ["", "5", "6", "7", "8", "9", "EF", "Q1", "Q2", "IK"];
        }
    }

    static var upperGrades: [String] {
        get {
            return ["EF", "Q1", "Q2"];
        }
    }
    
    static var lowerGrades: [String] {
        return  ["Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9"];
    }
    
    static var extendedLowerGrades: [String] {
        return  ["Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9"];
    }
    
    static var classes: [String] {
        get {
            return ["keine", "a", "b", "c", "d", "e"];
        }
    }

    static var shortClasses: [String] {
        get {
            return ["", "A", "B", "C", "D", "E"];
        }
    }

    static var courses: [String] {
        get {
            return ["Mathematik", "Deutsch", "Englisch", "Französisch", "Latein", "Spanisch", "Hebräisch", "Erdkunde", "Biologie", "Physik", "Chemie", "Informatik", "Geschichte", "Religion", "Philosophie", "Musik", "Kunst", "Sport", "Literatur", "SOWI"];
        }
    }

    static var coursesShortNames: [String] {
        get {
            return ["M", "D", "E", "F", "L", "S", "H", "EK", "BI", "PH", "CH", "IF", "GE", "KR", "PL", "MU", "KU", "SP", "LI", "SOWI"];
        }
    }

    static var courseTypes: [String] {
        get {
            return ["GK", "LK", "ZK", "V", "P"];
        }
    }
    
    static var courseNumbers: [String] {
        get {
            return ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
        }
    }
    
    static func getGradeNameForSetting(setting: Int) -> String {
        return Config.grades[setting];
    }
    
    static func getClassNameForSetting(setting: Int) -> String {
        return Config.classes[setting];
    }
    
     // Returns true when user has configured a grade.
    static var hasGrade: Bool {
        get {
            return AppDefaults.selectedGradeRow != 0;
        }
    }
    
    // Returns screen width.
    static var screenWidth: Int {
        get {
            return Int(UIScreen.main.bounds.width);
        }
    }
}
