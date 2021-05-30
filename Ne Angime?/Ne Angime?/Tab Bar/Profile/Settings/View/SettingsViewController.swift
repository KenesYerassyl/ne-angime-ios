//
//  SettingsViewController.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/25/21.
//

import UIKit

class SettingsViewController: ViewController {
    
    private lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        var temp = UICollectionViewFlowLayout()
        temp.minimumLineSpacing = 12
        temp.minimumInteritemSpacing = 12;
        return temp
    }()
    private lazy var collectionView: UICollectionView = {
        var temp = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
        temp.register(SettingsCollectionViewCell.self, forCellWithReuseIdentifier: SettingsCollectionViewCell.id)
        temp.register(SettingsHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SettingsHeaderView.id)
        temp.register(SettingsFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SettingsFooterView.id)
        return temp
    }()
    private let settingsViewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#f4f5fa")
        settingsViewModel.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        updateCollectionView()
    }
    
    func updateCollectionView() {
        view.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
        }
        collectionView.alwaysBounceVertical = true
    }
}
//Extension for View Model
extension SettingsViewController: SettingsViewModelDelegate {
    
}
//Extension for collection view delegate
extension SettingsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
//Extension for collection view data source
extension SettingsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  settingsViewModel.getNumberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingsViewModel.getNumberOfItems(at: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCollectionViewCell.id, for: indexPath)
        guard let cell = collectionViewCell as? SettingsCollectionViewCell else { return UICollectionViewCell() }
        let item = settingsViewModel.getItemAt(indexPath: indexPath)
        cell.titleLabel.text = item.title
        cell.dataLabel.text = item.data
        guard let image = UIImage(named: item.iconImageName) else { fatalError() }
        let imageViewHeight = cell.contentView.bounds.height * 0.4
        cell.remakeContstraintsForIconImageView(image.size.width * (imageViewHeight / image.size.height))
        cell.iconImageView.image = image.sd_resizedImage(
            with: CGSize(width: image.size.width * (imageViewHeight / image.size.height), height: imageViewHeight),
            scaleMode: .aspectFit
        )
        if item.hasToggle { cell.updateToggleSwitch() }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let reusableView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SettingsHeaderView.id,
                for: indexPath
            ) as? SettingsHeaderView else { return UICollectionReusableView() }
            let section = settingsViewModel.getSectionAt(indexPath: indexPath)
            reusableView.nameLabel.text = section.name
            return reusableView
        case UICollectionView.elementKindSectionFooter:
            guard let reusableView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SettingsFooterView.id,
                for: indexPath
            ) as? SettingsFooterView else { return UICollectionReusableView() }
            return reusableView
        default:
            fatalError()
        }
    }
    
}
//Extension for collection view flow layout
extension SettingsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 35)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width * 0.9, height: 10)
    }
}
