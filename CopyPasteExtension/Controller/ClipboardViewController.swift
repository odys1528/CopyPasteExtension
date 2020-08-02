//
//  ClipboardViewController.swift
//  CopyPasteExtension
//
//  Created by Yolo on 03/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Cocoa
import Carbon

class ClipboardViewController: NSViewController {
    @IBOutlet weak var dataTableView: NSTableView!
    var data: [DataModelProtocol] = []
    var cache: [Int: String] = [:]
    
    internal var dataProvider: DataRepositoryProtocol? = nil
    internal var menuProvider: EventListenerProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repository = ClipboardRepository(defaults: UserDefaults(suiteName: AppPreferences.userDefaultsFilename))
        dataProvider = repository
        menuProvider = MenuProvider(dataProvider: repository)
        
        setupTable()
        NSSound.beep()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        dataTableView.reloadData()
        self.view.window?.acceptsMouseMovedEvents = true
    }
    
    @IBAction func switchChange(_ sender: NSSwitch) {
        let state = sender.state
        if state == .on {
            menuProvider?.addEventListener(on: .rightMouseUp)
        } else {
            menuProvider?.removeEventListener()
        }
    }
    
    @IBAction func closeAppWindow(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}

//MARK:- NSTableViewDelegate
extension ClipboardViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < AppPreferences.getMaxClipboardSize else {
            return nil
        }
        
        let dataModel = data.itemOrNil(index: row)

        if tableColumn?.identifier == TableIdentifier.dataColumn.itemIdentifier {
            guard let cellView = tableView.makeView(withIdentifier: TableIdentifier.dataCell.itemIdentifier, owner: self) as? NSTableCellView else {
                return nil
            }
            
            cellView.textField?.delegate = self
            cellView.objectValue = dataModel
            if let data = dataModel?.data {
                cellView.textField?.stringValue = data
            }
            
            return cellView
        }
        
        return nil
    }
}

//MARK:- NSTableViewDataSource
extension ClipboardViewController: NSTableViewDataSource {
    private func setupTable() {
        refreshData()
        dataTableView.delegate = self
        dataTableView.dataSource = self
    }
    
    private func refreshData() {
        guard let allData = try? dataProvider?.allData() else {
            return
        }
        data = allData
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return AppPreferences.getMaxClipboardSize
    }
}

//MARK:- NSTextFieldDelegate
extension ClipboardViewController: NSTextFieldDelegate {
    func controlTextDidBeginEditing(_ obj: Notification) {
        let selectedRow = dataTableView.selectedRow
        guard
            let data = (obj.object as? NSTextField)?.stringValue,
            selectedRow >= 0
            else {
            return
        }
        
        cache[selectedRow] = data
    }
    
    func controlTextDidEndEditing(_ notification: Notification) {
        let selectedRow = dataTableView.selectedRow
        guard
            selectedRow.inRange(from: 0, to: AppPreferences.getMaxClipboardSize),
            let newData = (notification.object as? NSTextField)?.stringValue
            else {
            return
        }
        
        let data = newData.trim(maxLength: AppPreferences.getMaxDataSize)
        let cellView = dataTableView.cellView(cellIdentifier: CellIdentifier(identifier: TableIdentifier.dataCell, row: selectedRow))
        cellView?.setText(data)
        
        guard let dataModel = cellView?.objectValue as? DataModel else {
            guard newData.count > 0 else {
                cellView?.setText(cache[selectedRow])
                return
            }
            
            guard let itemId = try? (dataProvider as? ClipboardRepository)?.setData(withItemData: data) else {
                return
            }
            
            let newDataModel = DataModel(id: itemId, data: data)
            cellView?.setObject(newDataModel)
            self.data.append(newDataModel)
            
            return
        }
        
        guard newData.count > 0 else {
            cellView?.setText(cache[selectedRow])
            return
        }
        
        let updatedDataModel = DataModel(id: dataModel.id, data: data)
        cellView?.setObject(updatedDataModel)
        guard let _ = try? dataProvider?.setData(item: updatedDataModel) else {
            cellView?.setText(cache[selectedRow])
            return
        }
        
        let index = self.data.firstIndex {
            $0.id == updatedDataModel.id
        }
        guard let validIndex = index else {
            return
        }
        self.data[validIndex] = updatedDataModel
    }
}

//MARK:- delete on backspace
extension ClipboardViewController {
    override func keyDown(with event: NSEvent) {
        let selectedRow = dataTableView.selectedRow
        let cellView = dataTableView.cellView(cellIdentifier: CellIdentifier(identifier: TableIdentifier.dataCell, row: selectedRow))
        
        guard
            event.keyCode == kVK_Delete,
            selectedRow.inRange(from: 0, to: AppPreferences.getMaxClipboardSize),
            let dataModel = cellView?.objectValue as? DataModel
            else {
            return
        }
        
        guard let _ = try? (dataProvider as? ClipboardRepository)?.removeData(withId: dataModel.id) else {
            return
        }
        
        data = data.filter {
            $0.id != dataModel.id
        }
        cache[selectedRow] = nil
        
        dataTableView.update {
            cellView?.setText("")
            cellView?.setObject(nil)
            dataTableView.recycleRow()
        }
    }
}

//MARK:- NSTableView extension
private extension NSTableView {
    func update(action: () -> ()) {
        self.beginUpdates()
        action()
        self.endUpdates()
    }
    
    func cellView(cellIdentifier: CellIdentifier) -> NSTableCellView? {
        return view(atColumn: column(withIdentifier: cellIdentifier.identifier.itemIdentifier), row: cellIdentifier.row, makeIfNecessary: false) as? NSTableCellView
    }
    
    func recycleRow(rowId: Int? = nil) {
        guard let rowId = rowId else {
            self.moveRow(at: selectedRow, to: nearestFreeRowId-1)
            return
        }
        
        self.moveRow(at: rowId, to: nearestFreeRowId-1)
    }
    
    private var nearestFreeRowId: Int {
        for index in selectedRow+1...numberOfRows-1 {
            let cellView = self.cellView(cellIdentifier: CellIdentifier(identifier: TableIdentifier.dataCell, row: index))
            let objectValue = cellView?.objectValue as? DataModel
            guard objectValue != nil else {
                return index
            }
        }
        return numberOfRows-1
    }
}

//MARK:- NSTableCellView extension
private extension NSTableCellView {
    func setText(_ text: String?) {
        guard let text = text else {
            return
        }
        self.textField?.stringValue = text
    }
    
    func setObject(_ object: Any?) {
        self.objectValue = object
    }
}
