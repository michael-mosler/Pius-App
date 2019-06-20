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
    
    // On search this property is to the range that defines a match.
    // It can be used to hightlight the search result.
    public var highlight: [NSRange];

    init(detailItems: DetailItems) {
        self._detailItems = detailItems;
        self.highlight = [];
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
    
    var fullName: String {
        get {
            return _name;
        }
    }

    private var _dayItems: [DayItem];
    var dayItems: [DayItem] {
        get {
            return _dayItems;
        }
        
        set(value) {
            _dayItems = value;
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
            _filter = filter;
        }
        get {
            return _filter;
        }
    }

    var monthItems: [MonthItem] = []

    // Contains all calendar entries. If a filter is set contains only
    // those items that match the filter.
    var allItems: [Any] {
        var _allItems: [Any] = [];
        
        monthItems.forEach { monthItem in
            var _dayItems: [Any] = [];

            monthItem.dayItems.forEach { dayItem in
                if let _filter = filter, _filter.count > 0 {
                    if let stringRanges = dayItem.detailItems[1].allStandardRanges(of: _filter) {
                        var _dayItem = dayItem;
                        stringRanges.forEach { stringRange in
                            _dayItem.highlight.append(NSRange(stringRange, in: dayItem.detailItems[1]));
                        };
                        _dayItems.append(_dayItem);
                    }
                } else {
                    _dayItems.append(dayItem);
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
