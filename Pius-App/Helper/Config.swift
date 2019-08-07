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
    private static let userDefaults = UserDefaults()

    // The current device token. This is for transporting device token to Settings view controller only.
    // Settings view controller will update subscription when grade setting is changed.
    static var currentDeviceToken: String? {
        set(deviceToken) {
            Config.userDefaults.set(deviceToken, forKey: "currentDeviceToken")
        }
        get {
            return Config.userDefaults.string(forKey: "currentDeviceToken")
        }
    }

    static let colorPiusBlue: UIColor = UIColor(red:0.337, green:0.631, blue:0.824, alpha:1.0)
    static let colorRed: UIColor = UIColor(red: 0.914, green: 0.200, blue: 0.184, alpha: 1.0)
    static var colorGreen: UIColor = UIColor(red: 0.557, green: 0.788, blue: 0.259, alpha: 1.0)
    static let colorYellow: UIColor = UIColor(red: 1.0, green: 0.8, blue: 0.004, alpha: 1.0)
    static let colorGray: UIColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1.0)
    
    // Day names
    static let dayNames: [String] = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag"]
    
    // Grades and Classes
    static let grades: [String] = ["keine", "Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9", "EF", "Q1", "Q2", "IKD", "IKE"]
    static let shortGrades: [String] = ["", "5", "6", "7", "8", "9", "EF", "Q1", "Q2", "IKD", "IKE"]
    static let upperGrades: [String] = ["EF", "Q1", "Q2"]
    static let lowerGrades: [String] = ["Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9"]
    static let extendedLowerGrades: [String] = ["Klasse 5", "Klasse 6", "Klasse 7", "Klasse 8", "Klasse 9"]
    
    // Checks if grade is upper grade.
    static func isUpperGrade(_ grade: String) -> Bool {
        return Config.upperGrades.firstIndex(of: grade) != nil
    }
    
    // Checks if grade is lower grade.
    static func isLowerGrade(_ grade: String) -> Bool {
        return Config.lowerGrades.firstIndex(of: grade) != nil
    }

    static let classes: [String] = ["keine", "a", "b", "c", "d", "e"]
    static let shortClasses: [String] = ["", "A", "B", "C", "D", "E"]
    
    static let courses: [String] = ["Mathematik", "Deutsch", "Englisch", "Französisch", "Latein", "Spanisch", "Hebräisch", "Erdkunde", "Biologie", "Physik", "Chemie", "Informatik", "Geschichte", "Religion", "Philosophie", "Musik", "Kunst", "Sport", "Literatur", "SOWI", "IV"]
    static let coursesShortNames: [String] = ["M", "D", "E", "F", "L", "S", "H", "EK", "BI", "PH", "CH", "IF", "GE", "KR", "PL", "MU", "KU", "SP", "LI", "SW", "IV"]

    private var courseDictionary: [String:String]!
    
    static let courseTypes: [String] = ["GK", "LK", "ZK", "V", "P"]
    static var courseNumbers: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    static func getGradeNameForSetting(setting: Int) -> String {
        return Config.grades[setting]
    }
    
    static func getClassNameForSetting(setting: Int) -> String {
        return Config.classes[setting]
    }
    
    static var alwaysShowOnboarding: Bool {
        get {
            return Bundle.main.infoDictionary?["ALWAYS_SHOW_ONBOARDING"] as! String == "true"
        }
    }
    
    init() {
        courseDictionary = [:]
        for i in 0..<Config.coursesShortNames.count {
            courseDictionary[Config.coursesShortNames[i]] = Config.courses[i]
        }
    }
    
    func expand(shortCourseName name: String) -> String {
        return courseDictionary[name] ?? ""
    }
}
