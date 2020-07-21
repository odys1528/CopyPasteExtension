//
//  MockNSTableView.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 19/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

class MockNSTableView: NSTableView, MockStatusProtocol {
    private var status = MockStatus.unknown
    override var selectedRow: Int {
        return 0
    }
    
    override func removeRows(at indexes: IndexSet, withAnimation animationOptions: NSTableView.AnimationOptions = []) {
        status = .removed
    }
    
    func getStatus() -> MockStatus {
        return status
    }
}
