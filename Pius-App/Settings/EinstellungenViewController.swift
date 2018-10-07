//
//  EinstellungenViewController.swift
//  Pius-App
//
//  Created by Michael on 28.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class EinstellungenViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webSiteUserNameField: UITextField!
    @IBOutlet weak var webSitePasswordField: UITextField!
    @IBOutlet weak var myCoursesButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var ruler3: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var gradePickerView: UIPickerView!
    @IBOutlet weak var classPickerView: UIPickerView!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    @IBAction func loginButtonAction(_ sender: Any) {
        dismissKeyboard(fromTextField: activeTextField)
        saveCredentials();
    }
    
    // The active text field, is either webSizeUserNameField or webSitePasswordField.
    private var activeTextField: UITextField?;
    
    // Checks reachability of Pius Gateway
    private let reachabilityChecker = ReachabilityChecker(forName: AppDefaults.baseUrl);

    private func setVersionLabel() {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject;
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String;
        let versionString = String(format: "Pius-App für iOS Version %@", version);

        versionLabel.text = versionString;
    }

    // Checks if grade picker has selected an upper grade.
    private func isUpperGradeSelected(_ row: Int) -> Bool {
        return Config.upperGrades.index(of: Config.grades[row]) != nil
    }
    
    private func isLowerGradeSelected(_ row: Int) -> Bool {
        return Config.lowerGrades.index(of: Config.grades[row]) != nil
    }
    
    // Update Login button text depending on authentication state.
    private func updateLoginButtonText(authenticated: Bool?) {
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
            // Stop activity indicator but keep blur effect.
            self.activityIndicator.stopAnimating();
            self.loginButtonOutlet.isEnabled = true;

            // create the alert
            let message = (authenticated) ? "Du bist nun angemeldet." : "Die Anmeldedaten sind ungültig.";
            let alert = UIAlertController(title: "Anmeldung", message: message, preferredStyle: UIAlertController.Style.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil));
            self.present(alert, animated: true, completion: nil);

            // Store current authentication state in user settings and update text of
            // login button.
            if (authenticated) {
                AppDefaults.authenticated = true;
                self.webSiteUserNameField.isEnabled = false;
                self.webSitePasswordField.isEnabled = false;
            } else {
                AppDefaults.authenticated = false;
            }
            
            self.updateLoginButtonText(authenticated: authenticated);
        };
    }

    // Bring grade and class picker into a consistent state.
    private func setElementStates(forSelectedGrade row: Int) -> Void {
        // If grade "None" is selected class picker also is set to None.
        if (row == 0) {
            classPickerView.selectRow(0, inComponent: 0, animated: true);
            AppDefaults.selectedClassRow = 0;
            
            classPickerView.isUserInteractionEnabled = false;
            myCoursesButton.isEnabled = false;
            myCoursesButton.backgroundColor = UIColor.lightGray;

        }

        // When user has selected EF, Q1 or Q2 set class picker view to "None" and disable.
        // Enable "Meine Kurse" button.
        else if (isUpperGradeSelected(row)) {
            classPickerView.selectRow(0, inComponent: 0, animated: true);
            AppDefaults.selectedClassRow = 0;

            classPickerView.isUserInteractionEnabled = false;
            myCoursesButton.isEnabled = true;
            myCoursesButton.backgroundColor = Config.colorPiusBlue;

        // When a lower grade is selected disable "Meine Kurse" button and make sure
        // that class is defined.
        } else if (isLowerGradeSelected(row) ){
            if (classPickerView.selectedRow(inComponent: 0) == 0) {
                classPickerView.selectRow(1, inComponent: 0, animated: true);
                AppDefaults.selectedClassRow = 1;
            }

            classPickerView.isUserInteractionEnabled = true;
            myCoursesButton.isEnabled = false;
            myCoursesButton.backgroundColor = UIColor.lightGray;

        // Neither
        } else {
            classPickerView.selectRow(0, inComponent: 0, animated: true);
            AppDefaults.selectedClassRow = 0;
            myCoursesButton.isEnabled = false;
            myCoursesButton.backgroundColor = UIColor.lightGray;
        }
    }
    
    // Return the number of components in picker view;
    // Defaults to 1 in this case.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // Return content for the named row and picker view.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == gradePickerView) {
            return Config.getGradeNameForSetting(setting: row);
        }
        return Config.getClassNameForSetting(setting: row);
    }
    
    // Return the number of rows in the named picker view.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == gradePickerView) {
            return Config.grades.count;
        }
        return Config.classes.count;
    }
    
    // Store selected grade and class in user settings.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == gradePickerView) {
            // If user switches from upper grade row to non-upper grade make sure that at least "a" is selected as
            // class.
            if (!isUpperGradeSelected(row) && isUpperGradeSelected(AppDefaults.selectedGradeRow!)) {
                classPickerView.selectRow(1, inComponent: 0, animated: true);
                AppDefaults.selectedClassRow = 1;
            }

            AppDefaults.selectedGradeRow = row;
            setElementStates(forSelectedGrade: row);
        } else {
            // If a non-upper grade row is picked prevent user from setting "none" for class.
            if (row == 0 && !isUpperGradeSelected(AppDefaults.selectedGradeRow!)) {
                classPickerView.selectRow(1, inComponent: 0, animated: true);
                AppDefaults.selectedClassRow = 1;
            } else {
                AppDefaults.selectedClassRow = row;
            }
        }
        
        // Update subscription when app has push notifications enabled.
        if let deviceToken = Config.currentDeviceToken {
            let deviceTokenManager = DeviceTokenManager();
            deviceTokenManager.registerDeviceToken(token: deviceToken, subscribeFor: AppDefaults.gradeSetting, withCourseList: AppDefaults.courseList);
        }
    }

    // Saves credentials in shared defaults.
    private func saveCredentials() {
        // User is not authenticated; in this case we want to set credentials.
        if (!AppDefaults.authenticated) {
            // Save credentials in user defaults.
            let webSiteUserName = webSiteUserNameField.text!;
            let webSitePassword = webSitePasswordField.text!;
            
            AppDefaults.password = webSitePassword;
            AppDefaults.username = webSiteUserName;
            
            // Show activity indicator.
            activityIndicator.startAnimating();
            
            // Validate credentials; this will also update authenticated state
            // of the app.
            let vertretungsplanLoader = VertretungsplanLoader();

            self.loginButtonOutlet.isEnabled = false;
            vertretungsplanLoader.validateLogin(notfifyMeOn: self.validationCallback);
        } else {
            // User is authenticated and wants to logout.
            webSiteUserNameField.text = "";
            webSitePasswordField.text = "";

            // Delete credential from from user settings and clear text of username
            // and password field.
            AppDefaults.username = "";
            AppDefaults.password = "";
            AppDefaults.authenticated = false;
            updateLoginButtonText(authenticated: false);
            
            // Inform user on new login state.
            let alert = UIAlertController(title: "Anmeldung", message: "Du bist nun abgemeldet.", preferredStyle: UIAlertController.Style.alert);
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil));
            self.present(alert, animated: true, completion: nil);
            
            webSiteUserNameField.isEnabled = true;
            webSitePasswordField.isEnabled = true;
        }
    }

    // Sets credentials from sahred defaults in UI.
    private func showCredentials() {
        let (webSiteUserName, webSitePassword) = AppDefaults.credentials;
        
        webSiteUserNameField.text = webSiteUserName;
        webSitePasswordField.text = webSitePassword;

        updateLoginButtonText(authenticated: AppDefaults.authenticated);
    }

    // Dismiss keyboard on tap gesture somwwhere into view controller.
    @IBAction func tapGestureAction(_ sender: Any) {
        dismissKeyboard(fromTextField: activeTextField);
    }
    
    private func dismissKeyboard(fromTextField textField: UITextField?) {
        if (textField != nil) {
            textField?.resignFirstResponder();
        }
    }

    // Remember text field in which editing has begun.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField;
    }
    
    // Forget text field which was edited in as editing has ended.
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil;
    }

    // Dismiss keyboard on request.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(fromTextField: textField);
        return true;
    }

    // Keyboard was shown, we need to resize our scrollview to make sure that keyboard is visible
    // on any device.
    @objc func keyboardWasShown(notification: NSNotification) {
        guard activeTextField != nil else { return };

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0);
            scrollView.contentInset = contentInsets;
            scrollView.scrollIndicatorInsets = contentInsets;
            
            var cgRect: CGRect = scrollView.frame;
            cgRect.size.height -= keyboardSize.height;
            
            if (!cgRect.contains(loginButtonOutlet!.frame.origin)) {
                scrollView.scrollRectToVisible(loginButtonOutlet!.frame, animated: true);
            }
        }
    }

    // Keyboard will hide; scroll view can be expanded again.
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero;
        scrollView.contentInset = contentInsets;
        scrollView.scrollIndicatorInsets = contentInsets;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        setVersionLabel();
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        webSitePasswordField.delegate = self;
        webSiteUserNameField.delegate = self;
        
        scrollView.addGestureRecognizer(tapGestureRecognizer);
        
        // Disable Login and Logout when offline.
        let isOnline = reachabilityChecker.isNetworkReachable();
        let isAuthenticated = AppDefaults.authenticated;
        
        webSiteUserNameField.isEnabled = isOnline && !isAuthenticated;
        webSitePasswordField.isEnabled = isOnline && !isAuthenticated;
        loginButtonOutlet.isEnabled = isOnline;
        
        if let classRow = AppDefaults.selectedClassRow {
            classPickerView.selectRow(classRow, inComponent: 0, animated: false);
        }

        if let gradeRow = AppDefaults.selectedGradeRow {
            gradePickerView.selectRow(gradeRow, inComponent: 0, animated: false);
            setElementStates(forSelectedGrade: gradeRow);
        }
        
        showCredentials();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
