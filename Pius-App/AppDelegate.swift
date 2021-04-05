//
//  AppDelegate.swift
//  Pius-App
//
//  Created by Michael on 25.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WatchConnectivity
import UserNotifications
import Sheeeeeeeeet

@UIApplicationMain
/// App Delegate class. This class handles all messages that are received and processed
/// by this app.
class AppDelegate:
    UIResponder,
    UIApplicationDelegate,
    UNUserNotificationCenterDelegate
{
    
    var window: UIWindow?
    private let storyboard = UIStoryboard(name: "Main", bundle: nil)
    private let reachability = Reachability()
    private var connectivityHandler: WatchConnectivityHandler?

    var navigationController: UINavigationController? {
        get {
            return window?.rootViewController as? UINavigationController
        }
    }

    private var notificationCenter:  UNUserNotificationCenter {
        get {
            return UNUserNotificationCenter.current()
        }
    }

    /// Get the root window navigation controller and set it's colour to our standard.
    private func configureNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "piusBlue")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.isToolbarHidden = false
    }
    
    /// Sets push notification categories.
    private func setCategories(){
        let category = UNNotificationCategory(identifier: "substitution-schedule.changed", actions: [], intentIdentifiers: [], options: [])
        notificationCenter.setNotificationCategories([category])
    }
    
    /// Register for push notification service.
    /// - Parameter application: This application
    private func registerForPushNotifications(forApplication application: UIApplication) {
        notificationCenter.delegate = self
        setCategories()

        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            NSLog("Permission granted: \(granted)")

            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    /// Gets current push notifications settings when authorized registers for remote
    /// notifications.
    func getNotificationSettings() {
        notificationCenter.getNotificationSettings { (settings) in
            NSLog("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    /// Application launch delegate
    /// - Parameters:
    ///   - application: This application
    ///   - launchOptions: App launching options
    /// - Returns: True when request has been handled
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Apply appearances
        UITextField.appearance().tintColor = UIColor(named: "piusBlue")
        ActionSheet.applyAppearance(PiusAppActionSheetAppearance(), force: true)
        
        // Reachability
        reachability?.whenReachable = { _ in
            let tbc = self.window?.rootViewController as! UITabBarController
            let tb = tbc.tabBar
            tb.tintColor = UIColor(named: "piusBlue")
        }
        reachability?.whenUnreachable = { _ in
            let tbc = self.window?.rootViewController as! UITabBarController
            let tb = tbc.tabBar
            tb.tintColor = Config.colorRed
        }

        do {
            try reachability?.startNotifier()
        } catch {
            NSLog("Unable to start notifier")
        }

        // Create Watch Connectivity Handler
        if WCSession.isSupported() {
            NSLog("Activating Watch Connectivity Handler")
            self.connectivityHandler = WatchConnectivityHandler()
        }
        
        // Current version.
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        
        // If new version migrate whatever needs to be and set version.
        if Config.alwaysShowOnboarding || AppDefaults.version != version {
            // Make password accessible after first unlock.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: "group.de.rmkrings.piusapp.widget")
            passwordItem.setKSecAttrAccessibleAfterFirstUnlock()
            
            // Migrate SOWI -> SW
            if let courseList = AppDefaults.courseList {
                let mappedCourseList = courseList.map { value -> String in
                    return value.replacingOccurrences(of: "SOWI", with: "SW")
                }
                
                AppDefaults.courseList = mappedCourseList
            }
            
            // Update version.
            AppDefaults.version = version
            Config.showOnboarding = true
        }
        
        registerForPushNotifications(forApplication: application)
        
        // Refresh staff dictionary.
        let staffLoader = StaffLoader(onLoad: { object, bool in })
        staffLoader.load(withLoaderDelegate: staffLoader)
        
        return true
    }

    /// Delegate for opening app from widget. Host part of URL tells delegate which view controller to open.
    /// - Parameters:
    ///   - app: This application
    ///   - url: URL app is launched with
    ///   - options: Open URL options
    /// - Returns: true when URL has been handled.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        configureNavigationController()
        guard let host = url.host else { return false }
        
        switch(host) {
        case "today":
            let tbc = window?.rootViewController as! UITabBarController
            let today = tbc.viewControllers![0]
            tbc.selectedViewController = today

        case "dashboard":
            let tbc = window?.rootViewController as! UITabBarController
            let dashboard = tbc.viewControllers![2]
            tbc.selectedViewController = dashboard
            
        case "settings":
            let tbc = window?.rootViewController as! UITabBarController
            let settings = tbc.viewControllers![4]
            tbc.selectedViewController = settings
            
        default:
            return false
        }
        
        return true
    }
    
    /// Register for 3d touch actions.
    /// - Parameters:
    ///   - application: This application
    ///   - shortcutItem: 3d action shortcut used
    ///   - completionHandler: Handler that must be called on completion
    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void) {
        
        configureNavigationController()
        switch(shortcutItem.type) {
        case "de.rmkrings.piusapp.vertretungsplan":
            let tbc = window?.rootViewController as! UITabBarController
            let dashboard = tbc.viewControllers![1]
            tbc.selectedViewController = dashboard
            completionHandler(true)
            return

        case "de.rmkrings.piusapp.dashboard":
            let tbc = window?.rootViewController as! UITabBarController
            let dashboard = tbc.viewControllers![2]
            tbc.selectedViewController = dashboard
            completionHandler(true)
            return
 
        default:
            NSLog("Unknown quick action code \(shortcutItem.type) is being ignored.")
            completionHandler(false)
        }
    }

    /// Callback which is called when device has been registered for remote notifications.
    /// - Parameters:
    ///   - application: This application
    ///   - deviceToken: Device token for instance of this app
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        Config.currentDeviceToken = token
        let deviceTokenManager = DeviceTokenManager()
        deviceTokenManager.registerDeviceToken()
    }
    
    /// Callback which is called when registering for remote noftications has failed.
    /// - Parameters:
    ///   - application: This application
    ///   - error: Error description
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("Failed to register: \(error)")
    }
    
    /// Navigate to specific view controller when app is opened by tapping on a push notification.
    /// - Parameter userInfo: Push message payload
    private func navigateToViewControllerOnNotification(withUserInfo userInfo: [AnyHashable : Any]) {
        configureNavigationController()
        
        let tbc = window?.rootViewController as! UITabBarController
        let dashboard = tbc.viewControllers![2]
        tbc.selectedViewController = dashboard

        let dashboardChangesViewController = storyboard.instantiateViewController(withIdentifier: "ChangeDetails") as! DashboardChangesViewController
        dashboardChangesViewController.data = userInfo as NSDictionary
        window?.rootViewController?.show(dashboardChangesViewController, sender: self)
    }

    //
    /// Received remote notification when app is running.
    /// - Parameters:
    ///   - application: This application
    ///   - userInfo: Push message payload
    ///   - completionHandler: Completion handler to call
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)-> Void)
    {
        self.navigateToViewControllerOnNotification(withUserInfo: userInfo)
        completionHandler(.newData)
    }

    /// Show notification when app is running in foreground.
    /// - Parameters:
    ///   - center: Notification center instance
    ///   - notification: Notification
    ///   - completionHandler: Completion handlet to call
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound])
    }
}
