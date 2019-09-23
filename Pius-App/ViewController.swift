//
//  ViewController.swift
//  Pius-App
//
//  Created by Michael on 25.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIGestureRecognizerDelegate, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var webViewActivityIndicator: UIActivityIndicatorView!
    
    // Becomes true if webview has been loaded.
    var webViewLoaded: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let view = UIView();
        view.backgroundColor = .white;
        view.frame = UIApplication.shared.statusBarFrame;
                
        // Enable refresh in WebKit View.
        let refreshControl = UIRefreshControl();
        refreshControl.tintColor = UIColor.black;
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControl.Event.valueChanged);
        webView.scrollView.addSubview(refreshControl);
        
        // Load web view on initial view. Activity indicator is started on
        // initial load only. Later on refresh indicator is active instead.
        webView.navigationDelegate = self;        
        webViewActivityIndicator.startAnimating();
        loadWebView();
    }

    /*
     * =====================================================================
     *                          Wewb View
     * =====================================================================
     */

    // Stop activity indicator when news page has been loaded.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewActivityIndicator.stopAnimating();
    }

    // Load news page from Pius home page but proxied by our Pius Gateway.
    // This returns an optimized version of the news page.
    private func loadWebView() {
        var pageRequest: URLRequest;
        let reachability = Reachability();

        if reachability?.connection != Reachability.Connection.none {
            let baseUrl = URL(string: "\(AppDefaults.baseUrl)/news");
            pageRequest = URLRequest(url: baseUrl!);
            webViewLoaded = true;
        } else {
            let baseUrl = URL(string: "about:blank");
            pageRequest = URLRequest(url: baseUrl!);
            webViewLoaded = false;
        }

        webView.load(pageRequest);
    }
    
    // Refresh WebView.
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        sender.endRefreshing();
        loadWebView();
    }
}
