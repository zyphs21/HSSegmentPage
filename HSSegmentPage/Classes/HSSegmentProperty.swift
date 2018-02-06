//
//  HSSegmentProperty.swift
//  HSSegmentPage
//
//  Created by Hanson on 2018/2/2.
//

import Foundation

public struct HSSegmentProperty {
    
    public var segmentMenuHeight: CGFloat = 44
    public var gapInBothSide: CGFloat = 0 //44
    public var segmentMenuBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.1)
    public var indicatorHeight: CGFloat = 2.5
    public var originalX: CGFloat = 4
    public var buttonTextMargin: CGFloat = 5
    public var buttonMargin: CGFloat = 10
    public var widthOfIndicator: CGFloat = 40
    public var bottomGapOfIndicator: CGFloat = 0
    
    public var animationDuration: TimeInterval = 0.2
    
    public var segmentNormalColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    public var segmentDisabledColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    public var segmentSelectedColor: UIColor = UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
    
    public var normalFont   = UIFont.systemFont(ofSize: 16)
    public var selectedFont = UIFont.systemFont(ofSize: 17)
    
    public var isItemScrollEnabled: Bool = true
    public var isFontSizeAnimate: Bool = false
    public var isIndicatorFixWidth: Bool = false
    public var isLayoutEqual: Bool = false
    
    public init() {
        
    }
}
