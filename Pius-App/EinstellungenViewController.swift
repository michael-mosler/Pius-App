//
//  EinstellungenViewController.swift
//  Pius-App
//
//  Created by Michael on 28.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class EinstellungenViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var webSiteUserNameField: UITextField!
    @IBOutlet weak var webSitePasswordField: UITextField!
    @IBAction func loginButton(_ sender: Any) {
        self.saveCredentials();
    }
    
    @IBOutlet weak var gradePickerView: UIPickerView!
    @IBOutlet weak var classPickerView: UIPickerView!
    
    let userDefaults = UserDefaults.standard;
    
    let config = Config();
    
    // Return the number of components in picker view;
    // Defaults to 1 in this case.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // Return content for the named row and picker view.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == gradePickerView) {
            return config.getGradeNameForSetting(setting: row);
        }
        return config.getClassNameForSetting(setting: row);
    }
    
    // Return the number if rows in the named picker view.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == gradePickerView) {
            return config.grades.count;
        }
        return config.classes.count;
    }
    
    // Store selected grade and class in user settings.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == gradePickerView) {
            userDefaults.set(row, forKey: "selectedGradeRow");
        } else {
            userDefaults.set(row, forKey: "selectedClassRow");
        }
    }

    private func saveCredentials() {
        do {
            let webSiteUserName = self.webSiteUserNameField.text!;
            let webSitePassword = self.webSitePasswordField.text!;
            
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: KeychainConfiguration.accessGroup);
            try passwordItem.savePassword(webSitePassword);

            userDefaults.set(webSiteUserName, forKey: "webSiteUserName");
        }
        catch {
            fatalError("Die Anmeldedaten konnte nicht gespeichert werden - \(error)");
        }
    }

    private func showCredentials() {
        do {
            guard let webSiteUserName = userDefaults.string(forKey: "webSiteUserName"), !webSiteUserName.isEmpty else { return };

            webSiteUserNameField.text = webSiteUserName;
            
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: KeychainConfiguration.accessGroup);
            try webSitePasswordField.text = passwordItem.readPassword();
        }
        catch {
            fatalError("Die Anmeldedaten konnte nicht geladen werden - \(error)");
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad();

        var row : Int;
        row = userDefaults.integer(forKey: "selectedGradeRow");
        gradePickerView.selectRow(row, inComponent: 0, animated: false)

        row = userDefaults.integer(forKey: "selectedClassRow");
        classPickerView.selectRow(row, inComponent: 0, animated: false);
        
        self.showCredentials();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

