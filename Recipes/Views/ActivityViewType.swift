//
//  ActivityViewType.swift
//  Recipes
//
//  Created by Jeff Miller on 11/23/24.
//

import Foundation
import SVProgressHUD


protocol ActivityViewType: AnyObject {
    var isShowingActivityView: Bool { get set }
    func showActivityIndicator()
    func hideActivityIndicator()
}

extension ActivityViewType {
    
    func showActivityIndicator() {
        print("ActivityViewType: showActivityIndicator:")
        isShowingActivityView = true
        if Thread.isMainThread {
            SVProgressHUD.show()
        } else {
            print("WARNING: showActivityIndicator: NOT isMainThread")
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
    }
    
    func hideActivityIndicator() {
        print("ActivityViewType: hideActivityIndicator:")
        isShowingActivityView = false
        if Thread.isMainThread {
            SVProgressHUD.setContainerView(nil)
            SVProgressHUD.dismiss()
        } else {
            DispatchQueue.main.async {
                SVProgressHUD.setContainerView(nil)
                SVProgressHUD.dismiss()
            }
        }
    }
}
