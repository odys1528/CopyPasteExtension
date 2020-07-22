//
//  ViewControllerSpec.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 17/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Quick
import Nimble
import Carbon

class ViewControllerSpec: QuickSpec {
    override func spec() {
        describe("the view controller") {
            let viewController = ClipboardViewController()
            let dataModel = DataModel(id: 1, data: "mocked")
            
            context("on view events") {
                let `switch` = NSSwitch()
                viewController.menuProvider = MockEventListener()
                
                afterEach {
                    (viewController.menuProvider as? MockStatusProtocol)?.resetStatus()
                }
                
                it("on") {
                    `switch`.state = .on
                    viewController.switchChange(`switch`)
                    expect((viewController.menuProvider as? MockStatusProtocol)?.getStatus()) == .added
                }
                
                it("off") {
                    `switch`.state = .off
                    viewController.switchChange(`switch`)
                    expect((viewController.menuProvider as? MockStatusProtocol)?.getStatus()) == .removed
                }
            }
            
            context("on data edit") {
                var notification = Notification(name: Notification.Name("MockedNotification"))
                let prevoiusData = [dataModel]
                
                let mockNSTableView = MockNSTableView()
                let mockDefaults = MockUserDefaults()
                
                describe("no data") {
                    beforeEach {
                        notification = Notification(name: Notification.Name("MockedNotification"))
                        viewController.data = [dataModel]
                        viewController.dataTableView = mockNSTableView
                        mockDefaults.mockedStringReturn = { key in
                            if key == ClipboardRepository.dataId(withId: dataModel.id) {
                                return dataModel.data
                            }
                            return nil
                        }
                        viewController.dataProvider = ClipboardRepository(defaults: mockDefaults)
                    }
                    
                    it("no selection") {
                         mockNSTableView.mockSelectedRow = -1
                         notification.object = nil
                         
                         viewController.controlTextDidEndEditing(notification)
                         expect(viewController.data as? [DataModel]) == prevoiusData
                     }
                    
                    it("new nil data") {
                        mockNSTableView.mockSelectedRow = 0
                        notification.object = nil
                        
                        viewController.controlTextDidEndEditing(notification)
                        expect(viewController.data as? [DataModel]) == prevoiusData
                    }
                    
                    it("new empty data") {
                        viewController.dataProvider = ClipboardRepository(defaults: mockDefaults)
                        mockNSTableView.mockSelectedRow = 0
                        let textField = NSTextField()
                        textField.stringValue = ""
                        notification.object = textField
                        
                        viewController.controlTextDidEndEditing(notification)
                        expect(viewController.data as? [DataModel]) == prevoiusData
                    }
                }
                
                describe("non empty data") {
                    beforeEach {
                        viewController.data = [dataModel]
                        mockNSTableView.mockSelectedRow = 0
                        viewController.dataTableView = mockNSTableView
                        viewController.dataProvider = ClipboardRepository(defaults: mockDefaults)
                    }

                    it("new data") {
                        mockDefaults.mockedStringReturn = nil
                        
                        let textField = NSTextField()
                        textField.stringValue = dataModel.data
                        notification.object = textField

                        let storedId = ClipboardRepository.dataId(withId: dataModel.id)
                        viewController.controlTextDidEndEditing(notification)
                        expect(mockDefaults.dataSaved[storedId] as? String) == dataModel.data
                    }

                    it("update data") {
                        mockDefaults.mockedStringReturn = { key in
                            if key == ClipboardRepository.dataId(withId: dataModel.id) {
                                return dataModel.data
                            }
                            return nil
                        }
                        
                        let newData = "new data"
                        let textField = NSTextField()
                        textField.stringValue = newData
                        notification.object = textField

                        let storedId = ClipboardRepository.dataId(withId: dataModel.id+1)
                        viewController.controlTextDidEndEditing(notification)
                        expect(mockDefaults.dataSaved[storedId] as? String) == newData
                    }

                    it("trim data") {
                        mockDefaults.mockedStringReturn = { key in
                            if key == ClipboardRepository.dataId(withId: dataModel.id) {
                                return dataModel.data
                            }
                            return nil
                        }
                        
                        let newData = String.random(length: AppPreferences.maxDataSize+1)
                        let textField = NSTextField()
                        textField.stringValue = newData
                        notification.object = textField

                        let storedId = ClipboardRepository.dataId(withId: dataModel.id+1)
                        viewController.controlTextDidEndEditing(notification)
                        
                        let dataSaved = mockDefaults.dataSaved[storedId] as? String
                        expect(dataSaved) !== newData
                        expect(dataSaved?.count) == AppPreferences.maxDataSize
                    }
                }
            }
            
            context("on key events") {
                let mockNSTableView = MockNSTableView()
                viewController.dataTableView = mockNSTableView
                let mockDefaults = MockUserDefaults()
                let dataProvider = ClipboardRepository(defaults: mockDefaults)

                beforeEach {
                    viewController.data = [dataModel]
                    viewController.dataTableView = mockNSTableView
                    viewController.dataProvider = dataProvider
                }

                afterEach {
                    mockNSTableView.resetStatus()
                    mockDefaults.resetStatus()
                }

                it("valid") {
                    guard let keyEvent = NSEvent.mockEvent(with: kVK_Delete) else {
                        fail()
                        return
                    }

                    viewController.keyDown(with: keyEvent)
                    expect(mockNSTableView.getStatus()) == .removed
                    expect(mockDefaults.getStatus()) == .removed
                }

                it("invalid") {
                    guard let keyEvent = NSEvent.mockEvent(with: kVK_ANSI_X) else {
                        fail()
                        return
                    }

                    viewController.keyDown(with: keyEvent)
                    expect(mockNSTableView.getStatus()) == .unknown
                    expect(mockDefaults.getStatus()) == .unknown
                }
            }
        }
    }
}

fileprivate extension String {
    static func random(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
