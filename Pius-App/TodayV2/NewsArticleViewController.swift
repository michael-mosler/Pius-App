//
//  NewsArticlePopoverViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 01.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WebKit

/// Shows a webview with page content. On link navigation browser choice setting
/// is checked by webview.
class NewsArticleViewController: UIViewController, UIGestureRecognizerDelegate, WebViewDecisionDelegate {
    
    /// Implements WebViewDecisionDelegate decisionHandler() method. It decides if view controller has to dismiss
    /// because user selected Safari to open a web page.
    /// - Parameters:
    ///   - navigationAction: The action that caused navigation
    ///   - navigationActionPolicy: Suggested policy to pass to webViewDecisionHandler.
    ///   - webViewDecisionHandler: The original webview decision handler that must be called in any case.
    func decisionHandler(_ navigationAction: WKNavigationAction, _ navigationActionPolicy: WKNavigationActionPolicy, webViewDecisionHandler: WebViewDecisionHandler) {
        webViewDecisionHandler(navigationActionPolicy)
        
        if navigationAction.navigationType == .other && navigationActionPolicy == .cancel {
            dismiss(animated: false)
        }
    }
    
    @IBOutlet weak var webView: NewsWebView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var segueData: Any?
    
    /// Dismiss view controller
    /// - Parameter sender: Control that has sent dismiss.
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /// Swipe down to close webview.
    /// - Parameter sender: Control that has sent pan gesture.
    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if webView.scrollView.contentOffset.y <= -110 {
                dismiss(animated: true)
            }
        }
    }
    
    /// Allows simultaneous gesture recognition.
    /// - Parameters:
    ///   - gestureRecognizer: Gesture recognizer asking for configuration,
    ///   - otherGestureRecognizer: Second recognizer
    /// - Returns: This function returns always true.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// Initialise view when loaded.
    override func viewDidLoad() {
        var pageRequest: URLRequest
        let reachability = Reachability()
        
        view.addGestureRecognizer(panGestureRecognizer)
        
        if reachability?.connection != Reachability.Connection.none, let urlToShow = self.segueData as? URL {
            pageRequest = URLRequest(url: urlToShow)
        } else {
            let baseUrl = URL(string: "about:blank")
            pageRequest = URLRequest(url: baseUrl!)
        }
        
        webView.containingViewController = self
        webView.load(pageRequest)
    }
}
