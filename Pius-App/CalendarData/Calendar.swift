//
//  Calendar.swift
//  Pius-App
//
//  Created by Michael on 12.06.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import Foundation

struct DayItem {
    private var _detailItems: DetailItems;
    var detailItems: DetailItems {
        get {
            return _detailItems;
        }
    }
    
    init(detailItems: DetailItems) {
        self._detailItems = detailItems;
    }
};

struct MonthItem {
    private var _name: String;
    var name: String {
        get {
            let index = _name.index(_name.endIndex, offsetBy: -2)
            return "\(_name.prefix(3)) \(_name[index...])";
        }
    }

    private var _dayItems: [DayItem];
    var dayItems: [DayItem] {
        get {
            return _dayItems;
        }
    }
    
    init(name: String, dayItems: [DayItem]) {
        self._name = name;
        self._dayItems = dayItems;
    }
}

struct Calendar {
    var monthItems: [MonthItem] = []
}
