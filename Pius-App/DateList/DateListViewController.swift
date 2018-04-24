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
    
    // Stop activity indicator when news page has been loaded.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewActivityIndicator.stopAnimating();
    }
    
    // Load Termine page from Pius home page.
    private func loadWebView() {
        // Pius Gymnasium Home Page will be shown on landing page.
        let baseUrl = URL(string: "http://pius-gymnasium.de/internes/a/termine.html");
        
        let homePageRequest = URLRequest(url: baseUrl!);
        webView.load(homePageRequest);
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
