//
//  UIViewController+Extension.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 3/8/21.
//

import UIKit

extension UIViewController {
    
    func addBackButton(didTapBackButton: Selector) {
        let backButton = UIButton()
        view.addSubview(backButton)
        let width = UIImage(named: "back_icon_normal")!.size.width
        let height = UIImage(named: "back_icon_normal")!.size.height
        backButton.snp.makeConstraints { make in
            make.width.equalTo(width * 2)
            make.height.equalTo(height * 2)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            make.leading.equalTo(view).offset(24)
        }
        backButton.imageView?.snp.makeConstraints { make in
            make.width.equalTo(width * 2)
            make.height.equalTo(height * 2)
        }
        backButton.setImage(UIImage(named: "back_icon_normal"), for: .normal)
        backButton.setImage(UIImage(named: "back_icon_tapped"), for: .selected)
        backButton.setImage(UIImage(named: "back_icon_tapped"), for: .highlighted)
        backButton.addTarget(self, action: didTapBackButton, for: .touchUpInside)
    }
    
}
