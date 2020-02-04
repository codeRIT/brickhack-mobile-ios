//
//  TabViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 2/3/20.
//  Copyright © 2020 codeRIT. All rights reserved.
//

import UIKit
import Pageboy
import Tabman


class TabViewController: TabmanViewController, PageboyViewControllerDataSource, TMBarDataSource {

    var currentUser: User!
    private var viewControllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set PageboyViewControllerDataSource
        dataSource = self

        // Instantiate our view controller from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Even though delegate methods are polymorphic,
        // we need cast to properly set the user data.
        let eventsVC = storyboard.instantiateViewController(withIdentifier: "eventsVC") as! EventsViewController
        let resourcesVC = storyboard.instantiateViewController(withIdentifier: "resourcesVC") as! ResourcesViewController

        // Pass our user object forward
        eventsVC.currentUser = self.currentUser
        resourcesVC.currentUser = self.currentUser

        self.viewControllers.append(eventsVC)
        self.viewControllers.append(resourcesVC)

        self.reloadData()

        // Create bar
        // @TODO: Dark Mode
        let bar = TMBar.LineBar()
        bar.layout.contentInset.top = 30.0
        bar.layout.transitionStyle = .progressive
        bar.backgroundColor = .white
        bar.indicator.cornerStyle = .rounded
        if self.traitCollection.userInterfaceStyle == .dark {
            bar.indicator.tintColor = UIColor.init(named: "quadColor")
        } else {
            bar.indicator.tintColor = UIColor.init(named: "tertiaryColor")
        }


        // Add to view
        self.addBar(bar, dataSource: self, at: .top)

    }


    // MARK: PageboyViewControllerSource

    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return viewControllers.count
    }

    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }

    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .first
    }

    // MARK: TMBarDataSource
    func barItem(for bar: TMBar, at index: Int) -> TMBarItemable {
        print("indexed at \(index)")
        if index == 0 {
            return TMBarItem(title: "Schedule")
        } else if index == 2 {
            return TMBarItem(title: "Resources")
        } else {
            return TMBarItem(title: "Unknown")
        }
    }
}


