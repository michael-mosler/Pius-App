//
//  Cache.swift
//  Pius-App
//
//  Created by Michael on 10.05.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

/// Stores file on apps device storage.
class Cache {
    private let fileManager = FileManager.default;
    private let documentsURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first! as NSURL;
    private var documentsPath: String?;
    
    /// Constructor
    init() {
        documentsPath = documentsURL.path;
    }
    
    /// Gets the cache file URL for the given filename.
    /// - Parameter filename: Filename to get URL for. This file is supposed to be located on apps device storage.
    /// - Returns: URL for file access.
    func getCacheFileUrl(for filename: String) -> URL? {
        return documentsURL.appendingPathComponent(filename);
    }
    
    /// Check if file exists on apps device storage.
    /// - Parameter filename: Filename to check for existence
    /// - Returns: True if file exists
    func fileExists(filename: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: (getCacheFileUrl(for: filename)!).path);
    }

    /// Store data under given filename in cache directory.
    /// - Parameters:
    ///   - filename: Stores data objevz in cache file on device.
    ///   - data: Data object to store.
    func store(filename: String, data: Data) {
        do {
            try data.write(to: getCacheFileUrl(for: filename)!, options: [.atomic]);
        } catch {
            NSLog("Failed to cache item: \(error)");
        }
    }
    
    /// Read data from filename in cache directory. If data cannot
    /// be read returns nil. Supposes that file content is a string.
    /// - Parameter filename: Cache filename
    /// - Returns: Cache content as string object
    func read(filename: String) -> String? {
        var data: String? = nil;
        do {
            try data = String(contentsOf: getCacheFileUrl(for: filename)!);
        } catch {
            NSLog("Failed to read from cache: \(error)");
        }

        return data;
    }
    
    /// Read data from filename in cache directory. If data cannot
    /// be read returns nil. Supposes that file content is a string.
    /// - Parameter filename: Cache filename
    /// - Returns: Cache content as data object.
    func read(filename: String) -> Data? {
        var data: Data? = nil;
        do {
            try data = Data(contentsOf: getCacheFileUrl(for: filename)!);
        } catch {
            NSLog("Failed to read from cache: \(error)");
        }
        
        return data;
    }
}
