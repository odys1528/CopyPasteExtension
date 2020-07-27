//
//  CellIdentifier.swift
//  CopyPasteExtension
//
//  Created by Yolo on 15/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

struct CellIdentifier {
    let identifier: ItemIdentifierProtocol
    let row: Int
    
    init(identifier: ItemIdentifierProtocol, row: Int) {
        self.identifier = identifier
        self.row = row
    }
}

enum TableIdentifier: String, ItemIdentifierProtocol {
    case dataCell
    case dataColumn
    
    var itemIdentifier: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(rawValue: self.rawValue)
    }
}

protocol ItemIdentifierProtocol {
    var itemIdentifier: NSUserInterfaceItemIdentifier { get }
}
