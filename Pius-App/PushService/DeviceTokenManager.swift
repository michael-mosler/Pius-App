//
//  DeviceTokenManagement.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 26.07.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

class DeviceTokenManager {
    let url = URL(string: "\(AppDefaults.baseUrl)/v2/deviceToken")!;
    var request: URLRequest;
    let version: String;

    init() {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        version = nsObject as! String

        // Set content type to application/json as this is what we are using for all
        // requests.
        request = URLRequest(url: url);
        var headers = request.allHTTPHeaderFields ?? [:];
        headers["Content-Type"] = "application/json";
        request.allHTTPHeaderFields = headers;
        request.httpMethod = "POST";
    }
    
    /**
     * Get user credentials as hashed SHA1 value. If user is not authenticated
     * then NULL is returned.
     */
    private var credential: String? {
        guard AppDefaults.authenticated, let username = AppDefaults.username, let password = AppDefaults.password
        else {
            return nil
        }
        
        let sha1String: String
        if #available(iOS 13.0, *) {
            let sha1 = Insecure.SHA1.hash(data: (username + password).data(using: .utf8)!)
            sha1String = sha1.map { String(format: "%02x", UInt8($0)) }.joined()
        } else {
            // Fallback on earlier versions
            let data = (username + password).data(using: .utf8)!
            var digest: [UInt8] = Array(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
            }
            sha1String = digest.map { String(format: "%02hhx", $0) }.joined()
        }

        return sha1String;
    }
    
    /**
     * Register device token in the middleware. Finally middleware will decide if registration
     * is possible or not. "Useless" tokens, i.e. such on which no push messages can be sent
     * will be ignored, e.g. Also if user is not logged in token will not be accepted.
     *
     * Data sent with registration is taken from app settings, thus, no parameters are taken
     * but app must make sure that configuration is up to date before registering token.
     */
    func registerDeviceToken() {
        guard let deviceToken = Config.currentDeviceToken else { return }
        
        let json: [String: Any] = [
            "apiKey": AppDefaults.apiKey,
            "deviceToken": deviceToken,
            "grade": AppDefaults.gradeSetting as Any,
            "courseList": AppDefaults.courseList as Any,
            "version": version,
            "credential": credential as Any
        ];
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json);
        request.httpBody = jsonData;
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Adding device token failed: \(error)");
                return;
            }
            
            if let response = (response as? HTTPURLResponse) {
                if response.statusCode != 200 {
                    NSLog("Adding device token failed with status \(response.statusCode)");
                    return;
                }
            }
        }

        task.resume();
    }
}
