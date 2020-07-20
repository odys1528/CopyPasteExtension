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
            
            context("on view events") {
                let `switch` = NSSwitch()
                
                beforeEach {
                    viewController.menuProvider = MockEventListener()
                }
                
                it("on") {
                    `switch`.state = .on
                    viewController.switchChange(`switch`)
                    expect((viewController.menuProvider as? MockEventListener)?.getStatus()) == .added
                }
                
                it("off") {
                    `switch`.state = .off
                    viewController.switchChange(`switch`)
                    expect((viewController.menuProvider as? MockEventListener)?.getStatus()) == .removed
                }
            }
            
            context("on key events") {
                it("valid") {
                    let mockNSTableView = MockNSTableView()
                    viewController.dataTableView = mockNSTableView
                    let mockDefaults = MockUserDefaults()
                    viewController.dataProvider = ClipboardRepository(defaults: mockDefaults)
                    viewController.data = [DataModel(id: 1, data: "mocked")]
                    
                    guard let keyEvent = NSEvent.mockEvent(with: kVK_Delete) else {
                        fail()
                        return
                    }

                    viewController.keyDown(with: keyEvent)
                    expect(mockNSTableView.getStatus()) == .removed
                    expect(mockDefaults.getStatus()) == .removed
                }

                it("invalid") {
                    let mockNSTableView = MockNSTableView()
                    viewController.dataTableView = mockNSTableView
                    let mockDefaults = MockUserDefaults()
                    viewController.dataProvider = ClipboardRepository(defaults: mockDefaults)
                    viewController.data = [DataModel(id: 1, data: "mocked")]
                    
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
