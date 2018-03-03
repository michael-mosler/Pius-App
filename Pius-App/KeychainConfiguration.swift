/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    A simple struct that defines the service and access group to be used by the sample apps.
*/

import Foundation

struct KeychainConfiguration {
    static let serviceName = "PiusAppService";
    
    /*
     * Not specifying an access group to use with `KeychainPasswordItem` instances
     * will create items specific to each app.
     */
    static let accessGroup: String? = nil
}
