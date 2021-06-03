//
//  SettingsViewModel.swift
//  Ne Angime?
//
//  Created by Kenes Yerassyl on 5/25/21.
//

import Foundation

protocol SettingsViewModelDelegate: class {
    func reloadCollectionView()
    func userMayInteract()
}

struct SettingsSection {
    var name: String
    var items: [SettingsItem]
}

struct SettingsItem {
    var title: String
    var data: String?
    var hasToggle: Bool
    var iconImageName: String
}

class SettingsViewModel {
    var delegate: SettingsViewModelDelegate?
    var settingsSections = [SettingsSection]()
    
    func getNumberOfItems(at section: Int) -> Int {
        return settingsSections[section].items.count
    }
    
    func getNumberOfSections() -> Int {
        return settingsSections.count
    }
    
    func getItemAt(indexPath: IndexPath) -> SettingsItem {
        return settingsSections[indexPath.section].items[indexPath.row]
    }
    
    func getSectionAt(indexPath: IndexPath) -> SettingsSection {
        return settingsSections[indexPath.section]
    }
    
    func fetchSettingsInformation() {
        settingsSections = [
            SettingsSection(name: "Account", items: [
                SettingsItem(
                    title: "Bio",
                    data: nil,
                    hasToggle: false,
                    iconImageName: "bio_icon_normal"
                ),
                SettingsItem(
                    title: "Email",
                    data: UserDefaults.standard.string(forKey: "email") ?? "undefined",
                    hasToggle: false,
                    iconImageName: "email_icon_normal"
                ),
                SettingsItem(
                    title: "First Name",
                    data: UserDefaults.standard.string(forKey: "firstname") ?? "undefined",
                    hasToggle: false,
                    iconImageName: "firstname_icon_normal"
                ),
                SettingsItem(
                    title: "Last Name",
                    data: UserDefaults.standard.string(forKey: "lastname") ?? "undefined",
                    hasToggle: false,
                    iconImageName: "lastname_icon_normal"
                ),
                SettingsItem(
                    title: "Password",
                    data: nil,
                    hasToggle: false,
                    iconImageName: "password_icon_normal"
                )
            ]),
            SettingsSection(name: "Privacy", items: [
                SettingsItem(
                    title: "Private account",
                    data: "Hides your account from strangers",
                    hasToggle: true,
                    iconImageName: "private_mode_icon_normal")
            ])
        ]
        delegate?.userMayInteract()
        delegate?.reloadCollectionView()
    }
}
