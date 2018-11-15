//
//  LaunchScreenViewController.swift
//  Pius-App
//
//  Created by Michael on 13.05.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class OnboardingViewController: UITableViewController {
    @IBAction func startAppAction(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }

    /*
     * ==================================================
     *                  Table View
     * ==================================================
     */
    
    @IBOutlet weak var startAppButton: UIButton!
    private let rowHeights: [CGFloat] = [110, 44, 100, 145, 100];
    private let offset: CGFloat = 32;
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row >= 5 else { return rowHeights[indexPath.row]; };

        if indexPath.row == 5 {
            let totalHeight = rowHeights.reduce(0, { x, y in x + y});
            return max(tableView.frame.height - totalHeight - startAppButton.frame.height - offset, startAppButton.frame.height);
        } else {
            return 0;
        }
    }
}
