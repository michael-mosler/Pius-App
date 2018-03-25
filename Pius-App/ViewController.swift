//
//  ViewController.swift
//  Pius-App
//
//  Created by Michael on 25.02.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var webViewTabGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    // Indicates if sidebar menu is open or closed.
    var menuIsOpen : Bool = false;

    // Whenever use tabs outside of our sidebar menu it gets hidden.
    @IBAction func tabAction(_ sender: Any) {
        if (menuIsOpen) {
            menuLeadingConstraint.constant = -180;
            menuIsOpen = false;
            webView.isUserInteractionEnabled = true;
            visualEffectView.isHidden = true;
            
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            });
        }
    }
    
    // We want to receive tabs on our own gesture recognizer.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true;
    }

    // Allow tabs on all more than one gesture recognizer. This allows us to hide
    // sidebar menu when user tabs on web view.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }

    // Add Pius logo as navigation bar title on initial view.
    func addNavBarLogo() {
        let navigationController = self.navigationController!;
        let image = #imageLiteral(resourceName: "pius-logo-transparent");
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
        // Pius Gymnasium Home Page will be shown on landing page.
        let baseUrl = URL(string: "https://pius-gateway.eu-de.mybluemix.net/news");

        let homePageRequest = URLRequest(url: baseUrl!);
        webView.load(homePageRequest);
    }
    
    // Refresh WebView.
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        webView.reload();
        sender.endRefreshing()
    }

    // Called whenever view has been loaded. Initialises all our stuff.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure tab gesture recognizer.
        webViewTabGestureRecognizer.numberOfTapsRequired = 1;
        webViewTabGestureRecognizer.delegate = self;
        
        // Set color of navigation bar.
        navigationController?.navigationBar.barTintColor = UIColor(red:0.337, green:0.631, blue:0.824, alpha:1.0);
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white];
        
        addNavBarLogo();
        
        // Set menu shadow.
        menuView.layer.shadowOpacity = 1;
        menuView.layer.shadowRadius = 6;
        
        // Enable refresh in WebKit View.
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: UIControlEvents.valueChanged);
        webView.scrollView.addSubview(refreshControl);
        
        // Load web view on initial view.
        loadWebView();
        
        visualEffectView.addGestureRecognizer(webViewTabGestureRecognizer);
    }

    // Hide the sidebar menu whenever a selection is made.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        menuLeadingConstraint.constant = -180;
        menuIsOpen = false;
        webView.isUserInteractionEnabled = true;
        visualEffectView.isHidden = true;
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        });
    }

    // Toggle sidebar menu visibility. When menu is open web view will
    // be blurred and disabled. This allows user to close sidebar by
    // tabbing on background.
    @IBAction func menuButtonAction(_ sender: Any) {
        if (menuIsOpen) {
            menuLeadingConstraint.constant = -180;
        } else {
            menuLeadingConstraint.constant = 0;
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })

        menuIsOpen = !menuIsOpen;
        
        // When sidebar menu is open disable web view and blurbackground.
        webView.isUserInteractionEnabled = !menuIsOpen;
        visualEffectView.isHidden = !menuIsOpen;
    }
}

