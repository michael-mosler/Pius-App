//
//  AppDelegate.swift
//  Pius-App
//
//  Created by Michael on 25.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil);
    
    var navigationController: UINavigationController? {
        get {
            return window?.rootViewController as? UINavigationController;
        }
    }

    private var notificationCenter:  UNUserNotificationCenter {
        get {
            return UNUserNotificationCenter.current();
        }
    }

    // Get the root window navigation controller and set it's colour to our standard.
    private func configureNavigationController() {
        navigationController?.navigationBar.barTintColor = Config.colorPiusBlue;
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white];
    }

    private func setCategories(){
        let category = UNNotificationCategory(identifier: "substitution-schedule.changed", actions: [], intentIdentifiers: [], options: [])
        notificationCenter.setNotificationCategories([category])
    }
    
    // Register for push notification service.
    private func registerForPushNotifications(forApplication application: UIApplication) {
        notificationCenter.delegate = self;
        setCategories();

        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            print("Permission granted: \(granted)");

            guard granted else { return }
            self.getNotificationSettings();
        }
    }
    
    // Gets current push notifications settings when authorized registers for remote
    // notifications.
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            print("Notification settings: \(settings)");
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications();
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Current version.
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject;
        let version = nsObject as! String;

        // If new version migrate whatever needs to be and set version.
        if AppDefaults.version != version {
            // Make password accessible after first unlock.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: "group.de.rmkrings.piusapp.widget");
            passwordItem.setKSecAttrAccessibleAfterFirstUnlock();
            
            // Update version.
            AppDefaults.version = version;
        }
        
        registerForPushNotifications(forApplication: application);
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Delegate for opening app from widget. Host part of URL tells delegate which view controller to open.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        configureNavigationController();
        let host = url.host;
        guard host != nil else { return false };
        
        switch(host) {
        case "dashboard":
            if let dashboardViewController = storyboard.instantiateViewController(withIdentifier: "Dashboard") as? DashboardViewController {
                navigationController?.popToRootViewController(animated: false);
                navigationController?.pushViewController(dashboardViewController, animated: false);
            }
            
        case "settings":
            if let settingsViewController = self.storyboard.instantiateViewController(withIdentifier: "Einstellungen") as? EinstellungenViewController {
                navigationController?.popToRootViewController(animated: false);
                navigationController?.pushViewController(settingsViewController, animated: false);
            }
            
        default:
            return false;
       }
 
        return true;
    }
    
    // Register for 3d touch actions.
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        configureNavigationController();

        if (!AppDefaults.authenticated) {
            let alert = UIAlertController(title: "Anmeldung", message: "Um den Vertretungsplan oder das Dashboard benutzen zu können, musst Du dich zuerst in den Einstellungen anmelden.", preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                (action: UIAlertAction!) in
                if let settingsViewController = self.storyboard.instantiateViewController(withIdentifier: "Einstellungen") as? EinstellungenViewController {
                    self.navigationController?.popToRootViewController(animated: false);
                    self.navigationController?.pushViewController(settingsViewController, animated: false);
                }
            }));

            self.window?.rootViewController?.present(alert, animated: true, completion: nil);
            completionHandler(true);
            return;
        }

        switch(shortcutItem.type) {
        case "de.rmkrings.piusapp.vertretungsplan":
            if let vertretungsplanViewController = storyboard.instantiateViewController(withIdentifier: "Vertretungsplan") as? VertretungsplanViewController {
                navigationController?.popToRootViewController(animated: false);
                navigationController?.pushViewController(vertretungsplanViewController, animated: false);
            }
            completionHandler(true);
        case "de.rmkrings.piusapp.dashboard":
            guard Config.hasGrade else {
                let alert = UIAlertController(title: "Dashboard", message: "Um das Dashboard benutzen zu können, musst Du in den Einstellungen zuerst Deine Jahrgangsstufe festlegen.", preferredStyle: UIAlertControllerStyle.alert);
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
                    (action: UIAlertAction!) in
                    if let settingsViewController = self.storyboard.instantiateViewController(withIdentifier: "Einstellungen") as UIViewController? {
                        self.navigationController?.popToRootViewController(animated: false);
                        self.navigationController?.pushViewController(settingsViewController, animated: false);
                    }
                }));

                self.window?.rootViewController?.present(alert, animated: true, completion: nil);
                completionHandler(true);
                return;
            }

            if let dashboardViewController = storyboard.instantiateViewController(withIdentifier: "Dashboard") as? DashboardViewController {
                navigationController?.popToRootViewController(animated: false);
                navigationController?.pushViewController(dashboardViewController, animated: false);
            }
            completionHandler(true);
        default:
            print("Unknown quick action code \(shortcutItem.type) is being ignored.");
            completionHandler(false);
        }
    }
    
    // Callback which is called when device has been registered for remote notifications.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data);
        }
        
        let token = tokenParts.joined();
        print("Device Token: \(token)");
        
        Config.currentDeviceToken = token;
        let deviceTokenManager = DeviceTokenManager();
        deviceTokenManager.registerDeviceToken(token: token, subscribeFor: AppDefaults.gradeSetting);
    }
    
    // Callback which is called when registering for remote noftications has failed.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)");
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received remote notification");
        print(userInfo);

        /*
        let content = UNMutableNotificationContent()
        content.title = "Dein Vertretungsplan hat sich geändert!"
        content.body = "Buy some milk"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "substitution-schedule.changed"
        
        let identifier = "UYLLocalNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if let error = error {
                // Something went wrong
            }
        })
        */

        completionHandler(.newData);
    }
}
