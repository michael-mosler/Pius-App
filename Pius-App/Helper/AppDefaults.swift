//
//  AppDefaults.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 23.06.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

/// This class gives access to all persistent settings.
struct AppDefaults {
    // API Key for middleware access
    static var apiKey: String {
        get {
            return Bundle.main.infoDictionary?["API_KEY"] as! String
        }
    }

    // Base-URL of our IBM Cloud Middlware
    static var baseUrl: String {
        get { Bundle.main.infoDictionary?["HOST_ADDRESS"] as! String }
    }
    
    // Shared configuration settings.
    private static let sharedDefaults = UserDefaults(suiteName: "group.de.rmkrings.piusapp.widget")
    static var version: String {
        set { AppDefaults.sharedDefaults?.set(newValue, forKey: "version") }
        get { AppDefaults.sharedDefaults?.string(forKey: "version") ?? "" }
    }

    static var hasShownFunctionHelp: [String:Bool] {
        set { AppDefaults.sharedDefaults?.set(newValue, forKey: "shownFunctionHelp") }
        get { AppDefaults.sharedDefaults?.dictionary(forKey: "shownFunctionHelp") as? [String:Bool] ?? [:] as [String : Bool] }
    }

    static var selectedGradeRow: Int? {
        set(selectedGradeRow) {
            AppDefaults.sharedDefaults?.set(selectedGradeRow, forKey: "selectedGradeRow")
        }
        
        get {
            let _selectedGradeRow = AppDefaults.sharedDefaults?.integer(forKey: "selectedGradeRow")
            guard _selectedGradeRow ?? 0 >= Config.grades.count else { return _selectedGradeRow }

            // IKD, IKE is configured. These has have been removed in version 3.1.
            // Reset grade to none.
            AppDefaults.selectedGradeRow = 0
            AppDefaults.selectedClassRow = 0
            return 0
        }
    }

    static var selectedClassRow: Int? {
        set(selectedClassRow) {
            AppDefaults.sharedDefaults?.set(selectedClassRow, forKey: "selectedClassRow")
        }
        
        get {
            return AppDefaults.sharedDefaults?.integer(forKey: "selectedClassRow")
        }
    }

    static var gradeSetting: String {
        get {
            guard let gradeSetting = AppDefaults.selectedGradeRow, let classSetting = AppDefaults.selectedClassRow else { return "" }
            return Config.shortGrades[gradeSetting] + Config.shortClasses[classSetting]
        }
    }

    static var hasLowerGrade: Bool {
        get {
            if let selectedGradeRow = selectedGradeRow {
                return Config.lowerGrades.firstIndex(of: Config.grades[selectedGradeRow]) != nil
            } else {
                return false
            }
        }
    }

    static var hasExtendedLowerGrade: Bool {
        get {
            if let selectedGradeRow = selectedGradeRow {
                return Config.extendedLowerGrades.firstIndex(of: Config.grades[selectedGradeRow]) != nil
            } else {
                return false
            }
        }
    }

    static var hasUpperGrade: Bool {
        get {
            if let selectedGradeRow = selectedGradeRow {
                return Config.upperGrades.firstIndex(of: Config.grades[selectedGradeRow]) != nil
            } else {
                return false
            }
        }
    }
    
    // Returns true when user has configured a grade.
    static var hasGrade: Bool {
        get {
            return AppDefaults.selectedGradeRow != 0
        }
    }

    static var courseList: [String]? {
        set(courseList) {
            AppDefaults.sharedDefaults?.set(courseList, forKey: "courseList")
        }
        
        get {
            return AppDefaults.sharedDefaults?.array(forKey: "courseList") as? [String]
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
            // let data = NSKeyedArchiver.archivedData(withRootObject: value)
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
                AppDefaults.sharedDefaults?.set(data, forKey: "timetable")
            } catch let error as NSError {
                NSLog("Failed to archive timetable: \(error.localizedDescription)")
            }
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

            do {
                guard let value = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Timetable else { return Timetable() }
                return value
            } catch let error as NSError {
                NSLog("Failed to unarchive timetable: \(error.localizedDescription)")
                return Timetable()
            }
        }
    }

    static var courses: Courses {
        set(value) {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: false)
                AppDefaults.sharedDefaults?.set(data, forKey: "courses")
            } catch let error as NSError {
                NSLog("Failed to archive courses: \(error.localizedDescription)")
            }
        }
        get {
            do {
                guard let data = AppDefaults.sharedDefaults?.data(forKey: "courses"),
                      let value = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Courses
                else { return Courses() }
                return value
            } catch let error as NSError {
                NSLog("Failed to unarchive courses: \(error.localizedDescription)")
                return Courses()
            }
        }
    }

    static var credentials: (String, String) {
        get {
            guard let webSiteUserName = AppDefaults.sharedDefaults?.string(forKey: "webSiteUserName"), !webSiteUserName.isEmpty else { return ("", "") }
            do {
                // We need to deal with recovery here. Password will not be restored from backuo, thus there might
                // situations where user is set but password is unset. Simply returning nil as password will crash
                // app.
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: "group.de.rmkrings.piusapp.widget")
                
                var webSitePassword_: String?
                try webSitePassword_ = passwordItem.readPassword()
                
                if let webSitePassword = webSitePassword_ {
                    return (webSiteUserName, webSitePassword)
                } else {
                    return (webSiteUserName, "")
                }
            }
            catch {
                NSLog("Die Anmeldedaten konnten nicht geladen werden - \(error)")
                return (webSiteUserName, "")
            }
        }
    }
    
    static var username: String? {
        set(username) {
            sharedDefaults?.set(username, forKey: "webSiteUserName")
        }
        
        get {
            return sharedDefaults?.string(forKey: "webSiteUserName")
        }
    }
    
    static var password: String? {
        set(password) {
            do {
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: "group.de.rmkrings.piusapp.widget")
                try passwordItem.savePassword(password)
            }
            catch {
                NSLog("Das Password konnte nicht gespeichert werden - \(error)")
            }
        }
        
        get {
            let (_, password) = AppDefaults.credentials
            return password
        }
    }
    
    static var authenticated: Bool {
        set(authenticated) {
            sharedDefaults?.set(authenticated, forKey: "authenticated")
        }
        
        // Returns true when authenticated is set and there is a password set.
        // Password will be unset immediately after device restore from backup.
        get {
            if let authenticated = sharedDefaults?.bool(forKey: "authenticated"), let password = password {
                return authenticated && password != ""
            } else {
                return false
            }
        }
    }
    
    /// Possible decisions on browser engine. Option ask will cause user to
    /// be asked every time a page needsto be opened in some kind of web view.
    enum BrowserSelection: Int {
        case useInternal = 0,
             useSafari = 1
    }

    /// Defines the browser to use when opening news pages. Default is
    /// to always ask user. User may decide to either use Safari,
    /// internal WebView or to be asked always.
    static var browser: BrowserSelection {
        set {
            sharedDefaults?.set(newValue.rawValue, forKey: "browser")
        }
        
        get {
            let rawSelectionValue = sharedDefaults?.integer(forKey: "browser") ?? 0
            return BrowserSelection(rawValue: rawSelectionValue) ?? .useInternal
        }
    }
    
    /// If true the app will remember users browser selection and it will not ask
    /// again when a web page is displayed. This can be changed in settings.
    static var rememberBrowserSelection: Bool {
        set {
            sharedDefaults?.setValue(newValue, forKey: "rememberBrowserSelection")
        }
        
        get {
            return sharedDefaults?.bool(forKey: "rememberBrowserSelection") ?? false
        }
    }
}
