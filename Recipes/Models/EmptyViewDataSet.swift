//
//  EmptyViewDataSet.swift
//  Recipes
//
//  Created by Jeff Miller on 11/23/24.
//

import Foundation
import DZNEmptyDataSet

class EmptyViewData {
    
    init() {
    
    }
    
    var title: String?
    var description: String?
    
}

protocol EmptyViewDelegate: AnyObject {
    
    func emptyViewData() -> EmptyViewData?
    func shouldShowEmptyView() -> Bool
}

extension EmptyViewDelegate {
    
    func shouldShowEmptyView() -> Bool {
        return true
    }
    
    func emptyViewData() -> EmptyViewData? {
        return nil
    }
}

class EmptyViewDataSet: NSObject, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    weak var delegate: EmptyViewDelegate?
    var errorData: EmptyViewData?
    
    func currentEmptyViewData() -> EmptyViewData? {
        var data: EmptyViewData?
        if let error = errorData {
            data = error
        } else {
            data = delegate?.emptyViewData()
        }
        return data
    }
    
    @objc func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return delegate?.shouldShowEmptyView() ?? false
    }
    
//    @objc func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage? {
//        guard let image = currentEmptyViewData()?.image else { return nil }
//        return image
//    }
       
    @objc func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var attributedValue: NSAttributedString?
        if let value = currentEmptyViewData()?.title {
            let attribs = [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray
            ]
            
            attributedValue = NSAttributedString(string: value, attributes: attribs)
        }
        return attributedValue
    }
    
    @objc func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        var attributedValue: NSAttributedString?
        if let value = currentEmptyViewData()?.description {
            let para = NSMutableParagraphStyle()
            para.lineBreakMode = NSLineBreakMode.byWordWrapping
            para.alignment = NSTextAlignment.center
            
            let attribs = [
                NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline),
                NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                NSAttributedString.Key.paragraphStyle: para
            ]
            
            attributedValue = NSAttributedString(string: value, attributes: attribs)
        }
        return attributedValue
    }
    
//    @objc func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControl.State) -> NSAttributedString? {
//        var attributedValue: NSAttributedString?
//        if let value = currentEmptyViewData()?.buttonText {
//            let backgroundColor = ASThemeManager.sharedInstance.backgroundColor
//            let color = state == UIControl.State.normal ? backgroundColor : backgroundColor.withAlphaComponent(0.5)
//            attributedValue = NSAttributedString(string: value , attributes:[NSAttributedString.Key.foregroundColor:color])
//        
//        }
//        return attributedValue
//    }
    
    @objc func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
//        currentEmptyViewData()?.action?()
        errorData = nil
    }

}