//
//  DetailsCellTableViewCell.swift
//  Pius-App
//
//  Created by Michael on 19.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DetailsCellTableViewCell: UITableViewCell {
    // The itemIndex in Vertretungsplan items this cell is displaying.
    var itemIndex: Int?;
    
    // The collection view that is used to display details for this cell.
    var collectionView: UICollectionView?;
}
