//
//  MessageCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 06.09.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

/*
 * A simle table message cell which displays one row with a given message
 * in a standard formatting.
 */
class MessageCell: UITableViewCell {

    init(_ message: String) {
        super.init(style: .default, reuseIdentifier: nil)
        isUserInteractionEnabled = true
        textLabel?.textAlignment = .center
        textLabel?.lineBreakMode = .byWordWrapping
        textLabel?.numberOfLines = 0
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        textLabel?.text = message
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
