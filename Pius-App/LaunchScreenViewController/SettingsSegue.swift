//
//  SettingsSegue.swift
//  Pius-App
//
//  Created by Michael on 13.05.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class SettingsSegue: UIStoryboardSegue {
    override func perform() {
        let navigationController = source.navigationController;
        navigationController?.popToRootViewController(animated: false);
        navigationController?.pushViewController(destination, animated: true);       
    }
}
