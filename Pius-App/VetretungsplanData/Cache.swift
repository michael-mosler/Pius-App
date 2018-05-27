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

    func fileExists(filename: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: (getCacheFileUrl(for: filename)!).path);
    }

    // Store data under given filename in cache directory.
    func store(filename: String, data: Data) {
        do {
            try data.write(to: getCacheFileUrl(for: filename)!, options: [.atomic]);
        } catch {
            print("Failed to cache item: \(error)");
        }
    }
    
    // Read data from filename in cache directory. If data cannot
    // be read returns nil. Supposes that file content is a string.
    func read(filename: String) -> String? {
        var data: String? = nil;
        do {
            try data = String(contentsOf: getCacheFileUrl(for: filename)!);
        } catch {
            print("Failed to read from cache: \(error)");
        }

        return data;
    }
    
    // Read data from filename in cache directory. If data cannot
    // be read returns nil. Supposes that file content is a string.
    func read(filename: String) -> Data? {
        var data: Data? = nil;
        do {
            try data = Data(contentsOf: getCacheFileUrl(for: filename)!);
        } catch {
            print("Failed to read from cache: \(error)");
        }
        
        return data;
    }
}
