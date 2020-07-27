//
//  AppPreferences.swift
//  CopyPasteExtension
//
//  Created by Yolo on 03/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

struct AppPreferences {
    static let userDefaultsFilename = "CopyPasteExtension-data"
    static let menuLabel = "CLIPBOARD"
    static let configFile = "cpe-config"
    static let dataKeyBase = "copypaste"
}

//MARK:- default config values
extension AppPreferences {
    static let maxClipboardSize = 5
    static let maxDataSize = 50
}

//MARK:- app config data
extension AppPreferences {
    private static let appConfig = try? AppConfig.readConfigFile()
    
    static var getMaxClipboardSize: Int = {
        guard let maxClipboardSize = AppPreferences.appConfig?.maxClipboardSize else {
            return AppPreferences.maxClipboardSize
        }
        return maxClipboardSize
    }()
    static var getMaxDataSize: Int = {
        guard let maxDataSize = AppPreferences.appConfig?.maxDataSize else {
            return AppPreferences.maxDataSize
        }
        return maxDataSize
    }()
}
