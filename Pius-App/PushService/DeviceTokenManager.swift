//
//  DeviceTokenManagement.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 26.07.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

class DeviceTokenManager {
    let url = URL(string: "\(AppDefaults.baseUrl)/deviceToken")!;
    var request: URLRequest;

    init() {
        request = URLRequest(url: url);
        
        // Set content type to application/json as this is what we are using for all
        // requests.
        var headers = request.allHTTPHeaderFields ?? [:];
        headers["Content-Type"] = "application/json";
        request.allHTTPHeaderFields = headers;
        request.httpMethod = "POST";
    }
    
    // Register device token in the middleware.
    func registerDeviceToken(token: String, subscribeFor grade: String? = nil, withCourseList courseList: [String]? = nil) {
        let json: [String: Any] = [
            "apiKey": AppDefaults.apiKey,
            "deviceToken": token,
            "grade": grade as Any,
            "courseList": courseList as Any
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
