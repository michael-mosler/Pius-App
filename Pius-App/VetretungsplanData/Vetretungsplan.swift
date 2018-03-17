//
//  Vetretungsplan.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

typealias DetailItems = [String];

struct GradeItem {
    var grade: String!
    var vertretungsplanItems: [DetailItems]!
    
    init(grade: String!) {
        self.grade = grade;
        self.vertretungsplanItems = [];
    }
}

struct Vertretungsplan {
    var date: String!
    var gradeItems: [GradeItem]!
    var expanded: Bool!

    init(date: String!, gradeItems: [GradeItem]!, expanded: Bool!) {
        self.date = date;
        self.gradeItems = gradeItems;
        self.expanded = expanded;
    }
}
