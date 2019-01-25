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
    
    override init() {
        super.init()
        
        session.delegate = self
        session.activate()
        
        NSLog("%@", "Paired Watch: \(session.isPaired), Watch App Installed: \(session.isWatchAppInstalled)")
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("%@", "activationDidCompleteWith activationState:\(activationState)");
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session did deactivate")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        NSLog("%@", "sessionWatchStateDidChange: \(session)")
    }
    
    func doUpdate(vertretungsplan: Vertretungsplan?, online: Bool) {
        guard vertretungsplan != nil else {
            self.replyHandler!(["status": "error", "online": online])
            return
        }

        guard let encoded = try? JSONEncoder().encode(vertretungsplan),
            var dictionary = try? JSONSerialization.jsonObject(with: encoded, options: .allowFragments) as? [String: Any]
        else {
            self.replyHandler!(["status": "error", "online": online])
            return
        }

        dictionary!["status"] = "found"
        dictionary!["online"] = online
        self.replyHandler!(dictionary!)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        NSLog("didReceiveMessage: %@", message)
        if message["request"] as? String == "date" {
            let grade = AppDefaults.gradeSetting;
            let vertretungsplanLoader = VertretungsplanLoader(forGrade: grade);
            self.replyHandler = replyHandler;
            vertretungsplanLoader.load(doUpdate)
            
        }
    }
}
