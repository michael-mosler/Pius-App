//
//  VertretungsplanLoader.swift
//  Pius-App
//
//  Created by Michael on 26.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

/// Loader for Vertretungsplan.
class VertretungsplanLoader {
    private var matchEmptyCourse: NSRegularExpression?
    private var forGrade: String?
    private var url: URL?
    private let cache = Cache()
    private var cacheFileName: String = ""
    private var digestFileName: String = ""
    private var digest: String?
    
    /// Instantiates VertretungsplanLoader for a given grade or nil when full is requested.
    /// loadFromCache() or load must be called to get Vertretungsplan.
    /// - Parameter forGrade: Grade for which Veretretungsplan is requested.
    init(forGrade: String? = nil) {
        var _digest: String? = nil
        let _cacheFileName: String = (forGrade != nil) ? String(format: "%@.json", forGrade!) : "vertretungsplan.json"
        let _digestFileName: String = (forGrade != nil) ? String(format: "%@.md5", forGrade!) : "vertretungsplan.md5"

        // If cache file exists we may use digest to detect changes in Vertretungsplan. Without cache file
        // we need to request data.
        if (self.cache.fileExists(filename: _cacheFileName) && self.cache.fileExists(filename: _digestFileName)) {
            _digest = cache.read(filename: _digestFileName)
        } else {
            NSLog("Cache file \(_cacheFileName) does not exist. Not sending digest.")
        }

        self.forGrade = forGrade
        self.digest = _digest
        
        var urlString = "\(AppDefaults.baseUrl)/v2/vertretungsplan"
        if (forGrade != nil || _digest != nil) {
            var separator = "/?"
            if (forGrade != nil) {
                urlString.append(String(format: "%@forGrade=%@", separator, forGrade!))
                separator = "&"
            }
            
            if (_digest != nil) {
                urlString.append(String(format: "%@digest=%@", separator, _digest!))
            }
        }
        
        self.url = URL(string: urlString)
        self.cacheFileName = _cacheFileName
        self.digestFileName = _digestFileName

        // This expression matches a missing course that is indicated by dashes or blanks.
        do {
            matchEmptyCourse = try NSRegularExpression(pattern: "^[^A-Z]")
        } catch {
            NSLog("Failed to compile regexp for empty course: \(error)")
            matchEmptyCourse = nil
        }
    }
    
    /// For upper grades filters detail item by course list.
    /// - Parameter detailItems: Detail items for which acceptance is checked.
    /// - Returns: True when to be accepted.
    private func accept(basedOn detailItems: [String]) -> Bool {
        // When not in dashboard mode accept any item.
        if (forGrade == nil) {
            return true
        }

        // If not an upper grade do not check course list.
        if (Config.upperGrades.firstIndex(of: forGrade!) == nil) {
            return true
        }

        // If no course list set or list is empty accept any item.
        let courseList = AppDefaults.courseList
        if (courseList == nil || courseList!.count == 0) {
            return true
        }

        // This is the item from Vertretungsplan to check.
        var course = detailItems[2].replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        
        // "Sondereinsatz": In this case course property is empty.
        // Course is empty.
        if course.count == 0 {
            return true
        }

        // "Messe": Starts with "Mes", if seconds item is a course on users own course list
        // show it otherwise skip it.
        // If no seconds course is notated also skip it.
        let endOfText = course.index(course.startIndex, offsetBy: 3)
        if (course[..<endOfText] == "Mes") {
            if let secondCourse = CourseItem.course(from: course, first: false) {
                course = secondCourse
            } else {
                return true
            }
        }
        
        // Alternate definition of empty course?
        if let matcher = matchEmptyCourse {
            if matcher.firstMatch(in: course, range: NSMakeRange(0, course.count)) != nil {
                return true
            }
        }
        
        let found = courseList!.first(where: {
            CourseItem.normalizeCourseName($0) == course
        })

        return found != nil
    }

    /// Get username and password from settings and set up basic authentication
    /// header login string.
    /// - Parameters:
    ///   - username: User name
    ///   - password: Password
    /// - Returns: Base64 encoded credentials
    func getAndEncodeCredentials(username: String? = nil, password: String? = nil) -> String {
        var realUsername: String
        var realPassword: String
        if (username == nil && password == nil) {
            (realUsername, realPassword) = AppDefaults.credentials
        } else {
            realUsername = username!
            realPassword = password!
        }

        let loginString = String(format: "%@:%@", realUsername, realPassword)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        return loginData.base64EncodedString()
    }

