//
//  CourseCollectionView.swift
//
//  Created by Michael Mosler-Krings on 27.07.19.
//  Copyright © 2019 Michael Mosler-Krings. All rights reserved.
//

import UIKit
import MobileCoreServices

/* ****************************************************************
 * Collection view that holds all subjects for drag action.
 * This class creates a drag item for a single subject as soon
 * as drag action starts.
 * ****************************************************************/
class CourseCollectionView: UICollectionView, TimetableCollectionViewProtocol {
    private let prototypeItems: CourseItemCollection = CourseItemCollection()
    
    override func numberOfItems(inSection section: Int) -> Int {
        return prototypeItems.numberOfItems
    }
    
    func cell(forItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: "prototypeCell", for: indexPath) as! CourseCollectionViewCell
        cell.courseLabel.text = prototypeItems.courseItem(forIndex: indexPath.row).name
        return cell
    }
    
    func dragItem(forIndexPath indexPath: IndexPath) -> [UIDragItem] {
        let prototypeItem = prototypeItems.courseItem(forIndex: indexPath.row)
        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
            let data = (prototypeItem.name == "...") ? "".data(using: .utf8) : prototypeItem.longName.data(using: .utf8)
            completion(data, nil)
            return nil
        }
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}
