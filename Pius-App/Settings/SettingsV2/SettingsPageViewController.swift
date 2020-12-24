//
//  SettingsPageViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 23.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

class SettingsPageViewController: UIPageViewController {
    private(set) lazy var settingsViewControllers: [UIViewController] = {
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Preferences"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "About")
        ]
    }()
    
    /// Sets up page control colors.
    private func setupPageControl() {
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        if #available(iOS 13.0, *) {
            appearance.backgroundColor = UIColor.systemBackground
            view.backgroundColor = UIColor.systemBackground
        } else {
            appearance.backgroundColor = UIColor.white
            view.backgroundColor = UIColor.white
        }
        appearance.pageIndicatorTintColor = UIColor.systemGray
        appearance.currentPageIndicatorTintColor = UIColor(named: "piusBlue")
        appearance.frame.size = CGSize(width: 30, height: 10)
    }
    
    /// After view controller has been loaded set up page control.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        if let initialViewController = settingsViewControllers.first {
            setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
        }
        
        setupPageControl()
    }
    
    /// After sub-views have been layouted size embedded content to match
    /// page control height.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let subViews = view.subviews
        var scrollView: UIScrollView? = nil
        var pageControl: UIPageControl? = nil

        for view in subViews {
            if let _ = view as? UIScrollView {
                scrollView = view as? UIScrollView
            }
            else if let _ = view as? UIPageControl {
                pageControl = view as? UIPageControl
            }
        }

        if (scrollView != nil && pageControl != nil) {
            scrollView?.frame = view.bounds
            view.bringSubviewToFront(pageControl!)
        }
    }
    
    /// Returns the number of pages to be shown.
    /// - Parameter pageViewController: The view controller number of pages is requested for.
    /// - Returns: The number of pages to show
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return settingsViewControllers.count
    }
    
    /// Returns the page number to show first.
    /// - Parameter pageViewController: The view controller start page is requested for.
    /// - Returns: Always 0.
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension SettingsPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = settingsViewControllers.firstIndex(of: viewController) else { return nil }

        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        
        guard settingsViewControllers.count > previousIndex else { return nil }
        
        return settingsViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = settingsViewControllers.firstIndex(of: viewController) else { return nil }

        let nextIndex = index + 1
        let count = settingsViewControllers.count
        guard count != nextIndex else { return nil }
        
        guard count > nextIndex else { return nil }
        
        return settingsViewControllers[nextIndex]
    }
}