    /// Returns URL request object depending on the connection status of the app.
    /// If online a web URL request is returned, when offline cache URL request
    /// object is returned instead.
    /// - Parameter piusGatewayIsReachable: Reachabilty status of app.
    /// - Returns: URLRequest depending on reqchability.
    private func getURLRequest(_ piusGatewayIsReachable: Bool) -> URLRequest {
        let base64LoginString = getAndEncodeCredentials()
        var request: URLRequest
        
        if (piusGatewayIsReachable) {
            // Define GET request with basic authentication.
            request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData)
            request.httpMethod = "GET"
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        } else {
            request = URLRequest(url: cache.getCacheFileUrl(for: cacheFileName)!)
        }
        
        return request
    }
    
    /// Function loads Vertretungsplan from cache. If there is no data
    /// in cache it returns nil.
    /// - Returns: Vertretungsplan from cache.
    func loadFromCache() throws -> Vertretungsplan {
        guard let data: Data = cache.read(filename: cacheFileName) else { return Vertretungsplan() }
        return try Vertretungsplan(data, accept: accept(basedOn:))
    }

    /// Loads Vertretungsplan from backend and converts data that has been received in JSON
    /// format into internal data structures. Finally calls update() method. This method is
    /// intented for updating the view from the model that has been built from JSON.
    /// In case of an error update() will be called with nil-data. Boolean value indicates
    /// is application currently is online or not.
    /// - Parameter update: Callback function which is called after Vertretungsplan has been loaded.
    func load(_ update: @escaping (Vertretungsplan?, Bool) -> Void) {
        let reachability = Reachability()
        let piusGatewayIsReachable: Bool! = reachability!.connection != .none
        let request = getURLRequest(piusGatewayIsReachable)

        // Create task to get data in background.
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
                var vertretungsplan: Vertretungsplan
                
                // Request error. In this case nothing more is to be done here. Inform user and exit.
                if let error = error {
                    NSLog("Vertretungsplan Loader had error: \(error)")
                    update(nil, piusGatewayIsReachable)
                    return
                }

                do {
                    // Cached data is not modified. This can be checked in online mode only.
                    // In offline mode _data will come from cache already if available.
                    let notModified = piusGatewayIsReachable == true && ((response as! HTTPURLResponse).statusCode == 304)
                    if (notModified) {
                        NSLog("Vertretungsplan has not changed. Using data from cache.")
                        vertretungsplan = try self.loadFromCache()
                        update(vertretungsplan, piusGatewayIsReachable)
                    } else if let data = data {
                        vertretungsplan = try Vertretungsplan(data, accept: self.accept(basedOn:))

                        if piusGatewayIsReachable {
                            self.cache.store(filename: self.cacheFileName, data: data)
                            self.cache.store(filename: self.digestFileName, data: vertretungsplan.digest.data(using: .utf8)!)
                        }
                        update(vertretungsplan, piusGatewayIsReachable)
                    } else {
                        update(nil, piusGatewayIsReachable)
                    }
                } catch let error as NSError {
                    NSLog(error.localizedDescription)
                    update(nil, piusGatewayIsReachable)
                }
        }


        // Now execute task and get data. This also updates all views.
        task.resume()
    }
    
    /// Validate that given credentials are these that are stored in user settings.
    /// If username and password are both nil values from user settings are validated
    /// instead.
    /// - Parameters:
    ///   - username: User name
    ///   - password: Password
    ///   - validationCallback: Callback, first parameter is true when validation succeeded. 2nd parameter is true when an error occured.
    func validateLogin(forUser username: String? = nil, withPassword password: String? = nil, notfifyMeOn validationCallback: @escaping (Bool, Bool) -> Void) {
        let base64LoginString = getAndEncodeCredentials(username: username, password: password)
        
        let url = URL(string: "\(AppDefaults.baseUrl)/validateLogin")!
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            let ok = (error == nil && (response as! HTTPURLResponse).statusCode == 200)
            validationCallback(ok, error != nil)
        }

        task.resume()
    }
}
