//
//  HSSegmentPageView.swift
//  HSSegmentPage
//
//  Created by Hanson on 2018/2/5.
//

import Foundation


// MARK: - HSSegmentPageViewDelegate

@objc public protocol HSSegmentPageViewDelegate: class {
    @objc optional func childeViewControllerWillAppear(index: Int)
    @objc optional func childViewControllerDidApppear(index: Int)
    @objc optional func childViewControllerWillDisapppear(index: Int)
    @objc optional func childViewControllerDidDisapppear(index: Int)
}


// MARK: - VYSlideSegmentView

public class HSSegmentPageView: UIView {
    
    weak var delegate: HSSegmentPageViewDelegate?
    
    var menuBackgroundView: UIView = UIView()
    var segmentView: HSSegmentView!
    var pageScrollView: UIScrollView = UIScrollView()
    var bottomLine: UIView!
    
    var style = HSSegmentProperty()
    var heightOfSegmentMenu: CGFloat = 44
    
    var frameWidthOfMenu: CGFloat {
        return frame.width - 2 * style.gapInBothSide
    }

    var prevTabIndex = 0
    var currentTabIndex = 0
    
    var viewControllerArray: [UIViewController] = []
    var segmentTitle: [String] = []
    
    
    // MARK: - Initial
    
    public init(frame: CGRect, segmentTitle: [String], viewControllers: [UIViewController], style: HSSegmentProperty? = nil) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        
        if style != nil {
            self.style = style!
        }
        self.segmentTitle = segmentTitle
        self.viewControllerArray = viewControllers
        addMenuAndPageScorllView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Function

extension HSSegmentPageView {
    
    func addMenuAndPageScorllView() {
        
        menuBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: style.segmentMenuHeight))
        menuBackgroundView.backgroundColor = style.segmentMenuBackgroundColor
        self.addSubview(menuBackgroundView)
        
        segmentView = HSSegmentView(items: segmentTitle, property: style)
        segmentView.frame = CGRect(x: style.gapInBothSide, y: 0, width: frameWidthOfMenu, height: style.segmentMenuHeight)
        segmentView.backgroundColor = style.segmentMenuBackgroundColor
        segmentView.delegate = self
        segmentView.addTarget(self, action: #selector(onSegmentedControlValueChanged), for: .valueChanged)
        menuBackgroundView.addSubview(segmentView)
        
        pageScrollView.frame = CGRect(x: 0, y: style.segmentMenuHeight, width: frame.width, height: frame.height - style.segmentMenuHeight)
        pageScrollView.isPagingEnabled = true
        pageScrollView.delegate = self
        pageScrollView.showsHorizontalScrollIndicator = false
        pageScrollView.showsVerticalScrollIndicator = false
        pageScrollView.bounces = false
        pageScrollView.scrollsToTop = false
        pageScrollView.contentSize.width = CGFloat(viewControllerArray.count) * frame.width
        pageScrollView.contentSize.height = frame.height - style.segmentMenuHeight
        self.addSubview(pageScrollView)
    }
    
    public func slidePageScrollViewToPosition(index: Int) {
        addScrollContentView(index: index)
        currentTabIndex = index
        segmentView.selectedSegmentIndex = currentTabIndex
        let point = CGPoint(x: CGFloat(index) * frame.width, y: 0)
        self.pageScrollView.setContentOffset(point, animated: true)
    }
    
    func addScrollContentView(index: Int) {
        if let view = viewControllerArray[index].view, view.superview == nil {
            view.frame = CGRect(x: CGFloat(index) * frame.width, y: 0, width: frame.width, height: pageScrollView.frame.size.height)
            pageScrollView.addSubview(view)
        }
    }
    
    @objc func onSegmentedControlValueChanged() {
        let selectedIndex = segmentView.selectedSegmentIndex
        currentTabIndex = selectedIndex
    }
}

extension HSSegmentPageView: UIScrollViewDelegate {
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentX = scrollView.contentOffset.x
        currentTabIndex = Int(currentX / frame.width)
        
        addScrollContentView(index: currentTabIndex)
        segmentView.selectedSegmentIndex = currentTabIndex
    }
}

extension HSSegmentPageView: HSSegmentViewDelegate {
    public func tabDidClickToChange() {
        slidePageScrollViewToPosition(index: segmentView.selectedSegmentIndex)
    }
}

