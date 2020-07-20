//
//  UtilitySpec.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 17/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Quick
import Nimble

class UtilitySpec: QuickSpec {
    override func spec() {
        describe("the menu provider") {
            let mockDefaults = MockUserDefaults()
            let menuProvider = MenuProvider(dataProvider: ClipboardRepository(defaults: mockDefaults))
            
            context("monitor setting") {
                it("register monitor") {
                    menuProvider.addEventListener(on: .rightMouseUp)
                    expect(menuProvider.monitor).notTo(beNil())
                }
                
                it("unregister monitor") {
                    menuProvider.removeEventListener()
                    expect(menuProvider.monitor).to(beNil())
                }
                
                it("unregister monitor again") {
                    menuProvider.removeEventListener()
                    menuProvider.removeEventListener()
                    expect(menuProvider.monitor).to(beNil())
                }
            }
            
            context("menu creation") {
                mockDefaults.mockedStringReturn = { _ in
                    return "nana"
                }
                
                let menu = menuProvider.createMenu()
                expect(menu).notTo(beNil())
            }
        }
    }
}
