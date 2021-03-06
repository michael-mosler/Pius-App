//
//  EinstellungenViewController.swift
//  Pius-App
//
//  Created by Michael on 28.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WidgetKit
import BEMCheckBox

class EinstellungenViewController:
    UIViewController,
    UIPickerViewDataSource, UIPickerViewDelegate,
    UITextFieldDelegate, UIScrollViewDelegate, BEMCheckBoxDelegate {
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var webSiteUserNameField: UITextField!
    @IBOutlet weak var webSitePasswordField: UITextField!
    @IBOutlet weak var myCoursesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var gradePickerView: UIPickerView!
    @IBOutlet weak var classPickerView: UIPickerView!
    @IBOutlet weak var browserPickerView: BrowserPickerView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var timetableSwitch: UISwitch!
    
    @IBOutlet weak var successBox: BEMCheckBox!
    @IBOutlet weak var browserSwitch: BrowserSwitch!
    
    // The active text field, is either webSizeUserNameField or webSitePasswordField.
    private var activeTextField: UITextField?

    private var browserSelectionController: BrowserSelectionController?
    
    @IBAction func loginButtonAction(_ sender: Any) {
        dismissKeyboard(fromTextField: activeTextField)
        saveCredentials()
    }
    
    @IBAction func timetableSwitchAction(_ sender: Any) {
        guard let sender = sender as? UISwitch else { return }
        AppDefaults.useTimetable = sender.isOn
        elementStates(forSelectedGrade: gradePickerView.selectedRow(inComponent: 0))
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @IBAction func myCoursesButtonAction(_ sender: Any) {
        if timetableSwitch.isOn {
            performSegue(withIdentifier: "toTimetableEditor", sender: sender)
        } else {
            performSegue(withIdentifier: "toCourseListEditor", sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        changeGradeDelegate = tabBarController as! TabBarController
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        webSitePasswordField.delegate = self
        webSiteUserNameField.delegate = self
        
        scrollView.addGestureRecognizer(tapGestureRecognizer)
        
        // Disable Login and Logout when offline.
        let isAuthenticated = AppDefaults.authenticated
        
        webSiteUserNameField.isEnabled = !isAuthenticated
        webSitePasswordField.isEnabled = !isAuthenticated

        timetableSwitch.isOn = AppDefaults.useTimetable

        let classRow = AppDefaults.selectedClassRow ?? 0
        classPickerView.selectRow(classRow, inComponent: 0, animated: false)
        
        let gradeRow = AppDefaults.selectedGradeRow ?? 0
        gradePickerView.selectRow(gradeRow, inComponent: 0, animated: false)
        elementStates(forSelectedGrade: gradeRow)
        showCredentials()
        
        successBox.isHidden = true
        successBox.delegate = self
        
        browserSelectionController = BrowserSelectionController(browserSwitch, browserPickerView)
    }

    /// When view reappears bring tabbar item title in sync with
    /// selected view controller.
    /// - Parameter animated: Passed to super-class method call
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.selectedItem?.title = title
    }

    // When view is closed register device token. We will not wait for result as registrations
    // occur repeatedly triggered by iOS.
    // - Parameter animated: True if view should disappear with animation
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let deviceTokenManager = DeviceTokenManager()
        deviceTokenManager.registerDeviceToken()
    }
    
    /// Callback for login checkbox animation.
    /// - Parameter checkBox: Checkbox that was animated
    func animationDidStop(for checkBox: BEMCheckBox) {
        UIView.animate(withDuration: 0.5, delay: 1, animations: {
            checkBox.alpha = 0
        }, completion: { _ in
            checkBox.alpha = 1
            checkBox.isHidden = true
        })
    }
    
    var changeGradeDelegate: ChangeGradeDelegate?
    
    /// Checks if grade picker has selected an upper grade.
    /// - Parameter row: Row to check in picker view
    /// - Returns: True when upper grade is selected
    private func isUpperGradeSelected(_ row: Int) -> Bool {
        return Config.isUpperGrade(Config.grades[row])
    }
    
    /// Checks if grade picker has selected a lower grade.
    /// - Parameter row: Row to check in picker view
    /// - Returns: True when lower grade is selected
    private func isLowerGradeSelected(_ row: Int) -> Bool {
        return Config.isLowerGrade(Config.grades[row])
    }
    
    /// Update Login button text depending on authentication state.
    /// - Parameter authenticated: True means user is authenticated
    private func updateLoginButtonText(authenticated: Bool?) {
        if (authenticated != nil && authenticated!) {
            loginButton.setTitle("Abmelden", for: .normal)
            loginButton.backgroundColor = UIColor.red
        } else {
            loginButton.setTitle("Anmelden", for: .normal)
            loginButton.backgroundColor = UIColor(named: "piusBlue")
        }
    }

    // Callback for credential check. When credentials have been checked successfully authState is set to true and
    // button text of Login button changes to "Logout".
    func validationCallback(authenticated: Bool, hadError: Bool) {
        DispatchQueue.main.async {
            // Stop activity indicator but keep blur effect.
            self.activityIndicator.stopAnimating()
            self.loginButton.isEnabled = true

            // create the alert
            var message: String?
            if hadError {
                message = "Es ist ein Fehler aufgetreten. Bitte überprüfe Deine Internetverbindung und versuche es noch einmal."
            } else if !authenticated {
                message = "Die Anmeldedaten sind ungültig."
            }
            
            if let message = message {
                let alert = UIAlertController(title: "Anmeldung", message: message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

            // Store current authentication state in user settings and update text of
            // login button.
            if (authenticated) {
                AppDefaults.authenticated = true
                self.webSiteUserNameField.isEnabled = false
                self.webSitePasswordField.isEnabled = false
                
                self.successBox.isHidden = false
                self.successBox.setOn(true, animated: true)
            } else {
                AppDefaults.authenticated = false
            }
            
            self.updateLoginButtonText(authenticated: authenticated)
        }
    }

    // Bring grade and class picker into a consistent state.
    private func elementStates(forSelectedGrade row: Int) -> Void {
        if timetableSwitch.isOn {
            myCoursesButton.setTitle("Stundenplan bearbeiten", for: .normal)
        } else {
            myCoursesButton.setTitle("Kurse hinzufügen", for: .normal)
        }
        
        // If grade "None" is selected class picker also is set to None.
        if (row == 0) {
            classPickerView.selectRow(0, inComponent: 0, animated: true)
            AppDefaults.selectedClassRow = 0
            
            classPickerView.isUserInteractionEnabled = false
            myCoursesButton.isEnabled = false || timetableSwitch.isOn

        }

        // When user has selected EF, Q1 or Q2 set class picker view to "None" and disable.
        // Enable "Meine Kurse" button.
        else if (isUpperGradeSelected(row)) {
            classPickerView.selectRow(0, inComponent: 0, animated: true)
            AppDefaults.selectedClassRow = 0

            classPickerView.isUserInteractionEnabled = false
            myCoursesButton.isEnabled = true

        // When a lower grade is selected disable "Meine Kurse" button and make sure
        // that class is defined.
        } else if (isLowerGradeSelected(row) ){
            if (classPickerView.selectedRow(inComponent: 0) == 0) {
                classPickerView.selectRow(1, inComponent: 0, animated: true)
                AppDefaults.selectedClassRow = 1
            }

            classPickerView.isUserInteractionEnabled = true
            myCoursesButton.isEnabled = false || timetableSwitch.isOn

        // Neither
        } else {
            classPickerView.selectRow(0, inComponent: 0, animated: true)
            AppDefaults.selectedClassRow = 0
            myCoursesButton.isEnabled = false || timetableSwitch.isOn
        }
        
        myCoursesButton.backgroundColor = (myCoursesButton.isEnabled) ? UIColor(named: "piusBlue") : UIColor.lightGray
    }
    
    // Return the number of components in picker view
    // Defaults to 1 in this case.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Return content for the named row and picker view.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == gradePickerView) {
            return Config.getGradeNameForSetting(setting: row)
        }
        return Config.getClassNameForSetting(setting: row)
    }
    
    // Return the number of rows in the named picker view.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView == gradePickerView) {
            return Config.grades.count
        }
        return Config.classes.count
    }
    
    // Store selected grade and class in user settings.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == gradePickerView) {
            // If user switches from upper grade row to non-upper grade make sure that at least "a" is selected as
            // class.
            if (!isUpperGradeSelected(row) && isUpperGradeSelected(AppDefaults.selectedGradeRow!)) {
                classPickerView.selectRow(1, inComponent: 0, animated: true)
                AppDefaults.selectedClassRow = 1
            }

            AppDefaults.selectedGradeRow = row
            elementStates(forSelectedGrade: row)
        } else {
            // If a non-upper grade row is picked prevent user from setting "none" for class.
            if (row == 0 && !isUpperGradeSelected(AppDefaults.selectedGradeRow!)) {
                classPickerView.selectRow(1, inComponent: 0, animated: true)
                AppDefaults.selectedClassRow = 1
            } else {
                AppDefaults.selectedClassRow = row
            }
        }
        
        changeGradeDelegate?.setGrade(grade: AppDefaults.gradeSetting)
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    // Saves credentials in shared defaults.
    private func saveCredentials() {
        // User is not authenticated; in this case we want to set credentials.
        if (!AppDefaults.authenticated) {
            // Save credentials in user defaults.
            let webSiteUserName = webSiteUserNameField.text!
            let webSitePassword = webSitePasswordField.text!
            
            AppDefaults.password = webSitePassword
            AppDefaults.username = webSiteUserName
            
            // Show activity indicator.
            activityIndicator.startAnimating()
            
            // Validate credentials; this will also update authenticated state
            // of the app.
            let vertretungsplanLoader = VertretungsplanLoader()

            self.loginButton.isEnabled = false
            vertretungsplanLoader.validateLogin(notfifyMeOn: self.validationCallback)
        } else {
            // Ask before logging out. Sometimes one taps button accidently.
            let feedbackController = UIAlertController(title: "Abmelden", message: "Möchtest Du dich wirklich abmelden?", preferredStyle: UIAlertController.Style.alert)
            feedbackController.addAction(UIAlertAction(title: "Ja", style: UIAlertAction.Style.destructive, handler: {
                (action: UIAlertAction) in
                // User is authenticated and wants to logout.
                self.webSiteUserNameField.text = ""
                self.webSitePasswordField.text = ""

                // Delete credential from from user settings and clear text of username
                // and password field.
                AppDefaults.username = ""
                AppDefaults.password = nil
                AppDefaults.authenticated = false
                self.updateLoginButtonText(authenticated: false)
                
                self.webSiteUserNameField.isEnabled = true
                self.webSitePasswordField.isEnabled = true
            }))
            feedbackController.addAction(UIAlertAction(title: "Nein", style: UIAlertAction.Style.cancel, handler: nil))
            present(feedbackController, animated: true, completion: nil)
        }
    }

    // Sets credentials from sahred defaults in UI.
    private func showCredentials() {
        let (webSiteUserName, webSitePassword) = AppDefaults.credentials
        
        webSiteUserNameField.text = webSiteUserName
        webSitePasswordField.text = webSitePassword

        updateLoginButtonText(authenticated: AppDefaults.authenticated)
    }

    // Dismiss keyboard on tap gesture somewhere into view controller.
    @IBAction func tapGestureAction(_ sender: Any) {
        guard activeTextField != nil else { return }
        dismissKeyboard(fromTextField: activeTextField)
    }
    
    private func dismissKeyboard(fromTextField textField: UITextField?) {
        textField?.resignFirstResponder()
    }

    // Remember text field in which editing has begun.
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    // Forget text field which was edited in as editing has ended.
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }

    // Dismiss keyboard on request.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(fromTextField: textField)
        return true
    }

    // Keyboard was shown, we need to resize our scrollview to make sure that keyboard is visible
    // on any device.
    @objc func keyboardWasShown(notification: NSNotification) {
        guard activeTextField != nil else { return }

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets: UIEdgeInsets = UIEdgeInsets.init(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            var cgRect: CGRect = scrollView.frame
            cgRect.size.height -= keyboardSize.height
            
            if (!cgRect.contains(loginButton!.frame.origin)) {
                scrollView.scrollRectToVisible(loginButton!.frame, animated: true)
            }
        }
    }

    // Keyboard will hide; scroll view can be expanded again.
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
