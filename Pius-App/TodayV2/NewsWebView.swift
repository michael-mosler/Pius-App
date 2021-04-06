//
//  NewsWebView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 06.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit
import WebKit

/// Implementation of webview that integrates browser choice setting.
class NewsWebView: WKWebView, WKNavigationDelegate {
    var containingViewController: UIViewController?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        navigationDelegate = self
    }
    
    /// On link tapped ask user which browser to use for opening of link.
    /// - Parameters:
    ///   - webView: Webview in which navigation occured (always self)
    ///   - navigationAction: The navigation action, only link tapped is evaluated
    ///   - decisionHandler: Callback to send decision to webview.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // User has asked to remember his selection.
        if AppDefaults.rememberBrowserSelection {
            switch AppDefaults.browser {
            case .useInternal:
                decisionHandler(.allow)

            case .useSafari:
                decisionHandler(.cancel)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            // Get users choice and navigate.
            let browserSelection = BrowserSelection(
                parentViewController: containingViewController,
                onSelect: { (url: URL, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) in
                    return { (selection: AppDefaults.BrowserSelection?) in
                        self.openUrl(selection: selection, url: url, decisionHandler: decisionHandler)
                    }
                }(url, decisionHandler))

            browserSelection.choice()
        }
    }
    
    /// OpenURL and send browser selection to webview.
    /// - Parameters:
    ///   - selection: User's selection
    ///   - url: URL to open
    ///   - decisionHandler: Decision handler of webview.
    private func openUrl(selection: AppDefaults.BrowserSelection?, url: URL, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        switch selection {
        case .useInternal:
            decisionHandler(.allow)
        case .useSafari:
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case nil:
            decisionHandler(.cancel)
        }
    }
}
