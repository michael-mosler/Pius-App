//
//  PostingsLoader.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 10.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

/*
 * ====================================================
 *              News Item Data Model
 * ====================================================
 */

struct PostingsItem {
    var message: String;
    var timestamp: String;
    
    init(message: String, timestamp: String) {
        self.message = message;
        self.timestamp = timestamp;
    }
}

typealias PostingsItems = [PostingsItem];

class PostingsLoader {
    private var url: URL?;
    
    private let baseUrl = "\(AppDefaults.baseUrl)/v2/postings";
    private let cache = Cache();
    private var cacheFileName: String { get { return "postings.json"; } };
    private var digestFileName: String { get { return "postings.md5"; } };
    
    private var digest: String?;
    
    init() {
        var digest: String? = nil;
        
        // If cache file exists we may use digest to detect changes in Vertretungsplan. Without cache file
        // we need to request data.
        if (self.cache.fileExists(filename: cacheFileName)) {
            digest = cache.read(filename: digestFileName);
        } else {
            print("Cache file \(cacheFileName) does not exist. Not sending digest.");
        }
        
        self.digest = digest;
        
        var urlString = baseUrl;
        if (digest != nil) {
            urlString.append(String(format: "?digest=%@", digest!));
        }
        
        self.url = URL(string: urlString);
    }
    
    // Returns URL request object depending on the connection status of the app.
    // If online a web URL request is returned, when offline cache URL request
    // object is returned instead.
    private func getURLRequest(_ piusGatewayIsReachable: Bool) -> URLRequest {
        var request: URLRequest;
        
        if (piusGatewayIsReachable) {
            request = URLRequest(url: url!);
            request.httpMethod = "GET";
        } else {
            request = URLRequest(url: cache.getCacheFileUrl(for: cacheFileName)!);
        }
        
        return request;
    }
    
    // Loads Postings from backend and converts data that has been received in JSON
    // format into internal data structures. Finally calls update() method. This method is
    // intented for updating the view from the model that has been built from JSON.
    // In case of an error update() will be called with nil-data. Boolean value indicates
    // is application currently is online or not.
    func load(_ update: @escaping (PostingsItems?, Bool) -> Void) {
        let reachability = Reachability();
        let piusGatewayIsReachable = reachability!.connection != .none;
        let request = getURLRequest(piusGatewayIsReachable);
        
        // Create task to get data in background.
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            var data_: Data? = data;
            
            // Request error. In this case nothing more is to be done here. Inform user and exit.
            if let error = error {
                print("Postings Loader had error: \(error)");
                update(nil, piusGatewayIsReachable);
                return;
            }
            
            // Cached data is not modified. This can be checked in online mode only.
            // In offline mode _data will come from cache already if available.
            let notModified = piusGatewayIsReachable == true && ((response as! HTTPURLResponse).statusCode == 304);
            if (notModified) {
                data_ = self.cache.read(filename: self.cacheFileName);
                print("Postings have not changed. Using data from cache.");
            }
            
            if let data = data_ {
                var postingsItems: PostingsItems = [];
                
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any];
                    
                    // If in online mode store current Postings in cache. Here we are sure that data is valid
                    // and could be parsed to JSON. If News has been read from cache already we do not
                    // re-save it.
                    if (piusGatewayIsReachable && notModified == false) {
                        self.cache.store(filename: self.cacheFileName, data: data);
                    }
                    
                    // Store message digest for data cached before. If digest is unchanged this can be skipped.
                    if notModified == false, let json = jsonSerialized, let _digest = json["_digest"] as! String? {
                        let cache = Cache();
                        cache.store(filename: self.digestFileName, data: _digest.data(using: .utf8)!);
                    }
                    
                    if let json = jsonSerialized, let postingsItems_ = json["messages"] as! [Any]? {
                        // ... and iterate on all of them. This the top level of our Vertretungsplan.
                        for postingsItem_ in postingsItems_ {
                            // Convert news item element to dictionary that is indexed by string.
                            let dictionary = postingsItem_ as! [String: String];
                            
                            if let message = dictionary["message"], let timestamp = dictionary["timestamp"] {
                                let postingsItem = PostingsItem(message: message, timestamp: timestamp);
                                postingsItems.append(postingsItem);
                            }
                        }
                    }
                    
                    update(postingsItems, piusGatewayIsReachable);
                }  catch let error as NSError {
                    print(error.localizedDescription);
                    update(nil, piusGatewayIsReachable);
                }
            } else if let error = error {
                print(error.localizedDescription)
                update(nil, piusGatewayIsReachable);
            }
        }
        
        // Now get execute task and, thus, get data. This also updates all views.
        task.resume();
    }
}
