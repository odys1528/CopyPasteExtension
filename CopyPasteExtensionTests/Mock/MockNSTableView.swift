//
//  MockNSTableView.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 19/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

class MockNSTableView: NSTableView {
    var mockSelectedRow: Int = 0
    private var status = MockStatus.unknown
    override var selectedRow: Int {
        return mockSelectedRow
    }
    
    override func removeRows(at indexes: IndexSet, withAnimation animationOptions: NSTableView.AnimationOptions = []) {
        status = .removed
    }
    
    override func moveRow(at oldIndex: Int, to newIndex: Int) {
        status = .moved
    }
    
    override func view(atColumn column: Int, row: Int, makeIfNecessary: Bool) -> NSView? {
        return nil
    }
}

//MARK:- MockStatusProtocol protocol
extension MockNSTableView: MockStatusProtocol {
    func getStatus() -> MockStatus {
        return status
    }
    
    func resetStatus() {
        status = .unknown
    }
}
