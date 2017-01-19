//
//  NavgationBarStyle.swift
//  Runner
//
//  Created by Bodang on 19/01/2017.
//  Copyright © 2017 Bodang. All rights reserved.
//

import UIKit

extension UINavigationBar {
    class func setupStyle() {
        let bar = UINavigationBar.appearance()
        bar.tintColor = UIColor.white
        bar.barTintColor = UIColor(red: 212 / 255.0, green: 25 / 255.0, blue: 38 / 255.0, alpha: 1.0)
        let attr = [
            NSForegroundColorAttributeName : UIColor.white
        ]
        bar.titleTextAttributes = attr
        bar.isTranslucent = false
    }

}
