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
    var mockNumberOfRows: Int = 0
    var mockCellObject: DataModelProtocol? = nil
    private var status = MockStatus.unknown
    
    override var selectedRow: Int {
        return mockSelectedRow
    }
    override var numberOfRows: Int {
        return mockNumberOfRows
    }
    
    override func removeRows(at indexes: IndexSet, withAnimation animationOptions: NSTableView.AnimationOptions = []) {
        status = .removed
    }
    
    override func moveRow(at oldIndex: Int, to newIndex: Int) {
        status = .moved
    }
    
    override func view(atColumn column: Int, row: Int, makeIfNecessary: Bool) -> NSView? {
        let mockedCell = NSTableCellView()
        mockedCell.objectValue = mockCellObject
        return mockedCell
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
