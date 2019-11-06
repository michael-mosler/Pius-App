//
//  CourseItem.swift
//
//  Created by Michael Mosler-Krings on 28.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import Foundation

/* ****************************************************************
 * A single subject prototype. A subject is defined by it's short
 * and it's long name, e.g. (M/Mathematik)
 * ****************************************************************/
class CourseItemPrototype {
    var name: String
    var longName: String
    
    init(name: String, longName: String = "") {
        self.name = name
        self.longName = longName
    }
}

/* ****************************************************************
 * A list of all subjects to show in drag item collection view
 * area. Aka, this makes up the list of items the user my drag
 * from.
 * ****************************************************************/
class CourseItemCollection {
    var courseItems: [CourseItemPrototype]
    
    var numberOfItems: Int {
        get {
            return courseItems.count
        }
    }
    
    init() {
        courseItems = (Config.coursesShortNames + ["PK", "Mes", "..."]).map({ shortName -> CourseItemPrototype in
            let courseItemPrototype = CourseItemPrototype(name: shortName, longName: shortName)
            return courseItemPrototype
        })
    }
    
    func courseItem(forIndex index: Int) -> CourseItemPrototype {
        guard index < courseItems.count else { return CourseItemPrototype(name: "")}
        return courseItems[index]
    }
}
