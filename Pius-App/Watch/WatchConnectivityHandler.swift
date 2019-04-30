//
//  WatchConnectivityHandler.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 22.01.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectivityHandler: NSObject, WCSessionDelegate {
    var session = WCSession.default
    var replyHandler: (([String: Any]) -> Void)?
    
    // Strict dashboard check: App must be fully configured for watch app to be able
    // to show substituion schedule.
    private var canUseDashboard: Bool {
        get {
            if AppDefaults.authenticated && (AppDefaults.hasLowerGrade || (AppDefaults.hasUpperGrade && AppDefaults.courseList != nil && AppDefaults.courseList!.count > 0)) {
                if let _ = AppDefaults.selectedGradeRow, let _ = AppDefaults.selectedClassRow {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }

    override init() {
        super.init()
        
        session.delegate = self
        session.activate()
        
        NSLog("%@", "Paired Watch: \(session.isPaired), Watch App Installed: \(session.isWatchAppInstalled)")
    }

    /*
     * ====================================================
     *             Session Handler Protocol
     * ====================================================
     */
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            NSLog("%@", "activationDidCompleteWith error: activationState:\(activationState), error: \(error)")
        } else {
            NSLog("%@", "activationDidCompleteWith: activationState:\(activationState)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        NSLog("session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        NSLog("session did deactivate")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        NSLog("%@", "sessionWatchStateDidChange: \(session)")
    }
    
    // Send dashboard data to watch app.
    private func doUpdate(vertretungsplan: Vertretungsplan?, online: Bool) {
        guard vertretungsplan != nil else {
            self.replyHandler!(["status": "error", "online": online])
            return
        }

        guard let encoded = try? JSONEncoder().encode(vertretungsplan),
            var dictionary = ((try? JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: Any]) as [String : Any]??)
        else {
            self.replyHandler!(["status": "error", "online": online])
            return
        }

        dictionary!["status"] = "loaded"
        dictionary!["online"] = online
        self.replyHandler!(dictionary!)
    }

    // Process watch app requests. This is the only callback we use.
    // Currently the only supported request is "dashboard".
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if message["request"] as? String == "dashboard" {
            guard canUseDashboard else {
                replyHandler(["status": "notConfigured"])
                return
            }

            let grade = AppDefaults.gradeSetting;
            let vertretungsplanLoader = VertretungsplanLoader(forGrade: grade);
            self.replyHandler = replyHandler;
            vertretungsplanLoader.load(doUpdate)            
        }
    }
}
