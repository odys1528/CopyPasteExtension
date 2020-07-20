//
//  CellIdentifier.swift
//  CopyPasteExtension
//
//  Created by Yolo on 15/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

struct CellIdentifier {
    let identifier: UserInterfaceItemIdentifier
    let row: Int
    
    init(identifier: UserInterfaceItemIdentifier, row: Int) {
        self.identifier = identifier
        self.row = row
    }
}

enum TableIdentifier: String, UserInterfaceItemIdentifier {
    case dataCell
    case dataColumn
    
    var itemIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(rawValue: self.rawValue)
    }
}

protocol UserInterfaceItemIdentifier {
    var itemIdentifier: NSUserInterfaceItemIdentifier { get }
}
