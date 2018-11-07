//
//  DateListCollectionViewFlowLayout.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 07.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class DateListCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true;
    }
}
