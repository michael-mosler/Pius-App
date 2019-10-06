//
//  EvaLoader.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 16.02.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation

struct EvaItem {
    var uuid: String;
    var course: String;
    var evaText: String;
    
    init(_ uuid: String, _ course: String, _ evaText: String) {
        self.uuid = uuid;
        self.course = course;
        self.evaText = evaText;
    }
}

struct EvaCollection {
    var date: String;
    var evaItems: [EvaItem];
    
    init(_ date: String, _ evaItems: [[String: String]]) {
        self.date = date;
        self.evaItems = evaItems.map  {
            EvaItem($0["uuid"]!, $0["course"]!, $0["evaText"]!);
        }
    }
}

struct EvaDoc {
    var evaCollections: [EvaCollection];
    
    init(_ evaCollections: [[String: Any]]) {
        self.evaCollections = evaCollections.map {
            EvaCollection($0["date"] as! String, $0["evaItems"] as! [[String: String]]);
        }
    }
}

class EvaLoader {
    private var url: URL?;
    
    private let baseUrl = "\(AppDefaults.baseUrl)/v2/eva";
    private let cache = Cache();
    private var cacheFileName: String { get { return "eva.json"; } };
    private var digestFileName: String { get { return "eva.md5"; } };
    
    private var digest: String? = nil;
    
    init(grade: String, courseList: [String] = [], limit: Int = 10) {
        // If cache file exists we may use digest to detect changes in Vertretungsplan. Without cache file
        // we need to request data.
        if (self.cache.fileExists(filename: cacheFileName)) {
            self.digest = cache.read(filename: digestFileName);
        } else {
            NSLog("Cache file \(cacheFileName) does not exist. Not sending digest.");
        }
        
        var urlString = baseUrl;
        urlString.append(String(format: "?grade=%@", grade));

        if courseList.count > 0 {
            let mappedCourseList = courseList.reduce(into: "") { (result, course) in
                let mappedCourse = CourseItem.normalizeCourseName(course)
                result += (result.count == 0) ? mappedCourse : ",\(mappedCourse)";
            };
            urlString.append(String(format: "&courseList=%@", mappedCourseList));
        }

        if let digest = self.digest {
            urlString.append(String(format: "&digest=%@", digest));
        }
        
        self.url = URL(string: urlString);
    }
    
    // Get username and password from settings and set up basic authentication
    // header login string.
    private func getAndEncodeCredentials(username: String? = nil, password: String? = nil) -> String {
        var realUsername: String;
        var realPassword: String;
        if (username == nil && password == nil) {
            (realUsername, realPassword) = AppDefaults.credentials;
        } else {
            realUsername = username!;
            realPassword = password!;
        }
        
        let loginString = String(format: "%@:%@", realUsername, realPassword);
        let loginData = loginString.data(using: String.Encoding.utf8)!
        return loginData.base64EncodedString();
    }

    // Returns URL request object depending on the connection status of the app.
    // If online a web URL request is returned, when offline cache URL request
    // object is returned instead.
    private func getURLRequest(_ piusGatewayIsReachable: Bool) -> URLRequest {
        let base64LoginString = getAndEncodeCredentials();
        var request: URLRequest;
        
        if (piusGatewayIsReachable) {
            request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData);
            request.httpMethod = "GET";
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization");
        } else {
            request = URLRequest(url: cache.getCacheFileUrl(for: cacheFileName)!);
        }
        
        return request;
    }
    
    // Loads EVA data from backend and converts data that has been received in JSON
    // format into internal data structures. Finally calls update() method. This method is
    // intented for updating the view from the model that has been built from JSON.
    // In case of an error update() will be called with nil-data. Boolean value indicates
    // is application currently is online or not.
    func load(_ update: @escaping (EvaDoc?, Bool) -> Void) {
        let reachability = Reachability();
        let piusGatewayIsReachable = reachability!.connection != .none;
        let request = getURLRequest(piusGatewayIsReachable);
        
        // Create task to get data in background.
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            var _data: Data? = data;
            
            // Request error. In this case nothing more is to be done here. Inform user and exit.
            if let error = error {
                NSLog("EVA Loader had error: \(error)");
                update(nil, piusGatewayIsReachable);
                return;
            }
            
            // Cached data is not modified. This can be checked in online mode only.
            // In offline mode _data will come from cache already if available.
            let notModified = piusGatewayIsReachable == true && ((response as! HTTPURLResponse).statusCode == 304);
            if (notModified) {
                _data = self.cache.read(filename: self.cacheFileName);
                NSLog("EVA data has not changed. Using data from cache.");
            }
            
            if let data = _data {
                var evaDoc: EvaDoc? = nil;
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any];
                    
                    // If in online mode store current Calendar in cache. Here we are sure that data is valid
                    // and could be parsed to JSON. If Vertretungsplan has been read from cache already we do not
                    // re-save it.
                    if (piusGatewayIsReachable && notModified == false) {
                        self.cache.store(filename: self.cacheFileName, data: data);
                    }
                    
                    // Store message digest for data cached before. If digest is unchanged this can be skipped.
                    if notModified == false, let json = jsonSerialized, let _digest = json["_digest"] as! String? {
                        let cache = Cache();
                        cache.store(filename: self.digestFileName, data: _digest.data(using: .utf8)!);
                    }
                    
                    if let json = jsonSerialized, let evaData = json["evaData"] as! [[String: Any]]? {
                        evaDoc = EvaDoc(evaData);
                    }
                    
                    update(evaDoc, piusGatewayIsReachable);
                }  catch let error as NSError {
                    NSLog(error.localizedDescription);
                    update(nil, piusGatewayIsReachable);
                }
            } else if let error = error {
                NSLog(error.localizedDescription)
                update(nil, piusGatewayIsReachable);
            }
        }
        
        // Now get execute task and, thus, get data. This also updates all views.
        task.resume();
    }
}
