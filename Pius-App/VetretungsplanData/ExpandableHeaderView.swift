//
//  ExpandableHeaderView.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

/// This delegate must implement the actual expand/collaps
/// functionality of an ExpandableHeaderView.
protocol ExpandableHeaderViewDelegate {
    /// Toggles expansion/collapsing of section header.
    /// - Parameters:
    ///   - header: The header for which section shall be expanded/collapsed
    ///   - section: Section number
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

/// Table View Header that allows expanding and collapsing of
/// sections.
class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    private var isInitialized = false
    private var delegate: ExpandableHeaderViewDelegate?
    private(set) var section: Int!
    private(set) var expanded: Bool = true
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Action function called when header is tapped.
    /// - Parameter gestureRecognizer: Gesture recognizer
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        expanded = !expanded
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    /// Custom initialization of expandle header view.
    /// - Parameters:
    ///   - userInteractionEnabled: Pass true if enabled
    ///   - section: Table section no. this header is for
    ///   - expanded: Pass true if initially expanded
    ///   - delegate: Delegate to call when header is toggled
    func customInit(
        userInteractionEnabled: Bool = true,
        section: Int,
        expanded: Bool = true,
        delegate: ExpandableHeaderViewDelegate)
    {
        guard !isInitialized else { return }
        self.isInitialized = true
        self.section = section
        self.expanded = expanded
        self.delegate = delegate
        self.isUserInteractionEnabled = userInteractionEnabled
    }
    
    /// Sets look and feel of expandable header table cell.
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = isUserInteractionEnabled ? UIColor(named: "piusBlue") : .lightGray
        textLabel?.textColor = UIColor.white
        textLabel?.font = textLabel?.font.withSize(17)
    }
    
}
