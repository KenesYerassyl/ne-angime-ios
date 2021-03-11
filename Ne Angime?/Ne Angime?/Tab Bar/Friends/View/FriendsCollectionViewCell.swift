//
//  FriendsCollectionViewCell.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import SnapKit

class FriendsCollectionViewCell: UICollectionViewCell {
    static let id = "FriendsCollectionViewCell"
    var userImageView = UIImageView()
    var userNameLabel: UILabel = {
        var temp = UILabel()
        temp.font = UIFont(name: "Avenir", size: 20)
        return temp
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        updateUserImageView()
        updateUserNameLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateUserImageView() {
        contentView.addSubview(userImageView)
        userImageView.backgroundColor = UIColor(hex: "#aba7f3")
        userImageView.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.7)
            make.width.equalTo(contentView.bounds.height * 0.7)
            make.centerY.equalTo(contentView)
            make.leading.equalTo(contentView.bounds.height * 0.3 * 0.5)
        }
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = contentView.bounds.height * 0.7 * 0.5
    }
    
    func updateUserNameLabel() {
        contentView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.3);
            make.leading.equalTo(userImageView.snp.trailing).offset(contentView.bounds.height * 0.3 * 0.5)
            make.trailing.equalTo(contentView)
            make.centerY.equalTo(contentView)
        }
    }
}
