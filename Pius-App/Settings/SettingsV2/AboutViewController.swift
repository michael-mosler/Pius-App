//
//  AboutViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 24.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var versionLabelOutlet: UILabel!
    @IBOutlet weak var infoTextViewOutlet: UITextView!
    @IBOutlet weak var dataSecurityLabelOutlet: UILabel!
    @IBOutlet weak var reachabilityLabelOutlet: UILabel!
    @IBOutlet weak var kingFisherLabelOutlet: UILabel!
    @IBOutlet weak var mgSwipeTableCellLabelOutlet: UILabel!
    @IBOutlet weak var gitHubLabelOutlet: UILabel!
    
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
        
        UIApplication.shared.open(url)
    }

    /// Set label colour of app text box on iOS 13. This is needed in
    /// dark mode.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 13.0, *) {
            infoTextViewOutlet.textColor = UIColor.label
        }
    }
    
    /// Build view to URL map. This map is used by handleTap()
    /// to open URL assigned to label.
    private func buildLabelToUrlMap() {
        labelToUrlMap[dataSecurityLabelOutlet] = "https://github.com/michael-mosler/Pius-App/wiki/Datenschutzrichtlinie"
        labelToUrlMap[reachabilityLabelOutlet] = "https://github.com/ashleymills/Reachability.swift"
        labelToUrlMap[kingFisherLabelOutlet] = "https://github.com/onevcat/Kingfisher"
        labelToUrlMap[mgSwipeTableCellLabelOutlet] = "https://github.com/MortimerGoro/MGSwipeTableCell"
        labelToUrlMap[gitHubLabelOutlet] = "https://github.com/michael-mosler/Pius-App"
    }

    /// Bind tap gesture recognizer to labels.
    private func bindGestureRecognizer() {
        dataSecurityLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        reachabilityLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        kingFisherLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        mgSwipeTableCellLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        gitHubLabelOutlet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
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

extension UILabel {
    /// Highlight text that is enclosed by "*" characters.
    /// - Parameter color: Color to use for highlighting. If not given default color is used.
    func colorText(with color: UIColor?) {
        guard
            let regex: NSRegularExpression = try? NSRegularExpression(pattern: "\\*[^*]*\\*"),
            let attributedSourceText = attributedText
        else { return }
        
        // Find all substrings to color.
        let labelText = attributedSourceText.string
        let searchRange = NSRange(location: 0, length: labelText.count)
        let results = regex.matches(in: labelText, options: [], range: searchRange)

        var linkColor: UIColor
        if #available(iOS 13, *) {
            linkColor = color ?? UIColor.link
        } else {
            linkColor = color ?? UIColor.systemBlue
        }

        let attributedTargetText = NSMutableAttributedString(attributedString: attributedSourceText)
        let targetText = attributedTargetText.string

        // For each substring created a colored attributed string and replace
        // substring with this new attributed string. Remove "*" characters from
        // target.
        attributedTargetText.beginEditing()
        results.forEach({ result in
            if let range = Range(result.range, in: targetText) {
                var matchedText = String(targetText[range.lowerBound..<range.upperBound])
                matchedText = matchedText.replacingOccurrences(of: "*", with: "")
                
                let attributedMatchedText = NSAttributedString(string: matchedText, attributes: [NSAttributedString.Key.foregroundColor : linkColor])
                attributedTargetText.replaceCharacters(in: result.range, with: attributedMatchedText)
            }
        })
        attributedTargetText.endEditing()
        
        attributedText = attributedTargetText
    }
}
