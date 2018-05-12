//
//  ReachabilityChecker.swift
//  Pius-App
//
//  Created by Michael on 10.05.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation
import SystemConfiguration

class ReachabilityChecker {
    private var name: String?;
    private var reachability: SCNetworkReachability?;
    
    init(forName name: String) {
        reachability = SCNetworkReachabilityCreateWithName(nil, name);
    }
    
    // Gets reachability flags of the reachability property.
    private func getFlags() -> SCNetworkReachabilityFlags {
        var flags = SCNetworkReachabilityFlags();
        SCNetworkReachabilityGetFlags(reachability!, &flags);
        return flags;
    }
    
    // Checks if the address passed into constructor is reachable. Returns true if yes and
    // false otherwise.
    func isNetworkReachable() -> Bool {
        let flags = getFlags();
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        return isReachable && (!needsConnection || canConnectWithoutUserInteraction)
    }
}
