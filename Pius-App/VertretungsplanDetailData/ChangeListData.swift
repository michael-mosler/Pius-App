//
//  ChangeListData.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 29.06.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation

typealias DateItems = [(String, [NSDictionary])]

class ChangeListDateItemCollection {
    private var dateItems_: [String: [NSDictionary]] = [:]
    public var dateItems: DateItems { return sort() }
    
    init(from deltaList: NSArray) {
        deltaList.forEach({ item_ in
            let item = item_ as! NSDictionary
            let date = item["date"] as! String
            
            if dateItems_[date] == nil {
                dateItems_[date] = [item];
            } else {
                dateItems_[date]?.append(item)
            }
        })
    }
    
    func sort() -> DateItems {
        let sortedDateItems = dateItems_.sorted {
            // Sort by date from schedule. This date has form "Day name, dd.MM.yyyy".
            // We skip day name and convert remaining part into a Date object.
            let key0 = $0.key
            let key1 = $1.key
            let index0 = key0.index(key0.endIndex, offsetBy: -10)
            let index1 = key1.index(key1.endIndex, offsetBy: -10)
            
            let strDate0 = String(key0[index0...])
            let strDate1 = String(key1[index1...])
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "de_DE");
            dateFormatter.dateFormat = "dd.MM.yyyy"

            let date0 = dateFormatter.date(from: strDate0) ?? Date()
            let date1 = dateFormatter.date(from: strDate1) ?? Date()
            
            return date0 < date1
        }

        return sortedDateItems
    }
}
