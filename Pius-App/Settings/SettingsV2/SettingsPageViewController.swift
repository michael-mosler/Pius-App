//
//  SettingsPageViewController.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 23.12.20.
//  Copyright © 2020 Felix Krings. All rights reserved.
//

import UIKit

protocol EmbeddedSettingsViewController {
    var searchController: UISearchController? { get }
}

class SettingsPageViewController: UIPageViewController, UIPageViewControllerDelegate {
    private lazy var settingsViewControllers: [UIViewController] = {
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Preferences"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Staff"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "About")
        ]
    }()
    
    private lazy var titles: [String] = {
        return [
            "Einstellungen",
            "Kollegium",
            "Über Pius-App"
        ]
    }()

    private var myTabBarItem: UITabBarItem?
    
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
    
    /// Set up navigation item for display of view controller with given index.
    /// If view controller supports searching then searchbar is shown in
    /// navigation item.
    /// - Parameter index: Index of current view controller.
    private func setupNavigationItem(_ index: Array<UIViewController>.Index) {
        if #available(iOS 13, *) {
            navigationItem.searchController?.dismiss(animated: false, completion: {
                self.navigationItem.searchController = nil
            })
        } else {
            navigationItem.searchController = nil
        }

        if let activeViewController = settingsViewControllers[index] as? EmbeddedSettingsViewController {
            navigationItem.searchController = activeViewController.searchController
        }
        
        settingsViewControllers[index].title = titles[index]
        title = titles[index]
    }

    /// After view controller has been loaded set up page control.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remember linked tabbar item.
        myTabBarItem = tabBarController?.tabBar.selectedItem
        
        delegate = self
        dataSource = self

        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false

        if let initialViewController = settingsViewControllers.first {
            setViewControllers([initialViewController], direction: .forward, animated: true, completion: nil)
            setupNavigationItem(0)
        }
        
        setupPageControl()
    }
    
    /// Restore tabbar item title when view disappears.
    /// - Parameter animated: Passed to super class method call.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        myTabBarItem?.title = "Mehr"
    }
    
    /// Sets page title when page transition has completed.
    /// - Parameters:
    ///   - pageViewController: Page view controller for which transition has completed
    ///   - finished: Animation finished indicator
    ///   - previousViewControllers: View controller transition has started from
    ///   - completed: Transition completed indicator
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentViewController = pageViewController.viewControllers?.first,
              let index = settingsViewControllers.firstIndex(of: currentViewController)
        else { return }
        
        setupNavigationItem(index)
    }
}

extension SettingsPageViewController: UIPageViewControllerDataSource {
    
    /// Returns view controller to be shown before given view controller
    /// - Parameters:
    ///   - pageViewController: Page view controller requesting info
    ///   - viewController: Reference view controller
    /// - Returns: Before view controller
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = settingsViewControllers.firstIndex(of: viewController) else { return nil }

        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        
        return settingsViewControllers[previousIndex]
    }
    
    /// Returns view controller to be shown before given view controller
    /// - Parameters:
    ///   - pageViewController: Page view controller requesting info
    ///   - viewController: Reference view controller
    /// - Returns: After view controller
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = settingsViewControllers.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = index + 1
        let count = settingsViewControllers.count
        
        guard count > nextIndex else { return nil }
        
        return settingsViewControllers[nextIndex]
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
