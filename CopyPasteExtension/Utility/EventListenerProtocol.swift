//
//  EventListenerProtocol.swift
//  CopyPasteExtension
//
//  Created by Yolo on 17/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

protocol EventListenerProtocol {
    func addEventListener(on eventType: NSEvent.EventTypeMask)
    func removeEventListener()
}
