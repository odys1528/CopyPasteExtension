//
//  AppConfigProtocol.swift
//  CopyPasteExtension
//
//  Created by Yolo on 27/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

protocol AppConfigProtocol: Codable {
    static func readConfigFile(fileManager: FileManager) throws -> AppConfigProtocol
}
