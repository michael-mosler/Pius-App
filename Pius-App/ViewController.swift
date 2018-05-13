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
    @IBOutlet var webViewTabGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var swipeLeftGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var panRightGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var vertretungsplanItem: UIButton!
    @IBOutlet weak var dashboardItem: UIButton!
    @IBOutlet weak var webViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var offlineText: UILabel!
    
    // Open Safari with Pius home page when menu item is selected.
    @IBAction func gotoHomePageAction(_ sender: Any) {
        UIApplication.shared.open(NSURL(string:"http://pius-gymnasium.de/")! as URL)
    }
    
    // Indicates if sidebar menu is open or closed.
    var menuIsOpen : Bool = false;
    
    // User defaults access.
    let config = Config();

    // Checks reachability of news page.
    let reachabilityChecker = ReachabilityChecker(forName: "https://pius-gateway.eu-de.mybluemix.net");
    
    // Becomes true if webview has been loaded.
    var webViewLoaded: Bool = false;
    
    @IBAction func unwindFromLaunchScreen(unwindSegue: UIStoryboardSegue) {
        
    }

    // If not authenticated and is launched show login screen.
    private func showLaunchScreen() {
        let _: Bool = config.userDefaults.bool(forKey: "hideLaunchScreen");
        config.userDefaults.set(true, forKey: "hideLaunchScreen");
        
        if (!config.userDefaults.bool(forKey: "authenticated")) {
            if let launchScreenViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LaunchScreen") as UIViewController? {
                if let navigationController = navigationController {
                    navigationController.pushViewController(launchScreenViewController, animated: false);
                }
            }
        }
    }

    // Stop activity indicator when news page has been loaded.
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewActivityIndicator.stopAnimating();
    }

    // Hide sidebar menu.
    private func showSidebarMenu(with percentage: CGFloat = 0) {
        menuIsOpen = percentage >= 1;

        menuLeadingConstraint.constant = -180 + min(percentage, 1) * 180;
        webView.isUserInteractionEnabled = true;
        visualEffectView.isHidden = true;
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        });
        
        // Dashboard item is disabled if no grade is configured.
        let authenticated = config.userDefaults.bool(forKey: "authenticated");
        dashboardItem.isEnabled = (config.userDefaults.integer(forKey: "selectedGradeRow") != 0) && authenticated;
        vertretungsplanItem.isEnabled = authenticated;
        
        // When sidebar menu is open disable web view and blur background.
        webView.isUserInteractionEnabled = percentage == 0;
        visualEffectView.isHidden = percentage == 0;
    }
    
    // Whenever user tabs outside of our sidebar menu it gets hidden.
    @IBAction func tabAction(_ sender: Any) {
        showSidebarMenu(with: 0);
    }

    // Swipe left to hide sidebar menu.
    @IBAction func swipeLeftAction(_ sender: Any) {
        showSidebarMenu(with: 0);
    }
    
    // Pan right to show sidebar menu.
    @IBAction func panRightAction(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let percentage = max(panGestureRecognizer.translation(in: webView).x, 0) / webView.frame.width;
        switch(panRightGestureRecognizer.state) {
        case .began:
            showSidebarMenu(with: 0);
        case .changed:
            showSidebarMenu(with: 4 * percentage);
        case .cancelled:
            showSidebarMenu(with: 0);
        case .ended:
            if (percentage >= 0.25) {
                showSidebarMenu(with: 1);
            } else {
                showSidebarMenu(with: 0);
            }
        default:
            print("Unknown pan gesture state");
        }
    }

    // We want to receive tabs on our own gesture recognizers.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true;
    }

    // Allow tabs on more than one gesture recognizer. This allows us to hide
    // sidebar menu when user tabs on web view.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }

    // Add Pius logo as navigation bar title on initial view.
    func addNavBarLogo() {
        guard let navigationController = navigationController else { return };
        
        let image = UIImage(named: "pius-app-transparent.png")!;
        let imageView = UIImageView(image: image);
        
        let bannerWidth = navigationController.navigationBar.frame.size.width;
        let bannerHeight = navigationController.navigationBar.frame.size.height;
        
        let bannerX = bannerWidth / 2 - image.size.width / 2;
        let bannerY = bannerHeight / 2 - image.size.height / 2;
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: image.size.width, height: image.size.height);
        imageView.contentMode = .scaleAspectFit;

        navigationItem.titleView = imageView;
    }
    
    // Load news page from Pius home page but proxied by our Pius Gateway.
    // This returns an optimized version of the news page.
    private func loadWebView() {
        var pageRequest: URLRequest;
        
        if (reachabilityChecker.isNetworkReachable()) {
            offlineText.isHidden = true;

            // Pius Gymnasium Home Page will be shown on landing page.
            let baseUrl = URL(string: "https://pius-gateway.eu-de.mybluemix.net/news");
            pageRequest = URLRequest(url: baseUrl!);
            webViewLoaded = true;
        } else {
            offlineText.isHidden = false;

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

    // Called whenever view has been loaded. Initialises all our stuff.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLaunchScreen();

        // Configure tab gesture recognizer.
        webViewTabGestureRecognizer.numberOfTapsRequired = 1;
        webViewTabGestureRecognizer.delegate = self;
        
        // Set color of navigation bar.
        navigationController?.navigationBar.barTintColor = config.colorPiusBlue;
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white];
        
        addNavBarLogo();
        
        // Set menu shadow.
        menuView.layer.shadowOpacity = 1;
        menuView.layer.shadowRadius = 6;
        
        webView.navigationDelegate = self;
        
        // Enable refresh in WebKit View.
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControlEvents.valueChanged);
        webView.scrollView.addSubview(refreshControl);
        
        // Load web view on initial view. Activity indicator is started on
        // initial load only. Later on refresh indicator is active instead.
        webViewActivityIndicator.startAnimating();
        loadWebView();
        
        visualEffectView.addGestureRecognizer(webViewTabGestureRecognizer);
        visualEffectView.addGestureRecognizer(swipeLeftGestureRecognizer);
        menuView.addGestureRecognizer(swipeLeftGestureRecognizer);
        webView.addGestureRecognizer(panRightGestureRecognizer);
    }

    // Hide the sidebar menu whenever a selection is made.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        showSidebarMenu(with: 0);
    }

    // Toggle sidebar menu visibility. When menu is open web view will
    // be blurred and disabled. This allows user to close sidebar by
    // tabbing on background.
    @IBAction func menuButtonAction(_ sender: Any) {
        if (menuIsOpen) {
            showSidebarMenu(with: 0);
        } else {
            showSidebarMenu(with: 1);
        }
     }
}

