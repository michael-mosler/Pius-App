//
//  Vetretungsplan.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

let lessonStartTimes = ["07:55", "08:40", "09:45", "10:35", "11:25", "12:40", "13:25", "14:30", "15:15", "16:00", "16:45"]

typealias DetailItems = [String]

/// This struct implements an abstraction for the original DetailItems type. It
/// holds an instance of this type and provides getters for the different
/// properties. Instead of using subscripts the user now may access such
/// properties by means of named getters.
/// The class may also be used as array for compat. reasons.
struct DetailItem: Encodable {
    
    private var data: DetailItems
    
    init(_ details: DetailItems) {
        data = details
    }

    var course: String? { getItem(2) }
    var lesson: String? { getItem(0) }
    var type: String? { getItem(1) }
    var room: String? { getItem(3) }
    var teacher: String? { getItem(4) }
    var comment: String? { getItem(6) }
    var eva: String? { getItem(7) }
    
    var count: Int { data.count }

    subscript(index: Int) -> String {
        return getItem(index) ?? ""
    }
    
    /// Protected getter for subscript value. If array
    /// does not have requested index then nil is returned.
    /// - Parameter i: Subscript index
    /// - Returns: Value at index or nil when not defined.
    private func getItem(_ i: Int) -> String? {
        return i < data.count ? data[i] : nil
    }
    
}

/// A GradeItem holds all substitutions for a given grade.
struct GradeItem: Encodable {
    
    var grade: String!

    private var vertretungsplanItems_: [DetailItem] = []
    var vertretungsplanItems: [DetailItem] {
        set { vertretungsplanItems_ = newValue }
        get { vertretungsplanItems_ }
    }

    init(grade: String!) {
        self.grade = grade
    }
    
    /// Get details for given lesson.
    /// - Parameter lesson: Requested lesson
    /// - Returns: Details for given lesson
    func details(forLesson lesson: Int) -> [DetailItem] {
        let detailItems = vertretungsplanItems.filter({ details in
            let parts = details[0].split(separator: "-")
            
            // There is no lesson at all.
            if parts.count == 0 {
                return false
            }

            var lessonString = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: " "))
            let lesson1 = Int(lessonString) ?? -1

            // Invalid range.
            if lesson1 == -1 {
                return false
            }
            
            // First lesson matches what we are looking for.
            if parts.count == 1 {
                return lesson1 == lesson
            }

            // There is a range given but first lesson is greater than lesson we are checking for.
            if lesson1 > lesson {
                return false
            }

            lessonString = String(parts[1]).trimmingCharacters(in: CharacterSet(charactersIn: " "))
            let lesson2 = Int(lessonString) ?? -1

            return lesson1 <= lesson && lesson <= lesson2
        })
        
        return detailItems
    }
    
}

/// Substitution schedule for a given date. This struct holds schedules
/// for all grades for a date.
struct VertretungsplanForDate: Encodable {
    
    var date: String!
    var gradeItems: [GradeItem]!
    var expanded: Bool!

    init(date: String!, gradeItems: [GradeItem]!, expanded: Bool!) {
        self.date = date
        self.gradeItems = gradeItems
        self.expanded = expanded
    }
    
    /// Get item at index position. If index does not exist nil
    /// is returned.
    /// - Parameter index: Index position
    /// - Returns: Item at index or nil
    func item(forIndex index: Int) -> GradeItem? {
        return gradeItems.count > index ? gradeItems[index] : nil
    }
    
}

/// Full Vertretungsplan from cache or backend.
struct Vertretungsplan: Encodable {
    
    var tickerText: String?
    var additionalText: String?
    var lastUpdate: String!
    var vertretungsplaene: [VertretungsplanForDate]
    var digest: String
    
    /// Instantiate an empty Vertretunsgplan.
    init() {
        lastUpdate = ""
        digest = ""
        vertretungsplaene = []
    }
    
    /// Gets last update date as Date object.
    var lastUpdateDate: Date? {
        guard lastUpdate.count > 0 else { return nil }
        return DateHelper.format(lastUpdate.replacingOccurrences(of: " Uhr", with: ""), using: .standard)
    }

