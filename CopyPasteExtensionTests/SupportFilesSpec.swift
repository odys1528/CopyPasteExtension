//
//  SupportFilesSpec.swift
//  CopyPasteExtensionTests
//
//  Created by Yolo on 26/07/2020.
//  Copyright © 2020 Yolo. All rights reserved.
//

import Quick
import Nimble

class SupportFilesSpec: QuickSpec {
    override func spec() {
        //file not exists - file is created, object is returned
        //file extsts - file is not created, object is returned
        describe("the app config") {
            context("read config") {
                let mockedFileManager = MockFileManager()
                
                afterEach {
                    mockedFileManager.resetStatus()
                }
                
                it("file exists") {
                    mockedFileManager.mockedBoolReturn = {
                        return true
                    }
                    let appConfig = try? AppConfig.readConfigFile(fileManager: mockedFileManager)
                    
                    expect(appConfig) !== nil
                    expect(mockedFileManager.getStatus()) == .unknown
                }
                
                it("file does not exist") {
                    mockedFileManager.mockedBoolReturn = {
                        return false
                    }
                    let appConfig = try? AppConfig.readConfigFile(fileManager: mockedFileManager)
                    
                    expect(appConfig) !== nil
                    expect(mockedFileManager.getStatus()) == .created
                }
            }
        }
    }
}
