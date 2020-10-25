//
//  ScheduleData.swift
//
//  Created by Michael Mosler-Krings on 27.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import Foundation
import UIKit

let lessons: [String] = ["07:55", "08:40", "09:25", "09:45", "10:35", "11:25", "12:10", "12:40", "13:25", "14:10", "14:30", "15:15", "16:00", "16:45"]
let lessonsWithAllEndTimes: [String] = lessons + ["17:30"]

let courseTypes: [String] = ["―"] + Config.courseTypes + ["Fö"]
let courseNumbers: [String] = ["―"] + Config.courseNumbers

/* ****************************************************************
 * A single course which is defined by its subject the course
 * type, room and teacher.
 * ****************************************************************/
class CourseItem: NSObject, NSCoding, NSCopying {
    private var _courseName: String?
    var course: String
    var courseType: Int = 0
    var courseNumber: Int = 0
    var teacher: String
    var exam: Bool = false

    var courseName: String {
        set(value) {
            _courseName = value
        }
        get {
            guard _courseName == nil else { return _courseName! }
            if course.count > 0 {
                let courseTypeName = (courseType != 0) ? " \(courseTypes[courseType])" : ""
                let courseNumberName = (courseNumber != 0) ? courseNumbers[courseNumber] : ""
                return "\(course)\(courseTypeName)\(courseNumberName)"
            } else {
                return "..."
            }
        }
    }

    var color: UIColor? {
        get {
            if AppDefaults.hasUpperGrade {
                if courseType == 2 {
                    return UIColor(named: "lk")
                }
                
                switch course {
                case "M": return UIColor(named: "mint")
                case "IF": return UIColor(named: "mint")
                case "PH": return UIColor(named: "mint")
                case "CH": return UIColor(named: "mint")
                case "BI": return UIColor(named: "mint")

                case "D": return UIColor(named: "sprachen")
                case "E": return UIColor(named: "sprachen")
                case "F": return UIColor(named: "sprachen")
                case "L": return UIColor(named: "sprachen")
                case "S": return UIColor(named: "sprachen")
                case "H": return UIColor(named: "sprachen")

                case "EK": return UIColor(named: "gesellschaft")
                case "GE": return UIColor(named: "gesellschaft")
                case "KR": return UIColor(named: "gesellschaft")
                case "PL": return UIColor(named: "gesellschaft")
                case "LI": return UIColor(named: "gesellschaft")
                case "SW": return UIColor(named: "gesellschaft")
                case "PK": return UIColor(named: "gesellschaft")
                    
                case "MU": return UIColor(named: "kuenstlerisch")
                case "KU": return UIColor(named: "kuenstlerisch")
                    
                case "SP": return UIColor(named: "sport")
                    
                default: return nil
                }
            }
            else {
                switch course {
                case "M": return UIColor(named: "hauptfach")
                case "D": return UIColor(named: "hauptfach")
                case "E": return UIColor(named: "hauptfach")
                case "F": return UIColor(named: "hauptfach")
                case "S": return UIColor(named: "hauptfach")
                case "L": return UIColor(named: "hauptfach")
                    
                case "PH": return UIColor(named: "mint")
                case "CH": return UIColor(named: "mint")
                case "BI": return UIColor(named: "mint")

                case "EK": return UIColor(named: "gesellschaft")
                case "GE": return UIColor(named: "gesellschaft")
                case "KR": return UIColor(named: "gesellschaft")
                case "PL": return UIColor(named: "gesellschaft")
                case "LI": return UIColor(named: "gesellschaft")
                case "SW": return UIColor(named: "gesellschaft")
                case "PK": return UIColor(named: "gesellschaft")

                case "MU": return UIColor(named: "kuenstlerisch")
                case "KU": return UIColor(named: "kuenstlerisch")

                case "SP": return UIColor(named: "sport")

                default: return nil
                }
            }
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(course, forKey: "course")
        aCoder.encode(courseType, forKey: "courseType")
        aCoder.encode(courseNumber, forKey: "courseNumber")
        aCoder.encode(teacher, forKey: "teacher")
        aCoder.encode(exam, forKey: "exam")
    }
    
    required init?(coder aDecoder: NSCoder) {
        course = aDecoder.decodeObject(forKey: "course") as? String ?? ""
        courseType = aDecoder.decodeInteger(forKey: "courseType")
        courseNumber = aDecoder.decodeInteger(forKey: "courseNumber")
        teacher = aDecoder.decodeObject(forKey: "teacher") as? String ?? ""
        exam = aDecoder.decodeBool(forKey: "exam")
        super.init()
    }
    
    init(course: String, teacher: String = "", courseType: Int = 0, courseNumber: Int = 0, exam: Bool = false) {
        self.course = course
        self.teacher = teacher
        self.courseType = courseType
        self.courseNumber = courseNumber
        self.exam = exam
        super.init()
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CourseItem(course: course, teacher: teacher, courseType: courseType, courseNumber: courseNumber, exam: exam)
        return copy
    }
    
    // Gets first or second course item for a pattern like "a&rarr;b". In this case 2nd item is
    // b. If a/b is not a course name or does not exist at all nil is returned.
    // If courseSpec does not contain and first is true courseSpec is returned.
    // If first is false then nil is returned.
    static func course(from courseSpec: String, first: Bool = true) -> String? {
        if let range = courseSpec.range(of: "&rarr;") {
            var item: String
            let characters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVXYZ")
            
            if first {
                let startIndex = courseSpec.startIndex
                let endIndex = range.lowerBound
                item = String(courseSpec[startIndex..<endIndex])
            } else {
                let startIndex = range.upperBound
                item = String(courseSpec[startIndex...])
            }
            
            return item.rangeOfCharacter(from: characters) != nil ? item : nil
        }

        return first ? courseSpec : nil
    }

    static func ==(courseItem: CourseItem, courseSpec: String) -> Bool {
        if var courseName = CourseItem.course(from: courseSpec) {
            courseName = CourseItem.normalizeCourseName(courseName)
            return CourseItem.normalizeCourseName(courseItem.courseName) == courseName
        } else {
            return false
        }
    }

    static func normalizeCourseName(_ courseName: String) -> String {
        return courseName
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "GK", with: "G", options: .literal, range: nil)
            .replacingOccurrences(of: "ZK", with: "Z", options: .literal, range: nil)
            .replacingOccurrences(of: "LK", with: "L", options: .literal, range: nil);
    }
}

