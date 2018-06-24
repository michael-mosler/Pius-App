//
//  AppDefaults.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 23.06.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

struct AppDefaults {
    // Base-URL of our IBM Cloud Middlware
    static var baseUrl: String {
        get {
            return "https://pius-gateway.eu-de.mybluemix.net";
        }
    }
    
    // Shared configuration settings.
    private static let sharedDefaults = UserDefaults(suiteName: "group.de.rmkrings.piusapp.widget");
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

    static var courseList: [String]? {
        set(courseList) {
            AppDefaults.sharedDefaults?.set(courseList, forKey: "courseList");
        }
        
        get {
            return AppDefaults.sharedDefaults?.array(forKey: "courseList") as? [String];
        }
    }
    
    static var credentials: (String, String) {
        get {
            do {
                guard let webSiteUserName = sharedDefaults?.string(forKey: "webSiteUserName"), !webSiteUserName.isEmpty else { return ("", "") };
                
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
                if let password = password {
                    try passwordItem.savePassword(password);
                }
            }
            catch {
                fatalError("Das Password konnte nicht gespeichert werden - \(error)");
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
        
        get {
            if let authenticated = sharedDefaults?.bool(forKey: "authenticated") {
                return authenticated
            } else {
                return false;
            }
        }
    }
}
