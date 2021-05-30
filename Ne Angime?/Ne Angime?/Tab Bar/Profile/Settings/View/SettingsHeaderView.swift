//
//  SettingsHeaderView.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/25/21.
//

import UIKit

class SettingsHeaderView: UICollectionReusableView {
    static let id = "SettingsHeaderView"
    var nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateNameLabel() {
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(UIScreen.main.bounds.width * 0.05)
            make.centerY.equalTo(self)
        }
        nameLabel.font = UIFont(name: "Avenir Heavy", size: 20)
    }
    
}