/* ****************************************************************
 * The list of all courses. This list stored in AppDefaults as it
 * will be needed by substitution schedule for upper grades.
 * ****************************************************************/
typealias Courses = [CourseItem]

/* ****************************************************************
 * The base class of schedule items.
 * ****************************************************************/
class ScheduleItem: NSObject, NSCoding, NSCopying {
    var room: String
    var isSubstitution: Bool = false
    var substitutionDetails: DetailItems?
    
    fileprivate var _courseItem: CourseItem
    
    var courseItem: CourseItem {
        get {
            return _courseItem
        }
    }

    var course: String {
        set(value) {
            _courseItem.course = value
        }
        get {
            return _courseItem.course
        }
    }
    var courseType: Int {
        set(value) {
            _courseItem.courseType = value
        }
        get {
            return _courseItem.courseType
        }
    }
    var courseNumber: Int {
        set(value) {
            _courseItem.courseNumber = value
        }
        get {
            return _courseItem.courseNumber
        }
    }
    var teacher: String {
        set(value) {
            _courseItem.teacher = value
        }
        get {
            return _courseItem.teacher
        }
    }
    
    var courseName: String {
        get {
            return _courseItem.courseName
        }
    }

    var isCustomized: Bool {
        get {
            return true
        }
    }

    var canBeReplaced: Bool {
        get {
            return true
        }
    }
    
    var canBeDeleted: Bool {
        get {
            return true
        }
    }

    var color: UIColor? {
        get {
            return _courseItem.color
        }
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(room, forKey: "room")
        aCoder.encode(_courseItem, forKey: "courseItem")
    }
    
    required init?(coder aDecoder: NSCoder) {
        room = aDecoder.decodeObject(forKey: "room") as? String ?? ""
        _courseItem = aDecoder.decodeObject(forKey: "courseItem") as? CourseItem ?? CourseItem(course: "")
        super.init()
    }
    
    init(room: String = "", courseItem: CourseItem) {
        self.room = room
        self._courseItem = courseItem
    }

