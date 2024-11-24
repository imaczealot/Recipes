//
//  ViewModelMockDelegate.swift
//  Recipes
//
//  Created by Jeff Miller on 11/24/24.
//
import Foundation
import XCTest
@testable import Recipes

class ViewModelMockDelegate: RecipeViewModelDelegate {
    
    var isShowingActivityView: Bool = false
    var errorInfo: EmptyViewData?
    
    var didUpdateExpectation: XCTestExpectation? {
        didSet {
            didUpdateExpectation?.assertForOverFulfill = false
        }
    }
    var didHideActivityIndicator: XCTestExpectation?
    var didShowActivityIndicator: XCTestExpectation?
    var successReturned: Bool?
    
    func didUpdate(success: Bool, errorinfo: EmptyViewData?) {
        successReturned = success
        errorInfo = errorinfo
        didUpdateExpectation?.fulfill()
    }
    
    func hideActivityIndicator() {
        didHideActivityIndicator?.fulfill()
    }
    
    func showActivityIndicator() {
        didShowActivityIndicator?.fulfill()
    }

}
