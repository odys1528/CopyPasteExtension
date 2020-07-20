//
//  MockNSEvent.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 19/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

extension NSEvent {
    static func mockEvent(with keyCode: Int) -> NSEvent? {
        return NSEvent.keyEvent(with: .keyDown, location: NSPoint(), modifierFlags: .option, timestamp: 0, windowNumber: 0, context: nil, characters: "", charactersIgnoringModifiers: "", isARepeat: false, keyCode: UInt16(keyCode))
    }
}
