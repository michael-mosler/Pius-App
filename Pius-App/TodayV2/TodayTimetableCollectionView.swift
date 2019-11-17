//
//  TodayTimetableCollectionView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 25.08.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayItemCollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
    
    override var contentSize: CGSize {
        didSet{
            invalidateIntrinsicContentSize()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !self.bounds.size.equalTo(self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }

    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
    }
}

class TodayTimetableCollectionView: UICollectionView, UICollectionViewDelegate {
    override func awakeFromNib() {
        super.awakeFromNib()
        dataSource = (TodayV2TableViewController.shared.dataSource(forType: .timetable) as! TodayTimetableDataSource<TodayTimetableItemCell>).collectionViewDataSource
    }
}
