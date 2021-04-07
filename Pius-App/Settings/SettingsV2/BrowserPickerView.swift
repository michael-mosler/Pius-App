//
//  BrowserPickerView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 05.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit

/// Implements settings browser picker view.
class BrowserPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
    }
    
    /// Returns number of components (always 1)
    /// - Parameter pickerView: This picker view
    /// - Returns: Always 1
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    /// Returns number of rows in picker view (always 2)
    /// - Parameters:
    ///   - pickerView: This picker view
    ///   - component: Always 1
    /// - Returns: Always 2
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 2 }
    
    /// Returns title for picker view row.
    /// - Parameters:
    ///   - pickerView: This picker view
    ///   - row: Title is for this row
    ///   - component: Always 1
    /// - Returns: Title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0: return "In-App Ansicht"
        case 1: return "Safari"
        default: return nil
        }
    }
    
    /// Called when user has selected a row. The selection is persistet in app settings.
    /// - Parameters:
    ///   - pickerView: This picker view
    ///   - row: Selected row
    ///   - component: Always 1
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        AppDefaults.browser = AppDefaults.BrowserSelection(rawValue: row) ?? .useInternal
    }
    
    /// Selects row from BrowserSelection value
    /// - Parameter selection: Browser selection value to which selection shall be set.
    func selectRow(forBrowser selection: AppDefaults.BrowserSelection) {
        selectRow(selection.rawValue, inComponent: 0, animated: false)
    }
}

/// This class is used for typing the browser switch control, only.
class BrowserSwitch: UISwitch { }

/// This controller controls behaviour of all browser selection UI controls. It must be
/// instantiated from viewDidLoad() call of view controller.
class BrowserSelectionController: NSObject {
    weak var browserSwitch: BrowserSwitch?
    weak var browserPickerView: BrowserPickerView?
    
    init(_ browserSwitch: BrowserSwitch, _ browserPickerView: BrowserPickerView) {
        super.init()
        
        self.browserSwitch = browserSwitch
        self.browserPickerView = browserPickerView
        
        self.browserSwitch?.isOn = AppDefaults.rememberBrowserSelection
        self.browserPickerView?.selectRow(forBrowser: AppDefaults.browser)

        self.browserSwitch?.addTarget(self, action: #selector(browserSwitchChanged), for: .allTouchEvents)
    }
    
    /// Selector for browser switch. Gets called whenever switch is changed.
    /// - Parameter sender: This is always a BrowserSwitch instance.
    @objc private func browserSwitchChanged(_ sender: UISwitch) {
        AppDefaults.rememberBrowserSelection = browserSwitch?.isOn ?? false
    }
}
