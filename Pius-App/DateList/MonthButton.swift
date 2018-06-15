//
//  MonthButton.swift
//  Pius-App
//
//  Created by Michael on 13.06.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class MonthButton: UIButton {
    private var config = Config();
    private var _forMonth: Int? = nil;
    
    var forMonth: Int? {
        get {
            return _forMonth;
        }
        
        set(month) {
            _forMonth = month;
        }
    }

    private func setButtonColorForState() {
        if (isSelected) {
            backgroundColor = config.colorPiusBlue;
            setTitleColor(UIColor.white, for: .normal);
        } else {
            backgroundColor = UIColor.white;
            setTitleColor(config.colorPiusBlue, for: .normal);
        }
    }

    func makeMonthButton(for month: Int, with name: String) {
        forMonth = month;
        isSelected = false;
        
        setImage(nil, for: .normal);
        setTitle(name, for: .normal);
        
        setButtonColorForState();
    }
    
    override var isSelected: Bool {
        set(value) {
            super.isSelected = value;
            setButtonColorForState();
        }
        
        get {
            return super.isSelected;
        }
    }
}
