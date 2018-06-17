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

class Calendar {
    var _filter: String? = nil;
    var filter: String? {
        set(filter) {
            _filter = filter?.lowercased();
        }
        get {
            return _filter;
        }
    }

    var monthItems: [MonthItem] = []

    var allItems: [Any] {
        var _allItems: [Any] = [];
        
        monthItems.forEach { monthItem in
            var _dayItems: [Any] = [];

            monthItem.dayItems.forEach { dayItem in
                if (filter != nil && filter!.count > 0) {
                    if (dayItem.detailItems[1].lowercased().contains(filter!)) {
                        _dayItems.append(dayItem.detailItems);
                    }
                } else {
                    _dayItems.append(dayItem.detailItems);
                }
            }

            if (_dayItems.count > 0) {
                _allItems.append(monthItem.name);
                _allItems += _dayItems;
            }
        }

        return _allItems;
    }
}
