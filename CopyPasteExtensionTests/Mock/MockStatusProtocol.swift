//
//  MockStatusProtocol.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 20/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

protocol MockStatusProtocol {
    func getStatus() -> MockStatus
}

enum MockStatus {
    case unknown
    case removed
    case added
}
