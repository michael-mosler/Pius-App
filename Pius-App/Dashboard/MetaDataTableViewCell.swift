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
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var tickerText: String?;
    private var additionalText: String?;
    private var cells: [MetaDataCollectionViewCell?] = [nil, nil];
    
    override func awakeFromNib() {
        super.awakeFromNib();
        collectionView.delegate = self;
        collectionView.dataSource = self;

        flowLayout.itemSize = CGSize(width: CGFloat(IOSHelper.screenWidth), height: flowLayout.itemSize.height);
        pageControl.numberOfPages = 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageControl.numberOfPages;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.row < 2 else { return UICollectionViewCell() }
        
        cells[indexPath.row] = collectionView.dequeueReusableCell(withReuseIdentifier: "metaDataCollectionViewCell", for: indexPath) as? MetaDataCollectionViewCell;
        setCellContent();
        return cells[indexPath.row]!;
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = round(scrollView.contentOffset.x / CGFloat(IOSHelper.screenWidth));
        pageControl.currentPage = Int(currentPage);
    }
    
    private func setCellContent() {
        if let cell = cells[0] {
            cell.metaDataTextLabel.text = tickerText;
        }
        
        if let cell = cells[1] {
            cell.metaDataTextLabel.text = additionalText;
        }
    }
    
    func setContent(tickerText: String!, additionalText: String!) {
        self.tickerText = tickerText;
        self.additionalText = additionalText;
        setCellContent();

        pageControl.numberOfPages = (additionalText == "") ? 1 : 2;
        pageControl.currentPage = 0;

        collectionView.reloadData();
        collectionView.contentOffset = CGPoint(x: 0, y: 0);
    }
}
