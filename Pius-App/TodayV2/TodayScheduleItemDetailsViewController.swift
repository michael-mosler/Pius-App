//
//  TodayScheduleItemDetailsViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 26.09.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class TodayScheduleItemDetailsViewController: UIViewController, UIGestureRecognizerDelegate {

    var delegate: ModalDismissDelegate?
    var segueData: Any?
    var scheduleItem: ScheduleItem?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var teacherLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var evaLabel: UILabel!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    var lastTranslation: CGPoint?
    var oldCenter: CGPoint?
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.hasDismissed()
    }
    
    private func setContent() {
        guard let scheduleItem = scheduleItem, let details = scheduleItem.substitutionDetails else { return }
        let courseText = StringHelper.replaceHtmlEntities(input: details[2])
        let roomText = StringHelper.replaceHtmlEntities(input: details[3])
        let commentText: String = StringHelper.replaceHtmlEntities(input: details[6])
        
        headerLabel.attributedText = FormatHelper.roomText(room: courseText)
        typeLabel.text = StringHelper.replaceHtmlEntities(input: details[1])
        roomLabel.attributedText = FormatHelper.roomText(room: roomText)
        teacherLabel.text = details[4]
        
        if commentText.count > 0 {
            commentLabel.text = commentText
        } else {
            commentLabel.text = nil
        }
        
        if details.count >= 8 {
           let evaText = StringHelper.replaceHtmlEntities(input: details[7])
           evaLabel.text = evaText
        } else {
           evaLabel.attributedText = nil
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.borderColor = Config.colorPiusBlue.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        contentView.addGestureRecognizer(panGestureRecognizer)
        
        scheduleItem = segueData as? ScheduleItem
        setContent()
    }

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
                delegate?.hasDismissed()
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
