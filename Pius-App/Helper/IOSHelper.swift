//
//  IOSHelper.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 21.01.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation
import UIKit

class IOSHelper {
    // Returns screen width.
    static var screenWidth: Int {
        get {
            return Int(UIScreen.main.bounds.width);
        }
    }
}

struct TodayScreenUnits {
    static let timetableRowHeight = 35
    static let timetableSpacing = 8
    
}
