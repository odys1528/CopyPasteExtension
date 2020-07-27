//
//  MenuProvider.swift
//  CopyPasteExtension
//
//  Created by Yolo on 10/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa
import Carbon

final class MenuProvider: EventListenerProtocol {
    private let dataProvider: DataRepositoryProtocol
    internal var monitor: Any?
    
    init(dataProvider: ClipboardRepository) {
        self.dataProvider = dataProvider
    }
    
    func addEventListener(on eventType: NSEvent.EventTypeMask) {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: eventType) { _ in
            self.showMenu()
        }
    }
    
    func removeEventListener() {
        guard let monitor = monitor else {
            return
        }
        
        NSEvent.removeMonitor(monitor)
        self.monitor = nil
    }
    
    private func showMenu() {
        createMenu().popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }
    
    internal func createMenu() -> NSMenu {
        let clipboardMenu = NSMenu(title: AppPreferences.menuLabel)
        clipboardMenu.addItem(NSMenuItem.separator())
        let labelItem = NSMenuItem.labelMenuItem(title: AppPreferences.menuLabel)
        clipboardMenu.addItem(labelItem)
        
        try? dataProvider.allData().forEach { dataModel in
            let menuItem = NSMenuItem.initMenuItem(with: dataModel, onClick: #selector(paste(_:)))
            menuItem.target = self
            clipboardMenu.addItem(menuItem)
        }
        clipboardMenu.addItem(NSMenuItem.separator())
        
        return clipboardMenu
    }
}

//MARK:- paste method
extension MenuProvider {
    @objc private func paste(_ sender: NSMenuItem) {
        guard let dataModel = sender.representedObject as? DataModel else {
            return
        }
        //copy
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(dataModel.data, forType: .string)
        //paste
        let vKeyCode = CGKeyCode(kVK_ANSI_V)
        DispatchQueue.main.async {
            let source = CGEventSource(stateID: .combinedSessionState)
            // Disable local keyboard events while pasting
            source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents], state: .eventSuppressionStateSuppressionInterval)
            // Press Command + V
            let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
            keyVDown?.flags = .maskCommand
            // Release Command + V
            let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
            keyVUp?.flags = .maskCommand
            // Post Paste Command
            keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
            keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
}
