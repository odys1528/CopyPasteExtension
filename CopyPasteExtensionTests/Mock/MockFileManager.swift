//
//  MockFileManager.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 26/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

class MockFileManager: FileManager {
    typealias MockedBoolReturn = () -> Bool?
    var mockedBoolReturn: MockedBoolReturn? = nil
    private var status = MockStatus.unknown
    
    override func fileExists(atPath path: String) -> Bool {
        return mockedBoolReturn?() ?? true
    }
    
    override func createFile(atPath path: String, contents data: Data?, attributes attr: [FileAttributeKey : Any]? = nil) -> Bool {
        status = .created
        return true
    }
}

//MARK:- MockStatusProtocol protocol
extension MockFileManager: MockStatusProtocol {
    func getStatus() -> MockStatus {
        return status
    }
    
    func resetStatus() {
        status = .unknown
    }
}
