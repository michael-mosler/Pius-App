//
//  MetaDataTableCellTableViewCell.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 24.10.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class MetaDataTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        collectionView.delegate = self;
        collectionView.dataSource = self;

        let screenWidth = UIScreen.main.bounds.width;
        flowLayout.itemSize = CGSize(width: screenWidth, height: flowLayout.itemSize.height);
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "metaDataCollectionViewCell", for: indexPath) as! MetaDataCollectionViewCell;
        return cell;
    }
}
