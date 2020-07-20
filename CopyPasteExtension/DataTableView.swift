//
//  DataTableView.swift
//  CopyPasteExtension
//
//  Created by Yolo on 04/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Foundation
import Cocoa

class DataTableView: NSTableView {
    private let backspaceEventCode = 51
    private let dataProvider = CopiedDataProvider()
    
    override func keyDown(with event: NSEvent) {
        if self.selectedRow >= 0, event.keyCode == backspaceEventCode {
            self.removeRows(at: IndexSet(integer: self.selectedRow), withAnimation: .effectFade)
            
            let idCell = self.view(atColumn: self.column(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "idColumn")), row: self.selectedRow, makeIfNecessary: true) as! NSTableCellView
            guard let id = idCell.textField?.integerValue else {
                return
            }
            
            try? dataProvider.removeData(withId: id)
            self.reloadData()
        }
    }
}
