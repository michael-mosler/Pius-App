//
//  AppDefaults.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 23.06.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

struct AppDefaults {
    // API Key for middleware access
    static var apiKey: String {
        get {
            return Bundle.main.infoDictionary?["API_KEY"] as! String;
        }
    }

    // Base-URL of our IBM Cloud Middlware
    static var baseUrl: String {
        get {
            return Bundle.main.infoDictionary?["HOST_ADDRESS"] as! String;
        }
    }
    
    // Shared configuration settings.
    private static let sharedDefaults = UserDefaults(suiteName: "group.de.rmkrings.piusapp.widget");
    static var version: String {
        set(version) {
            AppDefaults.sharedDefaults?.set(version, forKey: "version");
        }
        
        get {
            guard let version = AppDefaults.sharedDefaults?.string(forKey: "version") else { return "" }
            return version;
        }
    }

    static var selectedGradeRow: Int? {
        set(selectedGradeRow) {
            AppDefaults.sharedDefaults?.set(selectedGradeRow, forKey: "selectedGradeRow");
        }
        
        get {
            return AppDefaults.sharedDefaults?.integer(forKey: "selectedGradeRow");
        }
    }

    static var selectedClassRow: Int? {
        set(selectedClassRow) {
            AppDefaults.sharedDefaults?.set(selectedClassRow, forKey: "selectedClassRow");
        }
        
        get {
            return AppDefaults.sharedDefaults?.integer(forKey: "selectedClassRow");
        }
    }

    static var gradeSetting: String {
        get {
            guard let gradeSetting = AppDefaults.selectedGradeRow, let classSetting = AppDefaults.selectedClassRow else { return "" };
            return Config.shortGrades[gradeSetting] + Config.shortClasses[classSetting];
        }
    }

    static var hasLowerGrade: Bool {
        get {
            if let selectedGradeRow = selectedGradeRow {
                return Config.lowerGrades.firstIndex(of: Config.grades[selectedGradeRow]) != nil
            } else {
                return false;
            }
        }
    }

    static var hasExtendedLowerGrade: Bool {
        get {
            if let selectedGradeRow = selectedGradeRow {
                return Config.extendedLowerGrades.firstIndex(of: Config.grades[selectedGradeRow]) != nil
            } else {
                return false;
            }
        }
    }

    static var hasUpperGrade: Bool {
        get {
            if let selectedGradeRow = selectedGradeRow {
                return Config.upperGrades.firstIndex(of: Config.grades[selectedGradeRow]) != nil
            } else {
                return false;
            }
        }
    }
    
    // Returns true when user has configured a grade.
    static var hasGrade: Bool {
        get {
            return AppDefaults.selectedGradeRow != 0;
        }
    }

    static var courseList: [String]? {
        set(courseList) {
            AppDefaults.sharedDefaults?.set(courseList, forKey: "courseList");
        }
        
        get {
            return AppDefaults.sharedDefaults?.array(forKey: "courseList") as? [String];
        }
    }
    
    static var useTimetable: Bool {
        set(value) {
            AppDefaults.sharedDefaults?.set(value, forKey: "useTimetable")
        }
        get {
            return AppDefaults.sharedDefaults?.bool(forKey: "useTimetable") ?? false
        }
    }

    static var timetable: Timetable {
        set(value) {
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            AppDefaults.sharedDefaults?.set(data, forKey: "timetable")
        }
        get {
            guard let data = AppDefaults.sharedDefaults?.data(forKey: "timetable") else { return Timetable() }
            
            // Make timetable data accessible from extensions. Module name depends on
            // the component that calls get-method(). As only app stores data class names
            // must be mapped when reading.
            NSKeyedUnarchiver.setClass(Timetable.self, forClassName: "Pius_App.Timetable")
            NSKeyedUnarchiver.setClass(ScheduleForDay.self, forClassName: "Pius_App.ScheduleForDay")
            NSKeyedUnarchiver.setClass(CustomScheduleItem.self, forClassName: "Pius_App.CustomScheduleItem")
            NSKeyedUnarchiver.setClass(CustomScheduleItem.self, forClassName: "Pius_App.ExtraScheduleItem")
            NSKeyedUnarchiver.setClass(CourseItem.self, forClassName: "Pius_App.CourseItem")
            NSKeyedUnarchiver.setClass(FreeScheduleItem.self, forClassName: "Pius_App.FreeScheduleItem")
            NSKeyedUnarchiver.setClass(BreakScheduleItem.self, forClassName: "Pius_App.BreakScheduleItem")

            let value = NSKeyedUnarchiver.unarchiveObject(with: data) as! Timetable
            return value
        }
    }

    static var courses: Courses {
        set(value) {
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            AppDefaults.sharedDefaults?.set(data, forKey: "courses")
        }
        get {
            guard let data = AppDefaults.sharedDefaults?.data(forKey: "courses") else { return Courses() }
            let value = NSKeyedUnarchiver.unarchiveObject(with: data) as! Courses
            return value
        }
    }

    static var credentials: (String, String) {
        get {
            guard let webSiteUserName = AppDefaults.sharedDefaults?.string(forKey: "webSiteUserName"), !webSiteUserName.isEmpty else { return ("", "") };
            do {
                // We need to deal with recovery here. Password will not be restored from backuo, thus there might
                // situations where user is set but password is unset. Simply returning nil as password will crash
                // app.
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: "group.de.rmkrings.piusapp.widget");
                
                var webSitePassword_: String?;
                try webSitePassword_ = passwordItem.readPassword();
                
                if let webSitePassword = webSitePassword_ {
                    return (webSiteUserName, webSitePassword);
                } else {
                    return (webSiteUserName, "");
                }
            }
            catch {
                NSLog("Die Anmeldedaten konnten nicht geladen werden - \(error)");
                return (webSiteUserName, "");
            }
        }
    }
    
    static var username: String? {
        set(username) {
            sharedDefaults?.set(username, forKey: "webSiteUserName");
        }
        
        get {
            return sharedDefaults?.string(forKey: "webSiteUserName");
        }
    }
    
    static var password: String? {
        set(password) {
            do {
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: "group.de.rmkrings.piusapp.widget");
                try passwordItem.savePassword(password);
            }
            catch {
                NSLog("Das Password konnte nicht gespeichert werden - \(error)");
            }
        }
        
        get {
            let (_, password) = AppDefaults.credentials;
            return password;
        }
    }
    
    static var authenticated: Bool {
        set(authenticated) {
            sharedDefaults?.set(authenticated, forKey: "authenticated");
        }
        
        // Returns true when authenticated is set and there is a password set.
        // Password will be unset immediately after device restore from backup.
        get {
            if let authenticated = sharedDefaults?.bool(forKey: "authenticated"), let password = password {
                return authenticated && password != ""
            } else {
                return false;
            }
        }
    }
}
