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
    
    internal var dataProvider: DataRepositoryProtocol? = nil
    internal var menuProvider: EventListenerProtocol? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let repository = ClipboardRepository(defaults: UserDefaults(suiteName: AppPreferences.userDefaultsFilename))
        dataProvider = repository
        menuProvider = MenuProvider(dataProvider: repository)
        let x = AppPreferences.getMaxDataSize
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
        dataTableView.delegate = self
        dataTableView.dataSource = self
        refreshData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return AppPreferences.getMaxClipboardSize
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return data.itemOrNil(index: row)
    }
}

//MARK:- NSTextFieldDelegate
extension ClipboardViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ notification: Notification) {
        let selectedRow = dataTableView.selectedRow
        guard selectedRow.inRange(from: 0, to: AppPreferences.getMaxClipboardSize),
            let newData = (notification.object as? NSTextField)?.stringValue else {
            return
        }
        
        let data = newData.trim(maxLength: AppPreferences.getMaxDataSize)
        let cellView = dataTableView.cellView(cellIdentifier: CellIdentifier(identifier: TableIdentifier.dataCell, row: selectedRow))
        cellView?.textField?.stringValue = data
        
        guard let dataModel = cellView?.objectValue as? DataModel else {
            guard let itemId = try? (dataProvider as? ClipboardRepository)?.setData(withItemData: data) else {
                return
            }
            
            let updatedDataModel = DataModel(id: itemId, data: data)
            cellView?.objectValue = updatedDataModel
            
            refreshData()
            return
        }
        
        let updatedDataModel = DataModel(id: dataModel.id, data: data)
        cellView?.objectValue = updatedDataModel
        try? dataProvider?.setData(item: updatedDataModel)
        refreshData()
    }
}

//MARK:- delete on backspace
extension ClipboardViewController {
    override func keyDown(with event: NSEvent) {
        let selectedRow = dataTableView.selectedRow
        
        guard event.keyCode == kVK_Delete,
            selectedRow.inRange(from: 0, to: AppPreferences.getMaxClipboardSize),
            let dataModel = data.itemOrNil(index: selectedRow)
            else {
            return
        }
        
        dataTableView.removeRows(at: IndexSet(integer: selectedRow), withAnimation: .effectFade)
        try? (dataProvider as? ClipboardRepository)?.removeData(withId: dataModel.id)
        refreshData()
    }
    
    private func refreshData() {
        guard let allData = try? dataProvider?.allData() else {
            return
        }
        data = allData
    }
}

//MARK:- NSTableView extension
private extension NSTableView {
    func cellView(cellIdentifier: CellIdentifier) -> NSTableCellView? {
        return view(atColumn: column(withIdentifier: cellIdentifier.identifier.itemIdentifier), row: cellIdentifier.row, makeIfNecessary: false) as? NSTableCellView
    }
}
