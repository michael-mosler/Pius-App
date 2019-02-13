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
    @IBOutlet weak var evaText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class EvaTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "date") as! EvaTableSectionHeader;
        cell.date.text = "Freitag, 15.02.2019";
        return cell as UIView;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eva") as! EvaTableContentTableViewCell;
        cell.course.text = "M LK1";
        cell.evaText.text = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sine";
        return cell;
    }
}