    /**
      * Copy constructor: This returns a shallow copy of self.
     */
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = ScheduleItem(room: room, courseItem: _courseItem)
        return copy
    }
    
    /**
     * Given a details item of a substitution schedule record the current ScheduleItem
     * is updated if details match.
     * Matching rules:
     *     + if details refer to a Klausur record then there is a match if the course given in details
     *       is on the list of courses at all and if this course is marked as "Schriftlich" (exam)
     *     + otherwise: if courses match then details must not refer to a Klausur record
     *     + otherwise: There is no course given in details, i.e. it is something like a wildcard record
     */
    func update(withDetails details: [DetailItems]) -> ScheduleItem {
        guard details.count > 0 else { return self }
        
        // Course name match?
        var bestDetails = details.filter({ detail in
            // First check if this is "Klausur" in detail[1]. If so, check
            // if course in detail[2] is on the list of courses. If so, this
            // is best match.
            if detail[1].contains("Klausur") {
                if let _ = AppDefaults.courses.firstIndex(where: { course in course.exam && CourseItem.normalizeCourseName(course.courseName) == CourseItem.normalizeCourseName(detail[2]) }) {
                    return true
                }
            }
            
            if _courseItem == detail[2] {
                return !detail[1].contains("Klausur")
            }
            
            return false
        })
        
        // If not, any item without course?
        if bestDetails.count == 0 {
            bestDetails = details.filter({ detail in
                return StringHelper.replaceHtmlEntities(input: detail[2])?.count == 0
            })
        }
        
        // Any item left, if not return self.
        guard bestDetails.count > 0 else { return self }

        // We need to copy existing item as otherwise timetable would get overwritten.
        // Then set course from substitution.
        let newCourseItem = _courseItem.copy() as! CourseItem
        let newScheduleItem = copy() as! ScheduleItem
        newScheduleItem.isSubstitution = true
        newScheduleItem.substitutionDetails = bestDetails[0]
        newScheduleItem._courseItem = newCourseItem
        newScheduleItem._courseItem.courseName = bestDetails[0][1]
        newScheduleItem.room = bestDetails[0][3]
        
        /* Breaks layout because it does not fit into timetable view.
         */
        // if details[0][4] != newScheduleItem.teacher && newScheduleItem.teacher.count > 0 {
        //     newCourseItem.teacher += " → " + details[0][4]
        // } else {
        //     newScheduleItem.teacher = details[0][4]
        // }
        newScheduleItem.teacher = bestDetails[0][4]
        return newScheduleItem
    }
}

/* ****************************************************************
 * This indicates a free lesson. An initial schedule is filled with
 * items of this type all of which can be replaced.
 * ****************************************************************/
class FreeScheduleItem: ScheduleItem {
    override var canBeDeleted: Bool {
        return false
    }

