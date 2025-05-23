//
//  ChatExtensionRoomSettingsViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/6/26.
//

import Foundation

class ChatExtensionRoomSettingsViewModel {
    var isOpenMicrophone: Bool
    var isOpenCamera: Bool
    private let engineManager = EngineManager.shared
    private(set) var roomSettingsViewItems: [RoomSetListItemData] = []
    init(isOpenMicrophone: Bool, isOpenCamera: Bool) {
        self.isOpenMicrophone = isOpenMicrophone
        self.isOpenCamera = isOpenCamera
        createRoomSettingsModel()
    }
    func createRoomSettingsModel() {
        let openMicItem = RoomSetListItemData()
        openMicItem.titleText = .micSeatText
        openMicItem.isSwitchOn = isOpenMicrophone
        openMicItem.action = {[weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.engineManager.store.isOpenMicrophone = view.isOn
        }
        roomSettingsViewItems.append(openMicItem)
        
        let openCameraItem = RoomSetListItemData()
        openCameraItem.titleText = .cameraSetText
        openCameraItem.isSwitchOn = isOpenCamera
        openCameraItem.action = {[weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.engineManager.store.isOpenCamera = view.isOn
        }
        roomSettingsViewItems.append(openCameraItem)
    }
}
private extension String {
    static var cameraSetText: String {
        localized("Enable video when joining a meeting")
    }
    static var micSeatText: String {
        localized("Enable audio when joining a meeting")
    }
}
