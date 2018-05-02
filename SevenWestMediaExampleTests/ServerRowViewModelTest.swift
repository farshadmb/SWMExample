//
//  ServerRowViewModelTest.swift
//  SevenWestMediaExampleTests
//
//  Created by Farshad Mousalou on 5/2/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import XCTest
@testable import SevenWestMediaExample

class ServerRowViewModelTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let testData = """
    {
        "title":"About Canada",
        "rows":[
                {
                    "title":"Beavers",
                    "description":"Beavers are second only to humans in their ability to manipulate and change their environment. They can measure up to 1.3 metres         long. A group of beavers is called a colony",
                    "imageHref":"http://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/American_Beaver.jpg/220px-American_Beaver.jpg"
                },
                {
                    "title":"Flag",
                    "description":null,
                    "imageHref":"http://images.findicons.com/files/icons/662/world_flag/128/flag_of_canada.png"
                }]
  }
""".data(using: .utf8)!
        
        let model = try? JSONDecoder().decode(ServerDataModel.self, from: testData)
        XCTAssertTrue(model != nil, "model is nil")
        
        let viewModel = ServerDataViewModel(withData: model!)
    
        viewModel.title.observe({ (newValue , oldValue) in
            debugPrint("Title = \(newValue), old = \(oldValue)")
        })
        
        let rowViewModel = viewModel[at:0]
        
        rowViewModel.image?.observe({ (newValue, oldValue) in
              debugPrint("Image = \(newValue), old = \(oldValue)")
        })
        
        rowViewModel.loadImage { (image, error) in
            
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
