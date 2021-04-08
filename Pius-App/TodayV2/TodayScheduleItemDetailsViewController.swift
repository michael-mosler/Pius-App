//
//  TodayScheduleItemDetailsViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 26.09.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

/**
 * Substitution overlay: Navigation is from timetable in Today View when tapping on a
 * substituted lesson.
 */
class TodayScheduleItemDetailsViewController: UIViewController, UIGestureRecognizerDelegate {

    var segueData: Any?
    var scheduleItem: ScheduleItem?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var evaLabelContainer: UIView!
    @IBOutlet weak var evaLabel: UITextView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    var lastTranslation: CGPoint?
    var oldCenter: CGPoint?
    
    /**
     * We prefer to hide status bar as otherwise it will overlap
     * close button on devices with a notch.
     */
    override var prefersStatusBarHidden: Bool {
        return true
    }

    /**
     * Tap close button X to close overlay.
     */
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /**
     * Sets content of detail substitution view when navigating from timetable
     * to substitution overlay.
     */
    private func setContent() {
        guard let scheduleItem = scheduleItem, let details = scheduleItem.substitutionDetails else { return }
        let lessonText = details[0];
        let courseText = StringHelper.replaceHtmlEntities(input: details[2])
        let roomText = StringHelper.replaceHtmlEntities(input: details[3])
        let commentText: String = StringHelper.replaceHtmlEntities(input: details[6])
        
        if let courseText = courseText, courseText != ""  {
            let attributedText = NSMutableAttributedString(string: "Fach/Kurs: ")
            attributedText.append(NSAttributedString(string: courseText))
            attributedText.append(NSAttributedString(string: ", "))
            attributedText.append(NSAttributedString(string: lessonText))
            attributedText.append(NSAttributedString(string: ". Stunde"))
            headerLabel.attributedText = attributedText
        } else {
            headerLabel.attributedText = NSAttributedString(string: String(format: "%@. Stunde", lessonText))
        }
        typeLabel.text = StringHelper.replaceHtmlEntities(input: details[1])
        roomLabel.attributedText = FormatHelper.roomText(room: roomText)
        teacherLabel.text = StringHelper.replaceHtmlEntities(input: details[4])
        
        if commentText.count > 0 {
            commentLabel.text = commentText
        } else {
            commentLabel.text = nil
        }
        
        if details.count >= 8 {
            let evaText = StringHelper.replaceHtmlEntities(input: details[7])
            evaLabelContainer.isHidden = false
            evaLabel.text = evaText
            evaLabel.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
            evaLabel.textContainer.lineFragmentPadding = 0
            commentBottomConstraint.constant = 0
        } else {
            evaLabelContainer.isHidden = true
            evaLabel.text = nil
            
            // For layout reasons, if there is no EVA text add some
            // extra space to bottom as otherwise comment is very close
            // to view border.
            commentBottomConstraint.constant = 4
        }
        
        if let bgColor = scheduleItem.color {
            headerView.backgroundColor = bgColor
        }
    }
    
    /// Initialize schedule item details overlay.
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1.5
        contentView.layer.borderColor = UIColor(named: "piusBlue")?.cgColor
        contentView.layer.masksToBounds = true
        
        contentView.addGestureRecognizer(panGestureRecognizer)
        
        scheduleItem = segueData as? ScheduleItem
        setContent()
    }

    /**
     * Close by panning down.
     */
    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            lastTranslation = sender.translation(in: contentView)
            oldCenter = contentView.center
        }
        
        if sender.state == .changed {
            let translation = sender.translation(in: contentView)
            contentView.center = CGPoint(x: contentView.center.x, y: contentView.center.y + translation.y - lastTranslation!.y)
            lastTranslation = translation

            if translation.y >= 110 {
                dismiss(animated: true)
            }
        }

        if sender.state == .ended {
            let translation = sender.translation(in: contentView)
            if translation.y < 110 {
                UIView.animate(withDuration: 0.25, animations: {
                    self.contentView.center = self.oldCenter!
                })
            }
        }
    }
    
    /// Allow simultaneous gestures.
    /// - Parameters:
    ///   - gestureRecognizer: Primary gesture recognizer
    ///   - otherGestureRecognizer: Secondary gesture recognizer requesting simultaneous gesture.
    /// - Returns: Returns always true
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
