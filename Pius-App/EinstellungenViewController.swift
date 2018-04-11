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
    @IBOutlet weak var loginButtonOutlet: UIButton!
    @IBAction func loginButton(_ sender: Any) {
        self.saveCredentials();
    }
    
    @IBOutlet weak var gradePickerView: UIPickerView!
    @IBOutlet weak var classPickerView: UIPickerView!
    
    let config = Config();
    
    // Update Login button text depending on authentication state.
    func updateLoginButtonText(authenticated: Bool?) {
        if (authenticated != nil && authenticated!) {
            loginButtonOutlet.setTitle("Abmelden", for: .normal);
        } else {
            loginButtonOutlet.setTitle("Anmelden", for: .normal);
        }
    }

    // Callback for credential check. When credentials have been checked successfully authState is set to true and
    // button text of Login button changes to "Logout".
    func validationCallback(authenticated: Bool) {
        DispatchQueue.main.async {
            // create the alert
            let message = (authenticated) ? "Die Anmeldung war erfolgreich." : "Die Anmeldedaten sind ungültig.";
            let alert = UIAlertController(title: "Anmeldung", message: message, preferredStyle: UIAlertControllerStyle.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil));
            self.present(alert, animated: true, completion: nil);
            
            if (authenticated) {
                self.config.userDefaults.set(true, forKey: "authenticated");
            } else {
                self.config.userDefaults.set(false, forKey: "authenticated");
            }
            
            self.updateLoginButtonText(authenticated: authenticated);
        };
    }

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
            config.userDefaults.set(row, forKey: "selectedGradeRow");
        } else {
            config.userDefaults.set(row, forKey: "selectedClassRow");
        }
    }

    private func saveCredentials() {
        do {
            // User is not authenticated; in this case we want to set credentials.
            if (!config.userDefaults.bool(forKey: "authenticated")) {
                // Save credentials in user defaults.
                let webSiteUserName = webSiteUserNameField.text!;
                let webSitePassword = webSitePasswordField.text!;
                
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: KeychainConfiguration.accessGroup);
                try passwordItem.savePassword(webSitePassword);
                
                config.userDefaults.set(webSiteUserName, forKey: "webSiteUserName");

                // Validate credentials; this will also update authenticated state
                // of the app.
                let vertretungsplanLoader = VertretungsplanLoader();
                vertretungsplanLoader.validateLogin(notfifyMeOn: self.validationCallback);
            } else {
                // User is authenticated and wants to logout.
                webSiteUserNameField.text = "";
                webSitePasswordField.text = "";

                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: "PiusApp", accessGroup: KeychainConfiguration.accessGroup);
                try passwordItem.savePassword("");

                config.userDefaults.set("", forKey: "webSiteUserName");
                config.userDefaults.set(false, forKey: "authenticated");
                updateLoginButtonText(authenticated: false);
            }
        }
        catch {
            fatalError("Die Anmeldedaten konnte nicht gespeichert werden - \(error)");
        }
    }

    private func showCredentials() {
        let config = Config();
        let (webSiteUserName, webSitePassword) = config.getCredentials();
        
        webSiteUserNameField.text = webSiteUserName;
        webSitePasswordField.text = webSitePassword;

        updateLoginButtonText(authenticated: config.userDefaults.bool(forKey: "authenticated"));
    }

    override func viewDidLoad() {
        super.viewDidLoad();

        var row : Int;
        row = config.userDefaults.integer(forKey: "selectedGradeRow");
        gradePickerView.selectRow(row, inComponent: 0, animated: false)

        row = config.userDefaults.integer(forKey: "selectedClassRow");
        classPickerView.selectRow(row, inComponent: 0, animated: false);
        
        showCredentials();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

