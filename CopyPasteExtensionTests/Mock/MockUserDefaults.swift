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
    
    override func string(forKey defaultName: String) -> String? {
        return mockedStringReturn?(defaultName)
    }
    
    override class func setValue(_ value: Any?, forKey key: String) {
    }
    
    override func removeObject(forKey defaultName: String) {
        status = .removed
    }
    
    func getStatus() -> MockStatus {
        return status
    }
}
