//
//  DateArithmetic.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 08.09.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation

/*
 * Calendar arithmetic. Thanks to nunogoncalves for sharing this gist.
 * https://gist.github.com/nunogoncalves/2cb7c7788a8f017e124d84a22c43e7fd
 */

struct CalendarComponentAmount {
    let component: Foundation.Calendar.Component
    let amount: Int
}

infix operator +: AdditionPrecedence
extension Date {
    static func +(date: Date, componentAmount: CalendarComponentAmount) -> Date {
        let calendar = Foundation.Calendar(identifier: .gregorian)
        return calendar.date(byAdding: componentAmount.component, value: componentAmount.amount, to: date)!
    }
}

extension Int {
    var years: CalendarComponentAmount {
        return CalendarComponentAmount(component: .year, amount: self)
    }
    
    var months: CalendarComponentAmount {
        return CalendarComponentAmount(component: .month, amount: self)
    }
    
    var days: CalendarComponentAmount {
        return CalendarComponentAmount(component: .day, amount: self)
    }
    
    var hours: CalendarComponentAmount {
        return CalendarComponentAmount(component: .hour, amount: self)
    }
    
    var minutes: CalendarComponentAmount {
        return CalendarComponentAmount(component: .minute, amount: self)
    }
    
    var seconds: CalendarComponentAmount {
        return CalendarComponentAmount(component: .second, amount: self)
    }
}
