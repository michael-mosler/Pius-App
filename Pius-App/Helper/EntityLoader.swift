//
//  EntityLoader.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 05.06.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import Foundation

/**
 * Delegate to process data loaded from a REST service.
 * entity defines the REST endpoint that is being used.
 * When data has been received first process() is called.
 * When process returns successfully onLoad() is called.
 * onLoad() also expects the online status as 2nd argument.
 */
protocol EntityLoaderDelegate {
    var entity: String { get set }
    var onLoad: (Any?, Bool) -> Void { get set }
    init(onLoad: @escaping (Any?, Bool) -> Void)
    func process(_ jsonData: [String: Any]) -> Any?
}

/**
 * An abstract entity loader class. This class fetches data from a given REST service
 * and expects an EntityLoaderDelegate to which data processing will be delegated.
 * When data has been processed successfully outcome will be passed to delegates
 * onLoad() method.
 */
class EntityLoader: NSObject {
    private var entity: String
    private var version: String?
    private var baseUrl: String { return "\(AppDefaults.baseUrl)/\(self.version != nil ? self.version! + "/" : "")\(self.entity)" }
    var cacheFileName: String { return "\(self.entity).json" }
    var digestFileName: String { return "\(self.entity).md5" }

    var digest: String?
    let cache = Cache()
    
    init(forEntity entity: String, version: String? = nil) {
        self.entity = entity
        self.version = version
        super.init()

        // If cache file exists we may use digest to detect changes in Vertretungsplan. Without cache file
        // we need to request data.
        var digest: String? = nil
        if cache.fileExists(filename: digestFileName) {
            digest = cache.read(filename: digestFileName)
        } else {
            NSLog("Cache file \(cacheFileName) does not exist. Not sending digest.")
        }
                
        self.digest = digest
    }
    
    // Returns URL request object depending on the connection status of the app.
    // If online a web URL request is returned, when offline cache URL request
    // object is returned instead.
    func getURLRequest(_ piusGatewayIsReachable: Bool) -> URLRequest {
        var request: URLRequest
        
        if (piusGatewayIsReachable) {
            var requestUrl = baseUrl
            if let digest = digest {
                requestUrl.append("?digest=\(digest)")
            }

            request = URLRequest(url: URL(string: requestUrl)!, cachePolicy: .reloadIgnoringLocalCacheData)
            request.httpMethod = "GET"
        } else {
            request = URLRequest(url: cache.getCacheFileUrl(for: cacheFileName)!)
        }
        
        return request
    }
    
    // Prepares all generic properties and then delegates request to
    // loaderDelegate.runRequest.
    func load(withLoaderDelegate loaderDelegate: EntityLoaderDelegate) {
        let reachability = Reachability()
        let isOnline = reachability!.connection != .none
        let request = getURLRequest(isOnline)

        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
                NSLog("Entity loader for \(loaderDelegate.entity) had error: \(error)")
                loaderDelegate.onLoad(nil, isOnline)
                return
            }
            
            // Cached data is not modified. This can be checked in online mode only.
            // In offline mode _data will come from cache already if available.
            var data: Data?
            let isUnmodified = isOnline && ((response as! HTTPURLResponse).statusCode == 304)
            if isUnmodified {
                data = self.cache.read(filename: self.cacheFileName)
                NSLog("Data for entity \(loaderDelegate.entity) has not changed. Using data from cache.")
            } else if let responseData = responseData {
                data = responseData
                self.cache.store(filename: self.cacheFileName, data: responseData)
            }

            if let data = data {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        // If digest is given store it.
                        if !isUnmodified, let digest = jsonData["_digest"] as! String? {
                            self.cache.store(filename: self.digestFileName, data: digest.data(using: .utf8)!)
                        }

                        let processResult = loaderDelegate.process(jsonData)
                        loaderDelegate.onLoad(processResult, isOnline)
                    } else {
                        loaderDelegate.onLoad(nil, isOnline)
                    }
                } catch let error as NSError {
                    NSLog(error.localizedDescription)
                    loaderDelegate.onLoad(nil, isOnline)
                }
            } else {
                loaderDelegate.onLoad(nil, isOnline)
            }
        }
        
        task.resume()
    }
}
