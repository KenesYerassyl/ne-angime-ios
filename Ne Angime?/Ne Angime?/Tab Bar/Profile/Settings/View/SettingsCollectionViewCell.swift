//
//  SettingsCollectionViewCell.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/25/21.
//

import UIKit

class SettingsCollectionViewCell: UICollectionViewCell {
    static let id = "SettingsCollectionViewCell"
    let titleLabel = UILabel()
    let iconImageView = UIImageView()
    let dataLabel = UILabel()
    let toggleSwitch = UISwitch()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        
        updateIconImageView()
        updateTitle(isCentered: true)
        updateData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateIconImageView() {
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.4)
            make.width.equalTo(contentView.bounds.height * 0.4)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView.bounds.height * 0.3)
        }
        
    }
    
    func remakeContstraintsForIconImageView(_ newWidth: CGFloat) {
        iconImageView.snp.remakeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.4)
            make.width.equalTo(newWidth)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView.bounds.height * 0.3)
        }
    }
    
    func updateTitle(isCentered: Bool) {
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont(name: "Avenir Heavy", size: 16)
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.3);
            make.centerX.equalTo(contentView)
            make.width.equalTo(contentView.bounds.width * 0.6)
            make.top.equalTo(contentView).offset(contentView.bounds.height * 0.3 * 0.5)
        }
    }
    
    func updateData() {
        contentView.addSubview(dataLabel)
        dataLabel.font = UIFont(name: "Avenir", size: 13)
        dataLabel.textColor = .systemGray
        dataLabel.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.3);
            make.centerX.equalTo(contentView)
            make.width.equalTo(contentView.bounds.width * 0.6)
            make.bottom.equalTo(contentView).offset(-contentView.bounds.height * 0.3 * 0.5)
        }
    }
    
    func updateToggleSwitch() {
        contentView.addSubview(toggleSwitch)
        toggleSwitch.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-contentView.bounds.height * 0.3)
            make.centerY.equalTo(contentView)
        }
        toggleSwitch.onTintColor = UIColor(hex: "#30289F")
        toggleSwitch.isUserInteractionEnabled = true
    }
}
