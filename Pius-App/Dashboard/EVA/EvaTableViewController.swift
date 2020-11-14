//
//  EvaViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 02.02.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import UIKit

class EvaTableSectionHeader: UITableViewCell {
    @IBOutlet weak var date: UILabel!
}

class EvaTableContentTableViewCell: UITableViewCell {
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var evaText: UITextView!
    @IBOutlet weak var evaTextHeightConstraint: NSLayoutConstraint!
    var uuid: String?
}

class EvaTableViewController: UITableViewController {
    private var evaDoc: EvaDoc?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let evaLoader = EvaLoader(grade: AppDefaults.gradeSetting, courseList: AppDefaults.courseList ?? [])
        evaLoader.load(doUpdate)
    }

    func doUpdate(evaDoc: EvaDoc?, online: Bool) {
        if let evaDoc = evaDoc {
            self.evaDoc = evaDoc
            
            if evaDoc.evaCollections.count == 0 {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "EVA", message: "Du hast im Moment keine EVA-Aufträge.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                        (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "EVA", message: "Die Daten konnten leider nicht geladen werden.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {
                    (action: UIAlertAction!) in self.navigationController?.popViewController(animated: true)
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.evaDoc?.evaCollections[section].evaItems.count ?? 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.evaDoc?.evaCollections.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "date") as! EvaTableSectionHeader
        cell.date.text = self.evaDoc?.evaCollections[section].date
        return cell as UIView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let evaItems = self.evaDoc?.evaCollections[indexPath.section].evaItems {
            let cell = tableView.dequeueReusableCell(withIdentifier: "eva") as! EvaTableContentTableViewCell
            let evaItem = evaItems[indexPath.row]
            
            cell.course.text = evaItem.course.trimmingCharacters(in: CharacterSet(charactersIn: " "))
            cell.evaText.text = evaItem.evaText
            cell.uuid = evaItem.uuid

            return cell
        } else {
            return UITableViewCell()
        }
    }
}
