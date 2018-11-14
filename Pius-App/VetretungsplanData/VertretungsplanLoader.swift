//
//  VertretungsplanLoader.swift
//  Pius-App
//
//  Created by Michael on 26.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

class VertretungsplanLoader {
    private var matchEmptyCourse: NSRegularExpression?;
    private var forGrade: String?;
    private var url: URL?;
    private let baseUrl = "\(AppDefaults.baseUrl)/vertretungsplan";
    private let cache = Cache();
    private var cacheFileName: String;
    private var digestFileName: String;
    private var digest: String?;
    
    init(forGrade: String? = nil) {
        var digest: String? = nil;
        let cacheFileName: String = (forGrade != nil) ? String(format: "%@.html", forGrade!) : "vertretungsplan.html";
        let digestFileName: String = (forGrade != nil) ? String(format: "%@.md5", forGrade!) : "md5";

        // If cache file exists we may use digest to detect changes in Vertretungsplan. Without cache file
        // we need to request data.
        if (self.cache.fileExists(filename: cacheFileName)) {
            digest = cache.read(filename: digestFileName);
        } else {
            print("Cache file \(cacheFileName) does not exist. Not sending digest.");
        }

        self.forGrade = forGrade;
        self.digest = digest;
        
        var urlString = baseUrl;
        if (forGrade != nil || digest != nil) {
            var separator = "/?";
            if (forGrade != nil) {
                urlString.append(String(format: "%@forGrade=%@", separator, forGrade!));
                separator = "&";
            }
            
            if (digest != nil) {
                urlString.append(String(format: "%@digest=%@", separator, digest!));
            }
        }
        
        self.url = URL(string: urlString);
        self.cacheFileName = cacheFileName;
        self.digestFileName = digestFileName;

        // This expression matches a missing course that is indicated by dashes or blanks.
        do {
            matchEmptyCourse = try NSRegularExpression(pattern: "^[^A-Z]");
        } catch {
            print("Failed to compile regexp for empty course: \(error)");
            matchEmptyCourse = nil;
        }
    }
    
    // Gets 2nd course item for a pattern like "a&rarr;b". In this case 2nd item is
    // b. If b is not a course name or does not exist at all nil is returned.
    private static func get2ndCourseFromItem(item: String) -> String? {
        if let range = item.range(of: "&rarr;") {
            let characters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVXYZ");
            
            let startIndex = range.upperBound;
            let secondItem = String(item[startIndex...]);
            
            if item.rangeOfCharacter(from: characters) != nil {
                return secondItem;
            }
            
            return nil;
        }
        
        return nil;
    }

    // For upper grades filters detail item against course list.
    private func accept(basedOn detailItems: [String]) -> Bool {
        // When not in dashboard mode accept any item.
        if (forGrade == nil) {
            return true;
        }

        // If not an upper grade do not check course list.
        if (Config.upperGrades.index(of: forGrade!) == nil) {
            return true;
        }

        // If no course list set or list is empty accept any item.
        let courseList = AppDefaults.courseList;
        if (courseList == nil || courseList!.count == 0) {
            return true;
        }

        // This is the item from Vertretungsplan to check.
        var course = detailItems[2].replacingOccurrences(of: " ", with: "", options: .literal, range: nil);
        
        // "Sondereinsatz": In this case course property is empty.
        // Course is empty.
        if course.count == 0 {
            return true;
        }

        // "Messe": Starts with "Mes", if seconds item is a course on users own course list
        // show it otherwise skip it.
        // If no seconds course is notated also skip it.
        let endOfText = course.index(course.startIndex, offsetBy: 3);
        if (course[..<endOfText] == "Mes") {
            if let secondCourse = VertretungsplanLoader.get2ndCourseFromItem(item: course) {
                course = secondCourse;
            } else {
                return true;
            }
        }
        
        // Alternate definition of empty course?
        if let matcher = matchEmptyCourse {
            if matcher.firstMatch(in: course, range: NSMakeRange(0, course.count)) != nil {
                return true;
            }
        }
        
        let found = courseList!.first(where: {
            $0
            .replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
            .replacingOccurrences(of: "GK", with: "G", options: .literal, range: nil)
            .replacingOccurrences(of: "LK", with: "L", options: .literal, range: nil) == course
        });

        return found != nil;
    }

    // Get username and password from settings and set up basic authentication
    // header login string.
    func getAndEncodeCredentials(username: String? = nil, password: String? = nil) -> String {
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
            // Define GET request with basic authentication.
            request = URLRequest(url: url!);
            request.httpMethod = "GET";
            request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization");
        } else {
            request = URLRequest(url: cache.getCacheFileUrl(for: cacheFileName)!);
        }
        
