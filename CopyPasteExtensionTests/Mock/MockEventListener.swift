//
//  MockEventListener.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 17/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

class MockEventListener: EventListenerProtocol, MockStatusProtocol {
    private var status = MockStatus.unknown
    
    func addEventListener(on eventType: NSEvent.EventTypeMask) {
        status = .added
    }
    
    func removeEventListener() {
        status = .removed
    }
    
    func getStatus() -> MockStatus {
        return status
    }
    
    func resetStatus() {
        status = .unknown
    }
}
