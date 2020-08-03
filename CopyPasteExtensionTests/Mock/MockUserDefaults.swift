//
//  MockUserDefaults.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 16/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation

class MockUserDefaults: UserDefaults {
    typealias MockedStringReturn = (String) -> String?
    var mockedStringReturn: MockedStringReturn? = nil
    private var status = MockStatus.unknown
    var dataSaved: [String: String?] = [:]
    
    override func string(forKey defaultName: String) -> String? {
        return mockedStringReturn?(defaultName)
    }
    
    override func setValue(_ value: Any?, forKey key: String) {
        dataSaved[key] = value as? String?
    }
    
    override func removeObject(forKey defaultName: String) {
        status = .removed
    }
}

//MARK:- MockStatusProtocol protocol
extension MockUserDefaults: MockStatusProtocol {
    func getStatus() -> MockStatus {
        return status
    }
    
    func resetStatus() {
        status = .unknown
        dataSaved = [:]
    }
}