    /// Create Vertretungsplan from given data. Uses accept() function on detail
    /// in order to decide if an item is added or not.
    /// - Parameters:
    ///   - data: JSON encoded Vertretunsgplan either from cache or from backend.
    ///   - accept: Called on detail item. Must return true if an item is to be added.
    /// - Throws: Throws on JSON parsing error
    init(_ data: Data, accept: ((_ basedOn: [String]) -> Bool)?) throws {
        vertretungsplaene = []
        lastUpdate = ""
        digest = ""
        
        // Convert the data to JSON
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            
            if let digest_ = json["_digest"] as! String? {
                digest = digest_
            }

            if let ticketText_ = json["tickerText"], let lastUpdate_ = json["lastUpdate"] {
                tickerText = ticketText_ as? String
                lastUpdate = lastUpdate_ as? String
            }

            if let additionalText_ = json["_additionalText"] {
                additionalText = additionalText_ as? String
            }
 
            // Extract date items...
            if let dateItems = json["dateItems"] as? [Any] {
                // ... and iterate on all of them. This the top level of our Vertretungsplan.
                for dateItem_ in dateItems {
                    // Convert date item element to dictionary that is indexed by string.
                    let dictionary = dateItem_ as! [String: Any]
                    let date = dictionary["title"] as! String
                    
                    // Iterate on all grades for which a Vetretungsplan for the current date exists.
                    var gradeItems: [GradeItem] = []
                    for gradeItem_ in dictionary["gradeItems"] as! [Any] {
                        // Convert grade item into dictionary that is indexed by string.
                        let dictionary = gradeItem_ as! [String: Any]
                        var gradeItem = GradeItem(grade: dictionary["grade"] as? String)
                        
                        // Iterate on all details of a particular Vetretungsplan elements
                        // which gives information on all lessons affected.
                        for vertretungsplanItem_ in dictionary["vertretungsplanItems"] as! [Any] {
                            // Convert vertretungsplan item into a dictionary indexed by string.
                            // This is the bottom level of our data structure. Each element is
                            // one of lesson, course, room, teacher (new and old) and an optional
                            // remark.
                            var detailItems: DetailItems = []
                            let dictionary = vertretungsplanItem_ as! [String: Any]
                            for detailItem in dictionary["detailItems"] as! [String] {
                                detailItems.append(detailItem)
                            }
                            
                            if accept?(detailItems) ?? true {
                                gradeItem.vertretungsplanItems.append(DetailItem(detailItems))
                            }
                        }
                        
                        // Done for the current grade.
                        if (gradeItem.vertretungsplanItems.count > 0) {
                            gradeItems.append(gradeItem)
                        }
                    }
                    
                    // Done for the current date.
                    vertretungsplaene.append(VertretungsplanForDate(date: date, gradeItems: gradeItems, expanded: false))
                }
            }
        }
    }

    /// Check if additional text exists.
    /// - Returns: True when Vertretungsplan has additional text.
    func hasAdditionalText() -> Bool {
        return additionalText != nil && additionalText!.count > 0
    }
    
    /// Filter Vertretungsplan for given date.
    /// - Parameter date: Filter date
    /// - Returns: Vertretungsplan for given date.
    func filter(onDate date: Date?) -> VertretungsplanForDate? {
        guard let date = date else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "de_DE")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, dd.MM.yyyy")
        let filterDate = dateFormatter.string(from: date)
        let vertretungsplanForDate = vertretungsplaene.filter { $0.date == filterDate }
        return vertretungsplanForDate.count == 0 ? nil : vertretungsplanForDate[0]
    }

    /// Holds a filtered Vertretungsplan that holds information on the next item only.
    /// It expects that this is a Vertretungsplan instance which is filtered by grade
    /// and a given course list.
    var next: [VertretungsplanForDate] {
        get {
            do {
                // Match date.
                let matchDate = try NSRegularExpression(pattern: "\\d{2}.\\d{2}.\\d{4}")

                // Match first number in a string.
                let matchFirstNumber = try NSRegularExpression(pattern: "\\d+")

                // Date formatter.
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "de_DE")
                dateFormatter.dateFormat = "dd.MM.yyyy'-'HH:mm"

                // Scan all dates.
                for vertretungsplanForDate in vertretungsplaene {
                    if let dateMatch = matchDate.firstMatch(in: vertretungsplanForDate.date, range: NSMakeRange(0, vertretungsplanForDate.date.count)) {
                        let range = Range(dateMatch.range, in: vertretungsplanForDate.date)
                        let date = String(vertretungsplanForDate.date[range!]) + "-"
                        
                        // This function is for dashboard mode only. Thus, there will be one or none grade
                        // item.
                        if vertretungsplanForDate.gradeItems.count > 0 {
                            let gradeItem = vertretungsplanForDate.gradeItems[0]

                            // Scan all items for the current date.
                            for vertretungsplanItem in gradeItem.vertretungsplanItems {
                                // Which lessons are affected? This may be a single figure or a range like "3-4. Stunde". Anyway
                                // we are interested in the very first figure only as this defines the time.
                                let lessonRange = vertretungsplanItem[0]
                                if let startLessonMatch = matchFirstNumber.firstMatch(in: lessonRange, range: NSMakeRange(0, lessonRange.count)), let range = Range(startLessonMatch.range, in: lessonRange) {
                                    // When something matched convert lesson number to time string, append it to date and convert
                                    // this string to NSDate. Then check if date is greater than current date and time.
                                    let startLesson = (String(lessonRange[range]) as NSString).integerValue
                                    let lessonStartTime = lessonStartTimes[startLesson - 1]
                                    
                                    if let lessonStartDateAndTime = dateFormatter.date(from: date + lessonStartTime), lessonStartDateAndTime > Date() {
                                        // Build a reduced vertretungsplan that only has the "next" item
                                        var filteredGradeItem = gradeItem
                                        filteredGradeItem.vertretungsplanItems = [vertretungsplanItem]
                                        
                                        var filteredVertretungsplanForDate = vertretungsplanForDate
                                        filteredVertretungsplanForDate.gradeItems = [filteredGradeItem]
                                        return [filteredVertretungsplanForDate]
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Nothing found, no next item. Sorry!
                return []
            } catch {
                NSLog("Failed to return widget data \(error)")
                return []
            }
        }
    }
    
}
