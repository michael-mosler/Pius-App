//
//  PiusAppActionSheetAppearance.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 05.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import Foundation
import UIKit
import Sheeeeeeeeet

/// Defines color scheme for ActionSheets. Add you app specific
/// customizations to this class.
class PiusAppActionSheetAppearance: ActionSheetAppearance {
    /// App color definition.
    override func applyColors() {
        super.applyColors()
        
        okButton.titleColor = UIColor(named: "piusBlue")
        cancelButton.titleColor = UIColor(named: "piusBlue")
        
        item.titleColor = UIColor(named: "piusBlue")
        item.subtitleColor = UIColor(named: "piusBlue")
        
        singleSelectItem.titleColor = UIColor(named: "piusBlue")
        singleSelectItem.selectedTitleColor = UIColor(named: "piusBlue")
        singleSelectItem.selectedTitleFont = .boldSystemFont(ofSize: 16)
        singleSelectItem.selectedIconColor = UIColor(named: "piusBlue")
        
        multiSelectItem.titleColor = UIColor(named: "piusBlue")
        multiSelectItem.selectedTitleColor = UIColor(named: "piusBlue")
        multiSelectItem.selectedTitleFont = .boldSystemFont(ofSize: 16)
        multiSelectItem.selectedIconColor = UIColor(named: "piusBlue")
    }
}
