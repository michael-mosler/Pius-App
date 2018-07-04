//
//  AppDelegate.swift
//  Pius-App
//
//  Created by Michael on 25.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil);
    
    var navigationController: UINavigationController? {
        get {
            return window?.rootViewController as? UINavigationController;
        }
    }
    
    // Get the root window navigation controller and set it's colour to our standard.
    private func configureNavigationController() {
        navigationController?.navigationBar.barTintColor = Config.colorPiusBlue;
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white];
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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

    // Delegate for opening app from widget. This will be called only if dashboard has been
    // configured as otherwise widget will refuse to work.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dashboardViewController = storyboard.instantiateViewController(withIdentifier: "Dashboard") as? DashboardViewController {
            navigationController?.popToRootViewController(animated: false);
            navigationController?.pushViewController(dashboardViewController, animated: false);
        }

        return true;
    }
    
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
}
