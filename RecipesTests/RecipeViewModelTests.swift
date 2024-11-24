//
//  RecipeViewModelTests.swift
//  RecipesTests
//
//  Created by Jeff Miller on 11/24/24.
//

import XCTest
import OHHTTPStubs
import OHHTTPStubsSwift
@testable import Recipes


class RecipeViewModelTests: XCTestCase {
    
    var viewModel: RecipeViewModel?
    var mockDelegate: ViewModelMockDelegate?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        mockDelegate = ViewModelMockDelegate()
        viewModel = RecipeViewModel(delegate:mockDelegate)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        viewModel = nil
    }
    
    
    func testEmptyViewData() {
        let empty = viewModel?.emptyViewData()
        XCTAssert(empty!.title == "No Recipes Available")
        XCTAssert(empty!.description == "An error has occurred retreiving recipes.")
    }
    
    func testFetchRecipeData() {
        
        let stubExpectation = self.expectation(description: "Stub should fire")
        stub(condition: isHost("d3jbb8n5wk0qxi.cloudfront.net")) { _ in
            let stubPath = OHPathForFile("Recipes_Success.json", type(of: self))
            stubExpectation.fulfill()
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        mockDelegate?.didUpdateExpectation = expectation(description: "Should Fire")
        
        viewModel?.pendingFetch = false
        viewModel?.refreshRecipeData(true)
        waitForExpectations(timeout: 5)
        XCTAssert(viewModel?.recipeList.count == 63,"Should load 63 recipes")
    }
    
    func testFetchEmptyRecipeData() {
        
        let stubExpectation = self.expectation(description: "Stub should fire")
        stub(condition: isHost("d3jbb8n5wk0qxi.cloudfront.net")) { _ in
            let stubPath = OHPathForFile("Recipes_Empty.json", type(of: self))
            stubExpectation.fulfill()
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        mockDelegate?.didUpdateExpectation = expectation(description: "Should Fire")
        
        viewModel?.pendingFetch = false
        viewModel?.refreshRecipeData(true)
        waitForExpectations(timeout: 5)
        XCTAssert(viewModel?.recipeList.count == 0,"Should load 0 recipes")
    }
    
    func testFetchMalformedRecipeData() {
                
        let stubExpectation = self.expectation(description: "Stub should fire")
        stub(condition: isHost("d3jbb8n5wk0qxi.cloudfront.net")) { _ in
            let stubPath = OHPathForFile("Recipes_Malformed.json", type(of: self))
            stubExpectation.fulfill()
            return fixture(filePath: stubPath!, headers: ["Content-Type":"application/json"])
        }
        mockDelegate?.didUpdateExpectation = expectation(description: "Should Fire")

        viewModel?.pendingFetch = false
        viewModel?.refreshRecipeData(true)
        waitForExpectations(timeout: 5)
        XCTAssert(viewModel?.recipeList.count == 0,"Should load 0 recipes")
        XCTAssert(mockDelegate?.errorInfo?.description == "Unable to read data from server", "Error message indicates malformed data")
    }
}
