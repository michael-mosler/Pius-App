//
//  StaffLoader.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 24.05.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import Foundation

protocol EntityLoaderDelegate {
    var entity: String { get set }
    var onLoad: (Any?, Bool) -> Void { get set }
    init(onLoad: @escaping (Any?, Bool) -> Void)
    func process(_ jsonData: [String: Any]) -> Any?
}

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

struct StaffMember {
    var name: String
    var subjects: [String]
    
    init(fromJSON: [String: Any]) {
        guard let name = fromJSON["name"] as? String,
            let subjects = fromJSON["subjects"] as? [String]
            else {
                self.name = ""
                self.subjects = []
                return
        }
        self.name = name
        self.subjects = subjects
    }
}

typealias StaffDictionary = [String : StaffMember]

/**
 * Loads staff dictionary from Pius website and refreshes cache. Other then
 * common loaders load() updates cache only but does not return dictionary.
 * This is because staff dictionary is refreshed once on app start.
 * When staff shall be looked up use loadFromCache() method. This
 * returns a StaffDictionary dictionary object.
 */
class StaffLoader: EntityLoader, EntityLoaderDelegate {
    var entity: String = "staff";
    var onLoad: (Any?, Bool) -> Void

    init() {
        self.onLoad = { object, bool in }
        super.init(forEntity: entity, version: "v2")
    }

    required init(onLoad: @escaping (Any?, Bool) -> Void) {
        self.onLoad = onLoad
        super.init(forEntity: entity, version: "v2")
    }

    /**
     * Empty callback as staff shall be pre-loaded to update cache.
     * Use loadFromCache() to dictionary for lookup.
     */
    func process(_ jsonData: [String : Any]) -> Any? {
        return nil
    }
    
    /**
     * Load dictionary from cache. If the dictionary cannot be read
     * for any reason an empty one is returned, instead.
     */
    func loadFromCache() -> StaffDictionary {
        guard cache.fileExists(filename: cacheFileName) else { return [ : ] }
        guard let data = cache.read(filename: cacheFileName) as Data? else { return [ : ] }
        
        do {
            // Try to parse JSON from server. If this throws we will return an empty
            // dictionary.
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
            
            // Access staff dictionary in JSON. If this is not present return empty dictionary.
            guard let dictionaryJSON = json["staffDictionary"] as? [String: Any] else { return [ : ] }
            
            var staffDictionary: StaffDictionary = [ : ]
            for (shortHandSymbol, infoJSON) in dictionaryJSON {
                let staffMember = StaffMember(fromJSON: infoJSON as! [String: Any])
                staffDictionary[shortHandSymbol] = staffMember
            }

            return staffDictionary
        } catch let error as NSError {
            NSLog(error.localizedDescription)
            return [ : ]
        }
    }
}
