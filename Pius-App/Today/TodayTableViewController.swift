//
//  TodayTableViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 22.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class TodayTableViewController: UITableViewController {
    @IBOutlet var tablewView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var newsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();

        // Make background of status opaque; by default status bar is presented transparently.
        // When scrolling we do not want to shine through table content as text gets unreadable
        // in this case.
        let view = UIView();
        view.backgroundColor = .white;
        view.frame = UIApplication.shared.statusBarFrame;
        navigationController!.view.addSubview(view);
        
        headerCellContent();
        
        newsView.layer.borderColor = UIColor.black.cgColor;
        newsView.layer.borderWidth = 1;
        newsView.layer.shadowColor = UIColor.black.cgColor;
        newsView.layer.shadowOffset = CGSize(width: 1, height: 3);
        newsView.layer.shadowOpacity = 0.7;
        newsView.layer.shadowRadius = 4;
    }

    /*
     * ====================================================
     *                  Table Data
     * ====================================================
     */

    private func headerCellContent() {
        let defaultSystemFont = UIFont.systemFont(ofSize: 11);
        //let largeTitleFont = UIFont.preferredFont(forTextStyle: .largeTitle);
        let largeTitleFont = UIFont.systemFont(ofSize: 36, weight: .bold);
        let dateFormatter = DateFormatter();
        let date = Date();
        
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE, d. MMMM");
        let dateString = NSMutableAttributedString(string: dateFormatter.string(from: date), attributes: [NSAttributedString.Key.font: defaultSystemFont]);
        let todayString = NSMutableAttributedString(string: "Heute", attributes: [NSAttributedString.Key.font: largeTitleFont]);
        dateString.append(NSMutableAttributedString(string: "\n"));
        dateString.append(todayString);
        headerLabel.attributedText = dateString;
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0;
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0;
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
