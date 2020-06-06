//
//  VertretungsplanDetailViewController.swift
//  Pius-App
//
//  Created by Michael on 16.03.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Container class for EVA text label in Substitution Schedule Details view.
 */
class SubstitutionScheduleDetailsEvaTableCell: EvaTableCell {
    @IBOutlet weak var evaTextLabelOutlet: UITextView!
    override var evaTextLabel: UITextView { return evaTextLabelOutlet }
}

class VertretungsplanDetailViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let rowsPerItem = 5
    
    public var gradeItem: GradeItem?
    public var date: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = gradeItem!.grade
        dateLabel.text = date

        detailsTableView.delegate = self
        detailsTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsPerItem * (gradeItem?.vertretungsplanItems.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemIndex: Int = indexPath.row / rowsPerItem

        switch indexPath.row % rowsPerItem {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "course")!
            let grade: String! = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][2])
            let lesson: String! = (gradeItem?.vertretungsplanItems[itemIndex][0])!

            if (grade != "") {
                cell.textLabel?.text = String(format: "Fach/Kurs: %@, %@. Stunde", grade, lesson)
            } else {
                cell.textLabel?.text! = String(format: "%@. Stunde", lesson)
            }
            return cell
        case 1:
            let cell = detailsTableView.dequeueReusableCell(withIdentifier: "details")!
            // This is the itemIndex this cell is know displaying.
            (cell as! DetailsCellTableViewCell).itemIndex = itemIndex
            
            // Reload content for this cell when it had already been used.
            (cell as! DetailsCellTableViewCell).collectionView?.reloadData()
            return cell
        case 2:
            let cell = detailsTableView.dequeueReusableCell(withIdentifier: "comment")!
            let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6])
            cell.textLabel?.text = text
            return cell
        case 3:
            let cell = detailsTableView.dequeueReusableCell(withIdentifier: "eva") as! SubstitutionScheduleDetailsEvaTableCell
            if (gradeItem?.vertretungsplanItems[itemIndex].count == 8) {
                let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][7])
                cell.evaTextLabel.text = text
            }
            return cell
        default:
            let cell = detailsTableView.dequeueReusableCell(withIdentifier: "spacer")!
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row % rowsPerItem {
        case 0: return tableView.rowHeight
        case 1: return tableView.rowHeight
        case 2:
            let itemIndex: Int = indexPath.row / rowsPerItem
            let text = StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][6])
            return (text == "") ? 0 : tableView.rowHeight
        case 3:
            let itemIndex: Int = indexPath.row / rowsPerItem
            return ((gradeItem?.vertretungsplanItems[itemIndex].count)! < 8) ? 0 : UITableView.automaticDimension
        default:
            // Spacer is shown only if there is a EVA text.
            let itemIndex: Int = indexPath.row / rowsPerItem
            return ((gradeItem?.vertretungsplanItems[itemIndex].count)! < 8) ? 0 : 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    // Compute collection view cell width.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let defaultWidth = 100
        let width: Int
        
        switch indexPath.item {
            case 0: width = IOSHelper.screenWidth - 2 * defaultWidth - 32
            case 1: width = defaultWidth
            case 2: width = defaultWidth
            default: width = defaultWidth
        }

        return CGSize(width: width, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detail", for: indexPath) as! DetailCollectionViewCell
        
        // The cell this collection view is in knows about the item index we need to display.
        let detailsCellTableViewCell = collectionView.superview?.superview as! DetailsCellTableViewCell
        let itemIndex = detailsCellTableViewCell.itemIndex!

        // We also need to tell the cell which collection view it is working with.
        detailsCellTableViewCell.collectionView = collectionView
        
        switch indexPath.item {
        case 0:
            // Type
            cell.label.attributedText = NSAttributedString(string: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][1]))
        case 1:
            // Room
            cell.label.attributedText = FormatHelper.roomText(room: StringHelper.replaceHtmlEntities(input: gradeItem?.vertretungsplanItems[itemIndex][3]))
        default:
            // Teachers
            cell.label.attributedText = FormatHelper.teacherText(oldTeacher: (gradeItem?.vertretungsplanItems[itemIndex][5]), newTeacher: gradeItem?.vertretungsplanItems[itemIndex][4])
            cell.label.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressSelector)))
        }

        return cell
    }
    
    /**
     * When user taps on teacher label this action method shows info popup
     * for teacher.
     */
    @objc func longPressSelector(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let substitutionLabel = gestureRecognizer.view as? UILabel else { return }
        guard let shortCutName = substitutionLabel.attributedText?.string.trimmingCharacters(in: .whitespaces) else { return }
        
        let staffInfoPopoverController = StaffInfoPopoverController(withShortcutName: shortCutName, onView: substitutionLabel, permittedArrowDirections: .any)
        staffInfoPopoverController.present(inViewController: self)
    }
}
