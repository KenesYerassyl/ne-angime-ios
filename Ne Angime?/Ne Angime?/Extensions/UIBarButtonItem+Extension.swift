//
//  UIBarButtonItem+Extension.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 4/11/21.
//

import UIKit

extension UIBarButtonItem {
    static func menuButton(_ target: Any?, action: Selector, imageName: String, size: CGSize, tintColor:UIColor?) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.frame = CGRect(origin: .zero, size: size)
        button.tintColor = tintColor
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        
        return menuBarItem
    }
}