        return request;
    }
    
    // Loads Vertretungsplan from backend and converts data that has been received in JSON
    // format into internal data structures. Finally calls update() method. This method is
    // intented for updating the view from the model that has been built from JSON.
    // In case of an error update() will be called with nil-data. Boolean value indicates
    // is application currently is online or not.
    func load(_ update: @escaping (Vertretungsplan?, Bool) -> Void) {
        let reachability = Reachability();
        let piusGatewayIsReachable: Bool! = reachability!.connection != .none;
        let request = getURLRequest(piusGatewayIsReachable);

        // Create task to get data in background.
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            var _data: Data? = data;
            
            // Request error. In this case nothing more is to be done here. Inform user and exit.
            if let error = error {
                print("Vertretungsplan Loader had error: \(error)");
                update(nil, piusGatewayIsReachable);
                return;
            }

            // Cached data is not modified. This can be checked in online mode only.
            // In offline mode _data will come from cache already if available.
            let notModified = piusGatewayIsReachable == true && ((response as! HTTPURLResponse).statusCode == 304);
            if (notModified) {
                _data = self.cache.read(filename: self.cacheFileName);
                print("Vertretungsplan has not changed. Using data from cache.");
            }
            
            if let data = _data {
                var vertretungsplan: Vertretungsplan = Vertretungsplan();
                
                do {
                    // Convert the data to JSON
                    let jsonSerialized = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any];

                    // If in online mode store current Vertretungsplan in cache. Here we are sure that data is valid
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
                    
                    // Extract ticker text and date of last update. Then dispatch update of label text.
                    if let json = jsonSerialized, let _tickerText = json["tickerText"], let _lastUpdate = json["lastUpdate"] {
                        vertretungsplan.tickerText = _tickerText as? String;
                        vertretungsplan.lastUpdate = _lastUpdate as? String;
                    }
                    
                    if let json = jsonSerialized, let _additionalText = json["_additionalText"] {
                        vertretungsplan.additionalText = _additionalText as? String;
                    }
                    
                    // Extract date items...
                    if let json = jsonSerialized, let dateItems = json["dateItems"] as? [Any] {
                        // ... and iterate on all of them. This the top level of our Vertretungsplan.
                        for _dateItem in dateItems {
                            // Convert date item element to dictionary that is indexed by string.
                            let dictionary = _dateItem as! [String: Any];
                            let date = dictionary["title"] as! String;
                            
                            // Iterate on all grades for which a Vetretungsplan for the current date exists.
                            var gradeItems: [GradeItem] = [];
                            for _gradeItem in dictionary["gradeItems"] as! [Any] {
                                // Convert grade item into dictionary that is indexed by string.
                                let dictionary = _gradeItem as! [String: Any];
                                var gradeItem = GradeItem(grade: dictionary["grade"] as? String);
                                
                                // Iterate on all details of a particular Vetretungsplan elements
                                // which gives information on all lessons affected.
                                for _vertretungsplanItem in dictionary["vertretungsplanItems"] as! [Any] {
                                    // Convert vertretungsplan item into a dictionary indexed by string.
                                    // This is the bottom level of our data structure. Each element is
                                    // one of lesson, course, room, teacher (new and old) and an optional
                                    // remark.
                                    var detailItems: DetailItems = [];
                                    let dictionary = _vertretungsplanItem as! [String: Any];
                                    for detailItem in dictionary["detailItems"] as! [String] {
                                        detailItems.append(detailItem);
                                    }
                                    
                                    if (self.accept(basedOn: detailItems)) {
                                        gradeItem.vertretungsplanItems.append(detailItems);
                                    }
                                }
                                
                                // Done for the current grade.
                                if (gradeItem.vertretungsplanItems.count > 0) {
                                    gradeItems.append(gradeItem);
                                }
                            }
                            
                            // Done for the current date.
                            vertretungsplan.vertretungsplaene.append(VertretungsplanForDate(date: date, gradeItems: gradeItems, expanded: false));
                        }
                    }
                    
                    update(vertretungsplan, piusGatewayIsReachable);
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
    
    // Validate that given credentials are these that are stored in user settings.
    // If username and password are both nil values from user settings are validated
    // instead.
    func validateLogin(forUser username: String? = nil, withPassword password: String? = nil, notfifyMeOn validationCallback: @escaping (Bool, Bool) -> Void) {
        let base64LoginString = getAndEncodeCredentials(username: username, password: password);
        
        let url = URL(string: baseUrl)!;
        var request = URLRequest(url: url);
        request.httpMethod = "HEAD";
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            let ok = (error == nil && (response as! HTTPURLResponse).statusCode == 200);
            validationCallback(ok, error != nil);
        }

        task.resume();
    }
}
