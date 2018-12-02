//
//  NewsArticlePopoverViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 01.12.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit;
import WebKit;

class NewsArticleViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var urlToShow: URL?;
    var delegate: ModalDismissDelegate?;
    
    private func dismissView() {
        dismiss(animated: true, completion: {
            guard self.delegate != nil else { return; }
            self.delegate?.hasDismissed();
        });
    }

    @IBAction func dismiss(_ sender: Any) {
        dismissView();
    }

    @IBAction func panGestureAction(_ sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            if webView.scrollView.contentOffset.y <= -110 {
                dismissView();
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }

    override func viewDidLoad() {
        var pageRequest: URLRequest;
        let reachability = Reachability();
        
        // panGestureRecognizer.delegate = self;
        view.addGestureRecognizer(panGestureRecognizer);
        
        if reachability?.connection != .none, let urlToShow = self.urlToShow {
            pageRequest = URLRequest(url: urlToShow);
        } else {
            let baseUrl = URL(string: "about:blank");
            pageRequest = URLRequest(url: baseUrl!);
        }
        
        webView.load(pageRequest);
    }
}
