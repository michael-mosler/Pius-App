//
//  BrowserSelection.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 02.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import Foundation
import UIKit
import Sheeeeeeeeet

/// Function definition for browser selection callback.
/// - Parameter selection: Actual selection
typealias OnBrowserSelect = (_ selection: AppDefaults.BrowserSelection?) -> Void

/// Implement this protocol to get notified when user has selected browser
/// to use.
protocol BrowserSelectProtocol {
    /// The function is called after browser has been selected.
    /// - Parameter selection: Actual selection
    func onBrowserSelect(selection: AppDefaults.BrowserSelection?)
}

/// Depending on the configuration value of AppDefaults.browser
/// this class either returns the browser engine to use or asks
/// user which engine to use.
class BrowserSelection {
    private let parentViewController: UIViewController?
    private let onSelect: OnBrowserSelect

    init(parentViewController: UIViewController?,
         onSelect: @escaping OnBrowserSelect) {
        self.parentViewController = parentViewController
        self.onSelect = onSelect
    }

    /// Gets users choice on browser selection. If user has selected to always ask
    /// then user's choice will be requested. If user decides for a persistent option
    /// setting will be updated. 
    /// - Returns: The Browser engine to use. This will never be .ask
    func choice() {
        if AppDefaults.rememberBrowserSelection {
            onSelect(AppDefaults.browser)
        } else {
            userChoice()
        }
    }
    
    /// Ask user for browser engine to use. User also has the option
    /// of persisting this selection. In this case he should not be
    /// asked again until this is reset in app settings.
    private func userChoice() {
        guard let parentViewController = parentViewController else {
            onSelect(.useInternal)
            return
        }

        let useInternal = AppDefaults.browser == .useInternal
        let userSafari = AppDefaults.browser == .useSafari

        let item1 = SingleSelectItem(title: "In-App Ansicht", isSelected: useInternal, group: "browser", tapBehavior: .none)
        let item2 = SingleSelectItem(title: "Safari", isSelected: userSafari, group: "browser", tapBehavior: .none)

        let sectionMargin = SectionMargin()
        let sectionTitle = SectionTitle(title: "Standard festlegen")
        let item3 = MultiSelectItem(title: "Nicht mehr fragen", isSelected: AppDefaults.rememberBrowserSelection, group: "persist")

        let ok = OkButton(title: "Ok")
        let cancel = CancelButton(title: "Abbrechen")
        let items = [item1, item2, sectionMargin, sectionTitle, item3, ok, cancel]
        let menu = Menu(title: "Wähle bitte einen Browser", items: items)
        let sheet = BrowserSelectionActionSheet(menu: menu) { (sheet, item) in
            let sheet = sheet as! BrowserSelectionActionSheet
            if item is OkButton {
                let selection: AppDefaults.BrowserSelection = (item1.isSelected) ? .useInternal : .useSafari
                
                // If user asks to remember selection then persist browser
                // and remember option.
                if item3.isSelected {
                    AppDefaults.browser = selection
                    AppDefaults.rememberBrowserSelection = item3.isSelected
                }
                
                sheet.selection = selection
            } else if item is CancelButton {
                sheet.dismiss()
            }
        }

        sheet.present(in: parentViewController, onSelect: onSelect)
    }
}

/// The only purpose of this class is to make sure that onSelect() is called
/// whenever action sheet is dismissed.
private class BrowserSelectionActionSheet: ActionSheet {
    var onSelect: OnBrowserSelect?
    var selection: AppDefaults.BrowserSelection?
    
    /// Views disappear handler. It will call onSelect() with the
    /// selection that has been set.
    /// - Parameter animated: Disappear with animation if true
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onSelect?(selection)
    }
    
    /// Call action sheet's present method after setting onSelect handler.
    /// - Parameters:
    ///   - vc: View controller sheet is presented in
    ///   - onSelect: onSelect handler is called when view is dismissed.
    func present(in vc: UIViewController, onSelect: @escaping OnBrowserSelect) {
        self.onSelect = onSelect
        super.present(in: vc, from: nil)
    }
}
