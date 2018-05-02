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
    
    /// <#Description#>
    func testLoadModalImageWithoutCaching() {
        
        var disposal = Disposal()
        
        // Create an expectation
        let expectation = self.expectation(description: "LoadingContent")
        
        let viewModal = ServerDataViewModel()
        
        viewModal.isLoading.observe({ (newValue, oldValue) in
            
            debugPrint("isLoading = \(newValue)")
            
        }).add(to: &disposal)
        
        
        viewModal.loadData({ (result, error) in
            
            XCTAssertTrue(error == nil, "error occure info error\(error)")
            
            XCTAssertTrue(result, "result is \(result)")
            
            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            expectation.fulfill()
        })
        
        // Wait for the expectation to be fullfilled, or time out
        // after 60 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 60.0, handler: nil)
        
        XCTAssertTrue(viewModal.data != nil, "data is not fetch")
        
        
        // Create an expectation for LoadingImage
        let imageExpectation = self.expectation(description: "LoadingImage")

        let rowViewModal = viewModal[at:0]

        rowViewModal.image?.observe({ (newValue, oldValue) in
            debugPrint("Image newValue = \(newValue)")
            debugPrint("Image old = \(oldValue)")
        }).add(to: &disposal)
        
        // Load Image without caching 
        rowViewModal.loadImage(shouldCacheImage: false) { (image, error) in
           
            XCTAssertTrue(error == nil, "error occure info error\(error)")
            
            XCTAssertTrue(image != nil, "image is \(image)")
            
            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            imageExpectation.fulfill()
        }
        
        // Wait for the expectation to be fullfilled, or time out
        // after 60 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 60.0, handler: nil)
        
        disposal.removeAll()
        
    }
    
    func testLoadModalImageWithCaching() {
        
        var disposal = Disposal()
        
        // Create an expectation
        let expectation = self.expectation(description: "LoadingContent")
        
        let viewModal = ServerDataViewModel()
        
        viewModal.isLoading.observe({ (newValue, oldValue) in
            
            debugPrint("isLoading = \(newValue)")
            
        }).add(to: &disposal)
        
        
        viewModal.loadData({ (result, error) in
            
            XCTAssertTrue(error == nil, "error occure info error\(error)")
            
            XCTAssertTrue(result, "result is \(result)")
            
            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            expectation.fulfill()
        })
        
        // Wait for the expectation to be fullfilled, or time out
        // after 60 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 60.0, handler: nil)
        
        XCTAssertTrue(viewModal.data != nil, "data is not fetch")
        
        
        // Create an expectation for LoadingImage
        let imageExpectation = self.expectation(description: "LoadingImage")
        
        let rowViewModal = viewModal[at:0]
        
        rowViewModal.image?.observe({ (newValue, oldValue) in
            debugPrint("Image newValue = \(newValue)")
            debugPrint("Image old = \(oldValue)")
        }).add(to: &disposal)
        
        // Load Image without caching
        rowViewModal.loadImage(shouldCacheImage: true) { (image, error) in
            
            XCTAssertTrue(error == nil, "error occure info error\(error)")
            
            XCTAssertTrue(image != nil, "image is \(image)")
            
            // Fullfil the expectation to let the test runner
            // know that it's OK to proceed
            imageExpectation.fulfill()
        }
        
        // Wait for the expectation to be fullfilled, or time out
        // after 60 seconds. This is where the test runner will pause.
        waitForExpectations(timeout: 60.0, handler: nil)
        
        disposal.removeAll()
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
