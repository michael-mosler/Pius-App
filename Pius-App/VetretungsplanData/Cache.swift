//
//  Cache.swift
//  Pius-App
//
//  Created by Michael on 10.05.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

class Cache {
    private let fileManager = FileManager.default;
    private let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL;
    private var documentsPath: String?;
    
    init() {
        documentsPath = documentsURL.path;
    }
    
    // Gets the cache file URL for the given filename.
    func getCacheFileUrl(for filename: String) -> URL? {
        return documentsURL.appendingPathComponent(filename);
    }

    // Store data under given filename in cache directory.
    func store(filename: String, data: Data) {
        do {
            try data.write(to: getCacheFileUrl(for: filename)!, options: [.atomic]);
        } catch {
            print("Failed to cache item: \(error)");
        }
    }
}
