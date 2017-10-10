//
//  HSSegmentPage.swift
//  HSSegmentPage
//
//  Created by Hanson on 2017/10/10.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import UIKit

struct HSSegmentPageStyle {
    var heightOfMenu: CGFloat = 44
    var heightOfIndicator: CGFloat = 2
    var bottomGapOfIndicator: CGFloat = 2
    
    var widthOfToolItem: CGFloat = 44
    var widthOfIndicator: CGFloat = 40
    
    var spaceBetweenTabItem: CGFloat = 5
    var textPadding: CGFloat = 15
    
    var tabFont = UIFont.boldSystemFont(ofSize: 18)
    
    var tabLightColor = UIColor.blue
    var tabDimColor = UIColor.black.withAlphaComponent(0.5)
    var indicatorColor = UIColor.blue
    var menuBackgroundColor = UIColor.white
    
    var isIndicatorAsItem: Bool = false
    var isFixItemWidth: Bool = false
}


class HSSegmentPageTabItem: UILabel {
    var padding: CGFloat = 8
    var tabIndex: Int?
    var itemText: String? {
        didSet {
            let textSize = itemText!.size(withAttributes: [NSAttributedStringKey.font: font])
            self.frame.size.width = textSize.width + 2 * padding
            self.text = itemText
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpItem() {
        let textSize = itemText!.size(withAttributes: [NSAttributedStringKey.font: font])
        self.frame.size.width = textSize.width + 2 * padding
        self.text = itemText
    }
}


@objc protocol HSSegmentPageDelegate: class {
    func slideSegmentNumberOfTab() -> Int
    func slideSegmentViewOfTab(index:Int) -> UIView
    func slideSegmentTitlesOfTab(index:Int) -> String
    @objc optional func editButtonClick(pageIndex: Int)
    @objc optional func childeVCWillAppear(index: Int)
    @objc optional func childViewControllerDidApppear(index: Int)
    @objc optional func childViewControllerWillDisapppear(index: Int)
    @objc optional func childViewControllerDidDisapppear(index: Int)
}


class HSSegmentPage: UIView, UIScrollViewDelegate {
    
    weak var delegate: HSSegmentPageDelegate?
    
    var menuScrollView: UIScrollView = UIScrollView()
    var pageScrollView: UIScrollView = UIScrollView()
    var indicator: UIView = UIView()
    var bottomLine: UIView!
    
    var style = HSSegmentPageStyle()
    
    var contentWidthOfMenu: CGFloat = 0
    var frameWidthOfMenu: CGFloat {
        return frame.width - 2 * style.widthOfToolItem
    }
    
    var tabItems: [HSSegmentPageTabItem] = []
    
    var prevTabIndex = 0
    var currentTabIndex = 0
    var currentIndicatorX: CGFloat = 0
    var currentIndicatorWidth: CGFloat = 0
    var contentScrollContentOffsetX: CGFloat = 0
    
    var isUserTappingTab: Bool = false
    
    var searchButtonClick: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Set Up
    
    func setUp() {
        if delegate != nil {
            addMenuAndPageScorllView()
            addIndicator()
            setScrollViewContent()
            adaptMenuContentWidth()
            normalSlideToItem(tab: tabItems[0])
            addBottomLine()
            setTabStyle()
        }
    }
    
    
    // MARK: - Function
    
    func addMenuAndPageScorllView() {
        
        menuScrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: style.heightOfMenu)
        menuScrollView.backgroundColor = style.menuBackgroundColor
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.scrollsToTop = false
        self.addSubview(menuScrollView)
        
        pageScrollView.frame = CGRect(x: 0, y: style.heightOfMenu, width: frame.width, height: frame.height - style.heightOfMenu)
        pageScrollView.isPagingEnabled = true
        pageScrollView.delegate = self
        pageScrollView.showsHorizontalScrollIndicator = false
        pageScrollView.showsVerticalScrollIndicator = false
        pageScrollView.bounces = false
        pageScrollView.scrollsToTop = false
        self.addSubview(pageScrollView)
    }
    
    func addIndicator() {
        menuScrollView.addSubview(indicator)
        indicator.frame.origin.y = style.heightOfMenu - style.heightOfIndicator - style.bottomGapOfIndicator
        indicator.frame.size.height = style.heightOfIndicator
        indicator.backgroundColor = style.indicatorColor
    }
    
    func addBottomLine() {
        bottomLine = UIView(frame: CGRect(x: 0, y: style.heightOfMenu - 0.5, width: frame.width, height: 0.5))
        bottomLine.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.addSubview(bottomLine)
    }
    
    func setScrollViewContent() {
        pageScrollView.contentSize.width = CGFloat(delegate!.slideSegmentNumberOfTab()) * frame.width
        pageScrollView.contentSize.height = frame.height - style.heightOfMenu
        
        contentWidthOfMenu = 0
        var XOffset: CGFloat = style.spaceBetweenTabItem
        for i in 0 ..< delegate!.slideSegmentNumberOfTab() {
            let tabItem = getTabItem(index: i, xOffset: XOffset)
            if style.isFixItemWidth {
                tabItem.frame.size.width = frame.width / CGFloat(delegate!.slideSegmentNumberOfTab())
            }
            XOffset += style.spaceBetweenTabItem + tabItem.frame.width
            contentWidthOfMenu += style.spaceBetweenTabItem + tabItem.frame.width
            menuScrollView.addSubview(tabItem)
            tabItems.append(tabItem)
        }
        menuScrollView.contentSize.width = contentWidthOfMenu
    }
    
    func adaptMenuContentWidth() {
        if contentWidthOfMenu < frameWidthOfMenu {
            let availableSpace: CGFloat = frameWidthOfMenu - contentWidthOfMenu
            let startOffsetX = availableSpace / 2
            contentWidthOfMenu = 0
            var XOffset: CGFloat = startOffsetX
            for tab in tabItems {
                tab.frame.origin.x = XOffset
                XOffset += style.spaceBetweenTabItem + tab.frame.width
                contentWidthOfMenu += style.spaceBetweenTabItem + tab.frame.width
            }
            menuScrollView.contentSize.width = contentWidthOfMenu
        }
    }
    
    func normalSlideToItem(tab: HSSegmentPageTabItem) {
        UIView.animate(withDuration: 0.3) {
            self.slideToItem(tab: tab)
        }
    }
    
    private func slideToItem(tab: HSSegmentPageTabItem){
        if style.isIndicatorAsItem {
            self.indicator.frame.origin.x = tab.frame.origin.x
            self.indicator.frame.size.width = tab.frame.width
        } else {
            self.indicator.frame.origin.x = tab.frame.origin.x + (tab.frame.width - style.widthOfIndicator)/2
            self.indicator.frame.size.width = style.widthOfIndicator
        }
    }
    
    func slidePageScrollViewToPosition(index: Int) {
        addContentView(index: index)
        let point = CGPoint(x: CGFloat(index) * frame.width,y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.pageScrollView.setContentOffset(point, animated: false)
            self.delegate?.childViewControllerDidApppear?(index: index)
        }) { (finish) in
            self.isUserTappingTab = false
        }
    }
    
