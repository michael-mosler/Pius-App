//
//  AboutViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 24.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

/// Shows information on the app and the libraries that are used.
class AboutViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var versionLabelOutlet: UILabel!
    @IBOutlet weak var infoTextViewOutlet: UITextView!
    @IBOutlet weak var dataSecurityLabelOutlet: UILabel!
    @IBOutlet weak var reachabilityLabelOutlet: UILabel!
    @IBOutlet weak var kingFisherLabelOutlet: UILabel!
    @IBOutlet weak var mgSwipeTableCellLabelOutlet: UILabel!
    @IBOutlet weak var gitHubLabelOutlet: UILabel!
    @IBOutlet weak var sheeeeeeeeetLabelOutlet: UILabel!
    
    private var segueData: Any?
    private var labelToUrlMap: [UIView : String?] = [:]
    private let linkColor = UIColor(named: "piusBlue")

    /// Initialize view controller after loading.
    override func viewDidLoad() {
        super.viewDidLoad()

        setVersionLabel()
        bindGestureRecognizer()
        buildLabelToUrlMap()
        
        dataSecurityLabelOutlet.colorText(with: linkColor)
        gitHubLabelOutlet.colorText(with: linkColor)
    }
    
    /// When view reappears bring tabbar item title in sync with
    /// selected view controller.
    /// - Parameter animated: Passed to super-class method call
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.selectedItem?.title = title
    }

    /// Set label colour of app text box on iOS 13. This is needed in
    /// dark mode.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 13.0, *) {
            infoTextViewOutlet.textColor = UIColor.label
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NewsArticleViewController {
            destination.segueData = segueData
        }
    }
    
    /// Handle tap gesture on label.
    /// - Parameter gestureRecognizer: Gesture recognizer that received tap.
    @objc func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        guard
            let entry = labelToUrlMap.first(where: { (key, _) in
                key == gestureRecognizer.view
            }),
            let value = entry.value,
            let url = URL(string: value)
        else { return }
        
        segueData = url
        performSegue(withIdentifier: "showInfo", sender: self)
    }

    /// Build view to URL map. This map is used by handleTap()
    /// to open URL assigned to label.
    private func buildLabelToUrlMap() {
        labelToUrlMap[dataSecurityLabelOutlet] = "https://github.com/michael-mosler/Pius-App/wiki/Datenschutzrichtlinie"
        labelToUrlMap[reachabilityLabelOutlet] = "https://github.com/ashleymills/Reachability.swift"
        labelToUrlMap[kingFisherLabelOutlet] = "https://github.com/onevcat/Kingfisher"
        labelToUrlMap[mgSwipeTableCellLabelOutlet] = "https://github.com/MortimerGoro/MGSwipeTableCell"
        labelToUrlMap[gitHubLabelOutlet] = "https://github.com/michael-mosler/Pius-App"
        labelToUrlMap[sheeeeeeeeetLabelOutlet] = "https://github.com/danielsaidi/Sheeeeeeeeet"
    }

    /// Bind tap gesture recognizer to labels.
    private func bindGestureRecognizer() {
        dataSecurityLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        reachabilityLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        kingFisherLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        mgSwipeTableCellLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        gitHubLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        sheeeeeeeeetLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    /// Sets the version label.
    private func setVersionLabel() {
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        
        //Then just cast the object as a String, but be careful,
        // you may want to double check for nil.
        let version = nsObject as! String
        let versionString = String(format: "Pius-App für iOS Version %@", version)

        versionLabelOutlet.text = versionString
    }
}
