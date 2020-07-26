//
//  AppConfig.swift
//  CopyPasteExtension
//
//  Created by Yolo on 25/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

class AppConfig: Codable {
    let maxDataSize: Int
    let maxClipboardSize: Int
    
    private init(maxDataSize: Int, maxClipboardSize: Int) {
        self.maxDataSize = maxDataSize
        self.maxClipboardSize = maxClipboardSize
    }
    
    private enum CodingKeys: String, CodingKey {
        case maxDataSize
        case maxClipboardSize
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        maxDataSize = try values.decode(Int.self, forKey: .maxDataSize)
        maxClipboardSize = try values.decode(Int.self, forKey: .maxClipboardSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxDataSize, forKey: .maxDataSize)
        try container.encode(maxClipboardSize, forKey: .maxClipboardSize)
    }
}

extension AppConfig {
    private static let fileExtension = "plist"
    
    static func readConfigFile() throws -> AppConfig {
        guard let filename = AppPreferences.configFile.appendingPathExtension(fileExtension) else {
            throw AppConfigError.invalidFilename
        }
        
        let applicationSupportDirectory = FileManager.applicationSupportDirectory
        let path = applicationSupportDirectory.appendingPathComponent(filename)
        let pathURL = URL(fileURLWithPath: path)
        
        guard FileManager.default.fileExists(atPath: path) else {
            FileManager.default.createFile(atPath: path, contents: nil)
            
            let configObject = AppConfig.defaultConfig
            if let configData = try? configObject.encodeObject() {
                try? configData.write(to: pathURL)
            }
            
            return configObject
        }
        
        guard let configData = try? Data(contentsOf: pathURL),
            let configObject = try? AppConfig.decodeObject(from: configData)
            else {
            return AppConfig.defaultConfig
        }
        
        return configObject
    }
}

extension AppConfig {
    private func encodeObject() throws -> Data? {
        return try PropertyListEncoder().encode(self)
    }
    
    private static func decodeObject(from data: Data) throws -> AppConfig {
        return try PropertyListDecoder().decode(AppConfig.self, from: data)
    }
}

extension AppConfig {
    private static let defaultConfig = AppConfig(
        maxDataSize: AppPreferences.maxDataSize,
        maxClipboardSize: AppPreferences.maxClipboardSize
    )
}

private enum AppConfigError: LocalizedError {
    case invalidFilename
    
    var errorDescription: String? {
        switch self {
        case .invalidFilename:
            return "Given filename in not accessible"
        }
    }
}