    init() {
        super.init(courseItem: CourseItem(course: "Frei"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/* ****************************************************************
 * A break. This item cannot be replaced.
 * ****************************************************************/
class BreakScheduleItem: ScheduleItem {
    override var canBeReplaced: Bool {
        get {
            return false
        }
    }

    override var canBeDeleted: Bool {
        return false
    }

    override var color: UIColor? {
        get {
            if #available(iOS 13, *) {
                return UIColor.systemGroupedBackground
            } else {
                return UIColor.groupTableViewBackground
            }
        }
    }
        
    init() {
        super.init(courseItem: CourseItem(course: "Pause"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

/* ****************************************************************
 * Standard item with a predefined subject and editable course
 * teacher and room.
 * ****************************************************************/
class CustomScheduleItem: ScheduleItem {
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = CustomScheduleItem(room: room, courseItem: _courseItem)
        return copy
    }
}

/* ****************************************************************
 * This item allows full custimization, i.e. also subject
 * can be edited.
 * ****************************************************************/
class ExtraScheduleItem: ScheduleItem {
    override var isCustomized: Bool {
        get {
            return course.count > 0
        }
    }

    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = ExtraScheduleItem(room: room, courseItem: _courseItem)
        return copy
    }
}

/* ****************************************************************
 * Timetable for a single day.
 * ****************************************************************/
class ScheduleForDay: NSObject, NSCoding {
    private var scheduleEntries: [ScheduleItem]

    var numberOfItems: Int {
        get {
            return scheduleEntries.count
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(scheduleEntries, forKey: "scheduleEntries")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let scheduleEntries = aDecoder.decodeObject(forKey: "scheduleEntries") as? [ScheduleItem] else {
            self.init()
            return
        }
        self.init(scheduleEntries)
    }
    
    init(_ scheduleEntries: [ScheduleItem]) {
        self.scheduleEntries = scheduleEntries
    }

    override init() {
        let freeScheduleItem = FreeScheduleItem()
        let breakScheduleItem = BreakScheduleItem()
        scheduleEntries = [
            freeScheduleItem,
            freeScheduleItem,
            breakScheduleItem,
            freeScheduleItem,
            freeScheduleItem,
            freeScheduleItem,
            breakScheduleItem,
            freeScheduleItem,
            freeScheduleItem,
            breakScheduleItem,
            freeScheduleItem,
            freeScheduleItem,
            freeScheduleItem,
            freeScheduleItem
        ]
        super.init()
    }
    
    func item(forLesson index: Int) -> ScheduleItem {
        guard index < scheduleEntries.count else { return ScheduleItem(courseItem: CourseItem(course: ""))}
        return scheduleEntries[index]
    }
    
    func item(forLesson index: Int, _ value: ScheduleItem) {
        scheduleEntries[index] = value
    }
    
    /// Returns effective lesson based on index value. Breaks do not count up.
    /// - Parameter value: An index value
    static func effectiveLessonFromIndex(_ value: Int?) -> Int? {
        guard let lesson = value else { return nil }
        
        switch lesson {
        case 0..<2:
            return lesson + 1
        case 2:
            return nil
        case 3..<6:
            return lesson
        case 6:
            return nil
        case 7..<9:
            return lesson - 1
        case 9:
            return nil
        default:
            return lesson - 2
        }
    }
}

/* ****************************************************************
 * Timetable for one week is a list of timetables for a single day.
 * ****************************************************************/
typealias ScheduleForDays = [ScheduleForDay]

/* ****************************************************************
 * Class Timetable
 * ****************************************************************/
class Timetable: NSObject, NSCoding {
    private var courseItemDictionary: [String: [String : CustomScheduleItem]]
    private var scheduleForWeeks: [ScheduleForDays]
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(scheduleForWeeks, forKey: "scheduleForWeeks")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let scheduleForWeeks = aDecoder.decodeObject(forKey: "scheduleForWeeks") as? [ScheduleForDays] else {
            self.init()
            return
        }
        self.init(scheduleForWeeks)
    }
    
    init(_ scheduleForWeeks: [ScheduleForDays]) {
        courseItemDictionary = [ : ]
        self.scheduleForWeeks = scheduleForWeeks
        super.init()

        // Rebuild the course item dictionary.
        forEachItem { (i, scheduleForDay, item) in
            guard let existingItem = item as? CustomScheduleItem else { return }
            if courseItemDictionary[existingItem.course] == nil {
                courseItemDictionary[existingItem.course] = [ : ]
            }
            courseItemDictionary[existingItem.course]![existingItem.courseName] = existingItem
        }
    }

    override init() {
        courseItemDictionary = [ : ]
        let scheduleForDaysAWeek: ScheduleForDays = [
            ScheduleForDay(),   // Monday
            ScheduleForDay(),   // Tuesday
            ScheduleForDay(),   // Wednesday
            ScheduleForDay(),   // Thursday
            ScheduleForDay()    // Friday
        ]
        let scheduleForDaysBWeek: ScheduleForDays = [
            ScheduleForDay(),   // Monday
            ScheduleForDay(),   // Tuesday
            ScheduleForDay(),   // Wednesday
            ScheduleForDay(),   // Thursday
            ScheduleForDay()    // Friday
        ]
        scheduleForWeeks = [scheduleForDaysAWeek, scheduleForDaysBWeek]
        super.init()
    }
    
    /**
     * Apply function f to each schedule item.
     */
    func forEachItem(_ f: (Int, ScheduleForDay, ScheduleItem) -> Void) {
        scheduleForWeeks.forEach({ scheduleForDays in
            scheduleForDays.forEach({ scheduleForDay in
                for i in 0..<scheduleForDay.numberOfItems {
                    let item = scheduleForDay.item(forLesson: i)
                    f(i, scheduleForDay, item)
                }
            })
        })
    }

    /**
     * Save timetable in app options. Calling this function also updates course list
     * which also forwards course list to backend for use by pusher.
     */
    private func save() {
        var courses = Courses()
        var courseNameDictionary: [String : CourseItem] = [ : ]
        
        forEachItem({ (i, scheduleForDay, scheduleItem) in
            if scheduleItem as? CustomScheduleItem != nil || scheduleItem as? ExtraScheduleItem != nil {
                courseNameDictionary[scheduleItem.courseName] = scheduleItem.courseItem
            }
        })
        
        courses = courseNameDictionary.map({ (_, courseItem) -> CourseItem in
            return courseItem
        })

        AppDefaults.timetable = self
        AppDefaults.courses = courses
        if Config.isUpperGrade(AppDefaults.gradeSetting) {
            AppDefaults.courseList = courses.map({ course in course.courseName })
        } else {
            AppDefaults.courseList = []
        }
    }

    /**
     * Swaps A and B week: A -> B, B -> A.
     */
    private func swapWeek(_ week: Week) -> Week {
        return (week == .A) ? .B : .A
    }
    
    func schedule(forWeek week: Week = Week.A, forDay index: Int) -> ScheduleForDay {
        guard index < 5 else { return ScheduleForDay() }
        return scheduleForWeeks[week.rawValue][index]
    }
    
    func schedule(forWeek week: Week = .A, forDay index: Int, _ scheduleForDay: ScheduleForDay) {
        guard index < 5 else { return }
        scheduleForWeeks[week.rawValue][index] = scheduleForDay
    }

    func schedule(forSubject subject: String) -> [ScheduleItem] {
        if let cachedTopLevelItem = courseItemDictionary[subject] {
            let scheduleItems: [ScheduleItem] = cachedTopLevelItem.map({(key: String, scheduleItem: CustomScheduleItem) -> ScheduleItem in
                return scheduleItem
            })
            return scheduleItems
        } else {
            return []
        }
    }

    func schedule(forSubject subject: String, forCourse course: String) -> ScheduleItem {
        if let cachedTopLevelItem = courseItemDictionary[subject] {
            if let scheduleItem: ScheduleItem = cachedTopLevelItem[course] {
                return scheduleItem
            } else {
                return FreeScheduleItem()
            }
        } else {
            return FreeScheduleItem()
        }
    }

    func update(_ week: Week, day: Int, lesson: Int, withScheduleItem item: ScheduleItem) {
        scheduleForWeeks[week.rawValue][day].item(forLesson: lesson, item.copy() as! ScheduleItem)
        
        // Custom Schedule Item is copied into B week when entry is free.
        let bWeekItem = scheduleForWeeks[swapWeek(week).rawValue][day].item(forLesson: lesson)        
        if item as? CustomScheduleItem != nil && bWeekItem as? FreeScheduleItem != nil {
            scheduleForWeeks[swapWeek(week).rawValue][day].item(forLesson: lesson, item.copy() as! ScheduleItem)
        }
        
        save()
    }
    
    func delete(forWeek week: Week, forDay day: Int, forLesson lesson: Int) {
        scheduleForWeeks[week.rawValue][day].item(forLesson: lesson, FreeScheduleItem())
        save()
    }
    
    func delete(forDay day: Int) {
        scheduleForWeeks[Week.A.rawValue][day] = ScheduleForDay()
        scheduleForWeeks[Week.B.rawValue][day] = ScheduleForDay()
        save()
    }
    
    func delete() {
        [Week.A, Week.B].forEach({ week in
            scheduleForWeeks[week.rawValue] = [
                ScheduleForDay(),   // Monday
                ScheduleForDay(),   // Tuesday
                ScheduleForDay(),   // Wednesday
                ScheduleForDay(),   // Thursday
                ScheduleForDay()    // Friday
            ]
        })
        save()
    }

    /**
     * Update details of a schedule item. The function scans all and sets details
     * to those given in itemUpdated. This is a two step process. For the original
     * item given as oldItem this update is unconditional All other item details
     * get updated if course matches.
     */
    func details(itemUpdated item: ScheduleItem, oldItem: ScheduleItem) {
        var newItem = item
        if let item = newItem as? CustomScheduleItem {
            if let cachedTopLevelItem = courseItemDictionary[item.course], let cachedItem = cachedTopLevelItem[item.courseName] {
                cachedItem.room = item.room
                cachedItem.courseItem.teacher = item.teacher
                cachedItem.courseItem.exam = item.courseItem.exam
                newItem = cachedItem
            } else {
                if courseItemDictionary[item.course] != nil {
                    courseItemDictionary[item.course]![item.courseName] = item
                } else {
                    courseItemDictionary[item.course] = [item.courseName : item]
                }
            }
        }

        forEachItem { (i, scheduleForDay, existingItem) in
            if existingItem == oldItem {
                scheduleForDay.item(forLesson: i, newItem.copy() as! ScheduleItem)
                return
            }

            if     /* Same Course                 */ (existingItem.course == newItem.course || existingItem.course.count == 0)
                && /* Same course type or unset   */ (existingItem.courseType == newItem.courseType || existingItem.courseType == 0)
                && /* Same course number or unser */ (existingItem.courseNumber == newItem.courseNumber || existingItem.courseNumber == 0)
                && /* Room unset                  */ (existingItem.room == "") {
                scheduleForDay.item(forLesson: i, newItem.copy() as! ScheduleItem)
                return
            }
        }
        save()
    }
}
