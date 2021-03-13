//
//  ConversationsCollectionViewCell.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 2/13/21.
//

import UIKit

class ConversationsCollectionViewCell: UICollectionViewCell {
    static let id = "ConversationsCollectionViewCell"
    var userImageView = UIImageView()
    var userNameLabel = UILabel()
    var userMessageLabel = UILabel()
    var newMessagesLabel = UILabel()
    var newMessagesCounter: Int = 0 {
        willSet {
            if newValue == 0 {
                newMessagesLabel.isHidden = true
                newMessagesLabel.snp.makeConstraints { make in
                    make.width.equalTo(contentView.bounds.height * 0.3)
                }
                newMessagesLabel.text = ""
            } else if (1...9).contains(newValue) {
                newMessagesLabel.snp.makeConstraints { make in
                    make.width.equalTo(contentView.bounds.height * 0.3)
                }
                newMessagesLabel.text = "\(newValue)"
                newMessagesLabel.isHidden = false
            } else if (10...999).contains(newValue) {
                let newText = "\(newValue)"
                newMessagesLabel.snp.updateConstraints { make in
                    make.width.equalTo(newText.width(withConstrainedHeight: contentView.bounds.width, font: newMessagesLabel.font) + 16)
                }
                newMessagesLabel.text = newText
                newMessagesLabel.isHidden = false
            } else {
                newMessagesLabel.snp.updateConstraints { make in
                    make.width.equalTo("999+".width(withConstrainedHeight: contentView.bounds.width, font: newMessagesLabel.font) + 16)
                }
                newMessagesLabel.text = "999+"
                newMessagesLabel.isHidden = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 20
        updateUserImageView()
        updateUserNameLabel()
        updateUserMessageLabel()
        updateNewMessagesLabel()
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
        userNameLabel.font = UIFont(name: "Avenir", size: 20)
        userNameLabel.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.3);
            make.leading.equalTo(userImageView.snp.trailing).offset(contentView.bounds.height * 0.3 * 0.5)
            make.width.equalTo(contentView.bounds.width * 0.6)
            make.top.equalTo(contentView).offset(contentView.bounds.height * 0.3 * 0.5)
        }
    }
    
    func updateUserMessageLabel() {
        contentView.addSubview(userMessageLabel)
        userMessageLabel.font = UIFont(name: "Avenir", size: 15)
        userMessageLabel.textColor = .systemGray
        userMessageLabel.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.3);
            make.leading.equalTo(userImageView.snp.trailing).offset(contentView.bounds.height * 0.3 * 0.5)
            make.width.equalTo(contentView.bounds.width * 0.6)
            make.bottom.equalTo(userImageView)
        }
    }
    func updateNewMessagesLabel() {
        contentView.addSubview(newMessagesLabel)
        newMessagesLabel.snp.makeConstraints { make in
            make.height.equalTo(contentView.bounds.height * 0.3)
            make.width.equalTo(contentView.bounds.height * 0.3)
            make.centerY.equalTo(contentView)
            make.trailing.equalTo(-contentView.bounds.height * 0.3 * 0.5)
        }
        newMessagesLabel.backgroundColor = UIColor(hex: "#aba7f3")
        newMessagesLabel.textColor = UIColor(hex: "#30289f")
        newMessagesLabel.textAlignment = .center
        newMessagesLabel.layer.masksToBounds = true
        newMessagesLabel.layer.cornerRadius = contentView.bounds.height * 0.15
        newMessagesLabel.isHidden = true
    }
}
