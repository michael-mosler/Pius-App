//
//  ExpandableHeaderView.swift
//  Pius-App
//
//  Created by Michael on 11.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

protocol ExpandableHeaderViewDelegate {
    func toggleSection(header: ExpandableHeaderView, section: Int);
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    var delegate: ExpandableHeaderViewDelegate?;
    var section: Int!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier);
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)));
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
        let cell = gestureRecognizer.view as! ExpandableHeaderView;
        delegate?.toggleSection(header: self, section: cell.section);
    }
    
    func customInit(title: String, userInteractionEnabled: Bool = true, section: Int, delegate: ExpandableHeaderViewDelegate) {
        self.textLabel?.text = title;
        self.section = section;
        self.delegate = delegate;
        self.isUserInteractionEnabled = userInteractionEnabled;
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();

        if (isUserInteractionEnabled) {
            contentView.backgroundColor = UIColor.init(red: 0.337, green: 0.631, blue: 0.824, alpha: 1.0);
        } else {
            contentView.backgroundColor = UIColor.lightGray;

        }
        textLabel?.textColor = UIColor.white;
    }
}
