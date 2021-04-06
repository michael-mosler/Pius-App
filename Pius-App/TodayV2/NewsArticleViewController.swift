//
//  NewsArticlePopoverViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 01.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit
import WebKit

protocol ModalDismissDelegate {
    func hasDismissed()
}

/// Shows a webview with page content. On link navigation browser choice setting
/// is checked by webview.
class NewsArticleViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var webView: NewsWebView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var segueData: Any?
    var delegate: ModalDismissDelegate?
    
    /// Dismiss view controller
    /// - Parameter sender: Control that has sent dismiss.
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
        delegate?.hasDismissed()
    }
    
    /// Swipe down to close webview.
    /// - Parameter sender: Control that has sent pan gesture.
    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if webView.scrollView.contentOffset.y <= -110 {
                dismiss(animated: true)
                delegate?.hasDismissed()
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
