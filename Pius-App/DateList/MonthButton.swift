//
//  MonthButton.swift
//  Pius-App
//
//  Created by Michael on 13.06.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

// Extends button with a property that holds information on the
// month the button has been created for.
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

    // Color button depending on its selection state.
    private func setButtonColorForState() {
        if (isSelected) {
            backgroundColor = config.colorPiusBlue;
            setTitleColor(UIColor.white, for: .normal);
        } else {
            backgroundColor = UIColor.white;
            setTitleColor(config.colorPiusBlue, for: .normal);
        }
    }

    // Makes a new month button amd sets its default color.
    func makeMonthButton(for month: Int, with name: String) {
        forMonth = month;
        isSelected = false;
        
        setImage(nil, for: .normal);
        setTitle(name, for: .normal);
        
        setButtonColorForState();
    }
    
    // When set button also gets automatically colored correctly.
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
