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

class NewsArticleViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var segueData: Any?
    var delegate: ModalDismissDelegate?

    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true)
        delegate?.hasDismissed()
    }

    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if webView.scrollView.contentOffset.y <= -110 {
                dismiss(animated: true)
                delegate?.hasDismissed()
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

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
        
        webView.load(pageRequest)
    }
}
