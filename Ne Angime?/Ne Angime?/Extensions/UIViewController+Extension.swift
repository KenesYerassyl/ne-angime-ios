//
//  UIViewController+Extension.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/14/21.
//

import UIKit

enum BackButtonColor: String {
    case normalDark = "back_icon_dark"
    case normalLight = "back_icon_light"
}

extension UIViewController {
    func addBackButton(withNormalColor: BackButtonColor, didTapBackButton: Selector) {
        let backButton = UIButton()
        view.addSubview(backButton)
        let width = UIImage(named: withNormalColor.rawValue)!.size.width
        let height = UIImage(named: withNormalColor.rawValue)!.size.height
        backButton.snp.makeConstraints { make in
            make.width.equalTo(width * 2)
            make.height.equalTo(height * 2)
            make.top.equalTo(view).offset(48)
            make.leading.equalTo(view).offset(24)
        }
        backButton.imageView?.snp.makeConstraints { make in
            make.width.equalTo(width * 2)
            make.height.equalTo(height * 2)
        }
        backButton.setImage(UIImage(named: withNormalColor.rawValue), for: .normal)
        backButton.setImage(UIImage(named: "back_icon_tapped"), for: .highlighted)
        backButton.addTarget(self, action: didTapBackButton, for: .touchUpInside)
    }
}
