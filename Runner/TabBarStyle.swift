//
//  TabBarStyle.swift
//  Runner
//
//  Created by Bodang on 19/01/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit

//This extension customise the NavigationBar
extension UITabBar {
    class func setupStyle() {
        let barItem = UITabBarItem.appearance()
        barItem.setTitleTextAttributes([NSForegroundColorAttributeName : UIColor(red: 212 / 255.0, green: 25 / 255.0, blue: 38 / 255.0, alpha: 1.0)], for: .selected)
        let bar = UITabBar.appearance()
        bar.tintColor = UIColor(red: 212 / 255.0, green: 25 / 255.0, blue: 38 / 255.0, alpha: 1.0)
    }
}
