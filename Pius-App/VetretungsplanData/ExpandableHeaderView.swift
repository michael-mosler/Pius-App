//
//  ExpandableHeaderView.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

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
        NSLog("init(coder:) has not been implemented")
    }
    
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView
        expanded = !expanded
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    func customInit(
        userInteractionEnabled: Bool = true, section: Int, expanded: Bool = true,
        delegate: ExpandableHeaderViewDelegate) {
        
        guard !isInitialized else { return }
        self.isInitialized = true
        self.section = section
        self.expanded = expanded
        self.delegate = delegate
        self.isUserInteractionEnabled = userInteractionEnabled
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if (isUserInteractionEnabled) {
            contentView.backgroundColor = UIColor(named: "piusBlue")
        } else {
            contentView.backgroundColor = UIColor.lightGray

        }
        textLabel?.textColor = UIColor.white
        textLabel?.font = textLabel?.font.withSize(17)
    }
}
