//
//  DateListViewController.swift
//  Pius-App
//
//  Created by Michael on 24.04.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WebKit

class DateListViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var offlineText: UILabel!
    
    // Checks reachability of news page.
    let reachabilityChecker = ReachabilityChecker(forName: "http://pius-gymnasium.de");
    
    // Stop activity indicator when news page has been loaded.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewActivityIndicator.stopAnimating();
    }
    
    // Load Termine page from Pius home page.
    private func loadWebView() {
        var pageRequest: URLRequest;
        
        if (reachabilityChecker.isNetworkReachable()) {
            offlineText.isHidden = true;

            // Pius Gymnasium Home Page will be shown on landing page.
            let baseUrl = URL(string: "http://pius-gymnasium.de/internes/a/termine.html");
            pageRequest = URLRequest(url: baseUrl!);

            webViewActivityIndicator.startAnimating();
        } else {
            offlineText.isHidden = false;

            let baseUrl = URL(string: "about:blank");
            pageRequest = URLRequest(url: baseUrl!);
        }
        
        webView.load(pageRequest);
    }

    override func viewDidLoad() {
        super.viewDidLoad();
        webView.navigationDelegate = self;
        loadWebView();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
