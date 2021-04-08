//
//  NewsWebView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 06.04.21.
//  Copyright © 2021 Felix Krings. All rights reserved.
//

import UIKit
import WebKit

/// Short hand for WK decision callback.
/// - Parameter navigationActionPolicy : Suggested policy to use.
typealias WebViewDecisionHandler = (_ navigationActionPolicy: WKNavigationActionPolicy) -> Void

/// View controllers that set containingViewController property of NewsWebView must conform
/// to this protocol. Whenver a navigation occurs decisionHandler will be called. It is
/// the parent's responsibility to call webViewDecisionHandler(). If not done app is
/// likely to crash with a protocol error.
protocol WebViewDecisionDelegate: UIViewController {
    
    /// This decision handler is called whenever user has selected a browser to open
    /// a web page and navigation has occured. The implementation has to decide what
    /// to do but finally it must call the given webViewDecisionHandler() in order
    /// to comply to web view protocol.
    /// - Parameters:
    ///   - navigationAction: The action object that caused navigation.
    ///   - navigationActionPolicy: The suggested policy to pass to webViewDecisionHandler()
    ///   - webViewDecisionHandler: The web view view decision handler that must be called.
    func decisionHandler(_ navigationAction: WKNavigationAction, _ navigationActionPolicy: WKNavigationActionPolicy, webViewDecisionHandler: WebViewDecisionHandler) -> Void
}

/// Implementation of webview that integrates browser choice setting.
class NewsWebView: WKWebView, WKNavigationDelegate {

    /// Register parent view controller here. This view controller must comply to protocol
    /// WebViewDecisionDelegate.
    var containingViewController: WebViewDecisionDelegate?
    
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
        guard [.other, .linkActivated].contains(navigationAction.navigationType), let url = navigationAction.request.url else {
            containingViewController?.decisionHandler(navigationAction, .allow, webViewDecisionHandler: decisionHandler)
            return
        }

        // User has asked to remember his selection.
        if AppDefaults.rememberBrowserSelection {
            switch AppDefaults.browser {
            case .useInternal:
                containingViewController?.decisionHandler(navigationAction, .allow, webViewDecisionHandler: decisionHandler)

            case .useSafari:
                containingViewController?.decisionHandler(navigationAction, .cancel, webViewDecisionHandler: decisionHandler)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            // Get users choice and navigate.
            let browserSelection = BrowserSelection(
                parentViewController: containingViewController,
                onSelect: { (navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) in
                    return { (selection: AppDefaults.BrowserSelection?) in
                        self.openUrl(selection: selection, navigationAction: navigationAction, decisionHandler: decisionHandler)
                    }
                }(navigationAction, decisionHandler))

            browserSelection.choice()
        }
    }
    
    /// OpenURL and send browser selection to webview.
    /// - Parameters:
    ///   - selection: User's selection
    ///   - navigationAction: Navigation action that wants to open URL.
    ///   - decisionHandler: Decision handler of webview.
    private func openUrl(selection: AppDefaults.BrowserSelection?, navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy)-> Void) {
        guard let url = navigationAction.request.url else {
            containingViewController?.decisionHandler(navigationAction, .allow, webViewDecisionHandler: decisionHandler)
            return
        }

        switch selection {
        case .useInternal:
            containingViewController?.decisionHandler(navigationAction, .allow, webViewDecisionHandler: decisionHandler)
        case .useSafari:
            containingViewController?.decisionHandler(navigationAction, .cancel, webViewDecisionHandler: decisionHandler)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        case nil:
            containingViewController?.decisionHandler(navigationAction, .cancel, webViewDecisionHandler: decisionHandler)
        }
    }
}
