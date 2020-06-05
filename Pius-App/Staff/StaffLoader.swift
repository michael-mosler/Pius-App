//
//  StaffLoader.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 24.05.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import Foundation

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