    func setTabStyle() {
        let preTab = tabItems[prevTabIndex]
        preTab.textColor = style.tabDimColor
        
        let curTab = tabItems[currentTabIndex]
        curTab.textColor = style.tabLightColor
    }
    
    private func positIndicator() {
        indicator.frame.origin.y = style.heightOfMenu - style.heightOfIndicator
    }
    
    func getTabItem(index: Int, xOffset: CGFloat) -> HSSegmentPageTabItem {
        let item = HSSegmentPageTabItem()
        item.tabIndex = index
        item.frame.size.height = style.heightOfMenu
        item.padding = style.textPadding
        if style.isFixItemWidth {
            item.text = delegate?.slideSegmentTitlesOfTab(index: index)
        } else {
            item.itemText = delegate?.slideSegmentTitlesOfTab(index: index)
        }
        item.frame.origin.x = xOffset
        item.frame.origin.y = 0
        item.textAlignment = .center
        item.textColor = style.tabDimColor
        item.font = style.tabFont
        
        item.isUserInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(itemPress(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        item.addGestureRecognizer(tap)
        
        return item
    }
    
    @objc func itemPress(_ sender: AnyObject) {
        isUserTappingTab = true
        
        let tap: UIGestureRecognizer = sender as! UIGestureRecognizer
        let tabItem: HSSegmentPageTabItem = tap.view as! HSSegmentPageTabItem
        
        prevTabIndex = currentTabIndex
        currentTabIndex = tabItem.tabIndex!
        setTabStyle()
        
        normalSlideToItem(tab: tabItem)
        slidePageScrollViewToPosition(index: tabItem.tabIndex!)
        //        adjustTopScrollViewsContentOffsetX(tab: tab)
        adjustScrollMenuContentOffsetX(tab: tabItem)
    }
    
    func scrollToIndex(index: Int, tabItem: HSSegmentPageTabItem) {
        prevTabIndex = currentTabIndex
        currentTabIndex = tabItem.tabIndex!
        setTabStyle()
        
        normalSlideToItem(tab: tabItem)
        slidePageScrollViewToPosition(index: tabItem.tabIndex!)
    }
    
    func scrollToIndex(index: Int) {
        guard index < tabItems.count else { return }
        prevTabIndex = currentTabIndex
        let tabItem = tabItems[index]
        currentTabIndex = index
        setTabStyle()
        
        normalSlideToItem(tab: tabItem)
        slidePageScrollViewToPosition(index: tabItem.tabIndex!)
    }
    
    func addContentView(index: Int) {
        let view = delegate!.slideSegmentViewOfTab(index: index)
        if view.superview == nil {
            view.frame.origin.x = CGFloat(index) * frame.width
            view.frame.origin.y = 0
            view.frame.size.height = pageScrollView.frame.size.height
            pageScrollView.addSubview(view)
        }
    }
    
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentTabIndex = Int(scrollView.contentOffset.x / frame.width)
        setTabStyle()
        prevTabIndex = currentTabIndex
        let tab = tabItems[currentTabIndex]
        setTabStyle()
        if style.isIndicatorAsItem {
            currentIndicatorX = tab.frame.origin.x
            currentIndicatorWidth = tab.frame.width
        } else {
            currentIndicatorX = tab.frame.origin.x + (tab.frame.width - style.widthOfIndicator)/2
            currentIndicatorWidth = style.widthOfIndicator
        }
        contentScrollContentOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if isUserTappingTab == true { return }
        
        let currentX = scrollView.contentOffset.x
        var gap: CGFloat = 0
        
        if currentX > contentScrollContentOffsetX {
            // 向左滑动，indicator 向右移动
            gap = currentX - contentScrollContentOffsetX
            if gap > frame.width {
                contentScrollContentOffsetX = currentX
                currentTabIndex = Int(currentX / frame.width)
                let tab = tabItems[currentTabIndex]
                normalSlideToItem(tab: tab)
                return
            }
            if currentTabIndex + 1 <= tabItems.count {
                let indicatorTotalWidth = getIndicatorTotalWidth(index: currentTabIndex + 1)
                let nextDistance: CGFloat = calcNextMoveDistance(gap: gap, nextTotal: indicatorTotalWidth)
                setWidthOfIndicator(distance: nextDistance + 10)
            }
            
        } else {
            // 向右滑动，indicator 向左移动
            gap = contentScrollContentOffsetX - currentX
            if currentTabIndex >= 1 {
                let indicatorTotalWidth = getIndicatorTotalWidth(index: currentTabIndex - 1)
                let nextDistance: CGFloat = calcNextMoveDistance(gap: gap, nextTotal: indicatorTotalWidth)
                setWidthOfIndicator(distance: nextDistance + 10)
                indicator.frame.origin.x = currentIndicatorX - nextDistance - 10
            }
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentX = scrollView.contentOffset.x
        currentTabIndex = Int(currentX / frame.width)
        let tab = tabItems[currentTabIndex]
        setTabStyle()
        
        //        adjustTopScrollViewsContentOffsetX(tab: tab)
        adjustScrollMenuContentOffsetX(tab: tab)
        UIView.animate(withDuration: 0.2) {
            self.slideToItem(tab: tab)
        }
        addContentView(index: currentTabIndex)
        self.delegate?.childViewControllerDidApppear?(index: currentTabIndex)
    }
    
    private func getIndicatorTotalWidth(index:Int) -> CGFloat {
        if style.isIndicatorAsItem {
            let tab = tabItems[index]
            let total: CGFloat = style.spaceBetweenTabItem + tab.frame.width
            return total
        } else {
            let total: CGFloat = style.spaceBetweenTabItem + style.widthOfIndicator //tab.frame.width
            return total
        }
    }
    
    private func calcNextMoveDistance(gap:CGFloat, nextTotal: CGFloat) -> CGFloat {
        let nextMove: CGFloat = (gap / frame.width) * nextTotal
        
        return nextMove
    }
    
    private func setWidthOfIndicator(distance: CGFloat){
        if distance < 1 {
            //            resetHeightOfWorm()
            
        } else {
            indicator.frame.size.width = currentIndicatorWidth + distance
        }
    }
    
    private func adjustScrollMenuContentOffsetX(tab: HSSegmentPageTabItem) {
        let widthOfTabItem = tab.frame.width
        let tabX = tab.frame.origin.x
        let xOfTabInMenuFrame = tabX - menuScrollView.contentOffset.x
        let lastTabShouldBeXpositon = self.frame.width - (style.spaceBetweenTabItem + widthOfTabItem)
        
        // 选中的tab在右边界没显示完全
        if xOfTabInMenuFrame > lastTabShouldBeXpositon {
            let point = CGPoint(x: tabX - lastTabShouldBeXpositon , y: 0)
            menuScrollView.setContentOffset(point, animated: false)
        }
        // 选中的tab在左边边界没显示完全
        if xOfTabInMenuFrame < style.spaceBetweenTabItem {
            let point = CGPoint(x: tabX - style.spaceBetweenTabItem, y: 0)
            menuScrollView.setContentOffset(point, animated: false)
        }
    }
}
