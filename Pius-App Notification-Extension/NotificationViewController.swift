//
//  NotificationViewController.swift
//  Pius-App Notification-Extension
//
//  Created by Michael Mosler-Krings on 30.07.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
    }

}
