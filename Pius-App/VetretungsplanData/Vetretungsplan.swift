//
//  Vetretungsplan.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

struct Vertretungsplan {
    var date: String!
    var grades: [String]!
    var expanded: Bool!

    init(date: String!, grades: [String]!, expanded: Bool!) {
        self.date = date;
        self.grades = grades;
        self.expanded = expanded;
    }
}
