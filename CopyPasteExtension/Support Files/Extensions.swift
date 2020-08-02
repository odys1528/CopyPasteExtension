//
//  Extensions.swift
//  CopyPasteExtension
//
//  Created by Yolo on 15/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa

extension NSMenuItem {
    convenience init(title: String, action: Selector?) {
        self.init(title: title, action: action, keyEquivalent: "")
    }
}

extension NSMenuItem {
    static func labelMenuItem(title: String) -> NSMenuItem {
        let labelItem = NSMenuItem(title: title, action: nil)
        labelItem.isEnabled = false
        return labelItem
    }
    
    static func initMenuItem(with dataModel: DataModelProtocol, onClick: Selector) -> NSMenuItem {
        let menuItem = NSMenuItem(title: dataModel.data, action: onClick)
        menuItem.representedObject = dataModel
        return menuItem
    }
}

extension String {
    func trim(maxLength: Int) -> String {
        return String(self.prefix(maxLength))
    }
    
    func appendingPathExtension(_ str: String) -> String? {
        return (self as NSString).appendingPathExtension(str)
    }
    
    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
}

extension Int {
    func inRange(from: Int, to: Int, rightClosed: Bool = false) -> Bool {
        return self >= from && (self < to || (rightClosed && self == to))
    }
}

extension Array {
    func itemOrNil(index: Int) -> Element? {
        return index < self.count ? self[index] : nil
    }
    
    mutating func filtered(_ isIncluded: (Self.Element) throws -> Bool) rethrows {
        self = try self.filter(isIncluded)
    }
}

extension FileManager {
    static var applicationSupportDirectory: String {
        return NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] as String
    }
}
