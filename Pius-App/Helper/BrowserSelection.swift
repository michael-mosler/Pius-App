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

typealias OnBrowserSelect = (_ selection: AppDefaults.BrowserSelection) -> Void
protocol BrowserSelectProtocol {
    func onBrowserSelect(selection: AppDefaults.BrowserSelection)
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

        let item1 = SingleSelectItem(title: "Interner Browser", isSelected: useInternal, group: "browser", tapBehavior: .none)
        let item2 = SingleSelectItem(title: "Safari", isSelected: userSafari, group: "browser", tapBehavior: .none)

        let sectionMargin = SectionMargin()
        let sectionTitle = SectionTitle(title: "Standard festlegen")
        let item3 = MultiSelectItem(title: "Nicht mehr fragen", isSelected: AppDefaults.rememberBrowserSelection, group: "persist")

        let ok = OkButton(title: "Ok")
        let cancel = CancelButton(title: "Abbrechen")
        let items = [item1, item2, sectionMargin, sectionTitle, item3, ok, cancel]
        let menu = Menu(title: "Wähle bitte einen Browser", items: items)
        let sheet: ActionSheet = menu.toActionSheet() { (sheet, item) in
            if item is OkButton {
                let selection: AppDefaults.BrowserSelection = (item1.isSelected) ? .useInternal : .useSafari
                
                AppDefaults.browser = selection
                AppDefaults.rememberBrowserSelection = item3.isSelected
                
                self.onSelect(selection)
            } else if item is CancelButton {
                sheet.dismiss()
            }
        }
        
        sheet.present(in: parentViewController, from: nil)
    }
}
