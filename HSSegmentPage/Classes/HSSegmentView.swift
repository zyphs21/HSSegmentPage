//
//  HSSegmentView.swift
//  HSSegmentPage
//
//  Created by Hanson on 2018/2/2.
//

import UIKit

public protocol HSSegmentViewDelegate: class {
    func tabDidClickToChange()
}

public class HSSegmentView: UIControl {
    
    weak var delegate: HSSegmentViewDelegate?
    
    var property = HSSegmentProperty()
    
    var items: [String] = [] {
        willSet { removeAllSegments() }
        didSet { insertAllSegments() }
    }
    
    var numberOfSegments: Int {
        return items.count
    }
    
    var selectedSegmentIndex: Int = 0 {
//        get { return _selectedSegmentIndex }
//        set { setSelected(true, forSegmentAtIndex: newValue) }
//        willSet {
//            setSelected(true, forSegmentAtIndex: newValue)
//        }
        didSet {
            setSelected(forSegmentAt: selectedSegmentIndex, previousIndex: oldValue)
        }
    }
    
    
    
//    fileprivate var _selectedSegmentIndex = 0
    
    var isTopSeparatorHidden: Bool {
        get { return separatorTopLine.isHidden }
        set { separatorTopLine.isHidden = newValue }
    }
    
    var isBottomSeparatorHidden: Bool {
        get { return separatorLine.isHidden }
        set { separatorLine.isHidden = newValue }
    }
    
    var defaltSelectedIndex: Int = 0
    
    fileprivate var segmentsButtons: [UIButton] = []
    fileprivate(set) var segmentsContainerView: UIScrollView?
    fileprivate var indicatorView = UIView()
    fileprivate var separatorTopLine = UIView()
    fileprivate var separatorLine = UIView()
    
    
    // MARK: - Initialize
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    convenience public init(items: [String], property: HSSegmentProperty?) {
        self.init()
        
        self.items = items
        if let property = property {
            self.property = property
        }
        insertAllSegments()
    }
    
    
    fileprivate func commonInit() {
        separatorTopLine.isHidden = true
        separatorTopLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        separatorLine.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    }
    
    
    // MARK: - Override function
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if segmentsButtons.count == 0 {
            selectedSegmentIndex = -1
        } else if selectedSegmentIndex < 0 {
            selectedSegmentIndex = defaltSelectedIndex
        }
        
        configureSegments()
        layoutButtons()
        layoutIndicator()
        layoutSeparator()
    }
    
    override open func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        setColors()
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setColors()
    }
    
    
    // MARK: - Open function
    
    func setSelected(forSegmentAt index: Int, previousIndex: Int) {
        guard 0 <= index, index < segmentsButtons.count, index != previousIndex else { return }
        
        layoutSelectedOffset(at: index)
        
        let previousButton = buttonAtIndex(previousIndex)
        let currentButton = buttonAtIndex(index)
        let isPreviousButtonShowAnimation = isButtonTitlePresentation(at: previousIndex)
        let isCurrentButtonShowAnimation = isButtonTitlePresentation(at: index)
        
        previousButton?.isUserInteractionEnabled = true
        previousButton?.isSelected = false
        
        currentButton?.isSelected = true
        currentButton?.isUserInteractionEnabled = false
        
        if property.isFontSizeAnimate {
            var scale: CGFloat = 1
            if let selectHeight = previousButton?.titleLabel?.bounds.height, let normalHeight = currentButton?.titleLabel?.bounds.height, let t = previousButton?.transform {
                if normalHeight > 0 && selectHeight > 0 && t.a + t.c > 0 {
                    //缩放大小 ＝ 选中的字体高度 * 仿射变换的缩放系数 / 未选中的字体高度
                    scale = selectHeight * sqrt(t.a * t.a + t.c * t.c) / normalHeight
                }
            }
            
            UIView.animate(withDuration: property.animationDuration,
                           delay: 0,
                           options: .beginFromCurrentState,
                           animations: {
                            self.layoutIndicator()
                            if isPreviousButtonShowAnimation {
                                previousButton?.transform = CGAffineTransform(scaleX: 1 / scale, y: 1 / scale)
                            }
                            if isCurrentButtonShowAnimation {
                                currentButton?.transform = CGAffineTransform(scaleX: scale, y: scale)
                            }
            },
                           completion: { _ in
                            
                            previousButton?.transform = CGAffineTransform.identity
                            currentButton?.transform = CGAffineTransform.identity
                            previousButton?.titleLabel?.font = (previousButton?.isSelected ?? true) ? self.property.selectedFont : self.property.normalFont
                            currentButton?.titleLabel?.font = (currentButton?.isSelected ?? true) ? self.property.selectedFont : self.property.normalFont
            })
            
        } else {
            UIView.animate(withDuration: property.animationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                self.layoutIndicator()
            }, completion: { _ in
                previousButton?.titleLabel?.font = self.property.normalFont
                currentButton?.titleLabel?.font = self.property.normalFont
            })
            
        }
        
        sendActions(for: .valueChanged)
    }
    
    open func setSelected(_ selected: Bool, forSegmentAtIndex index: Int) {
        guard 0 <= index, index < segmentsButtons.count else { return }
        
        layoutSelectedOffset(at: index)
        
        if selectedSegmentIndex == index {
            return
        }
        
        let previousButton = buttonAtIndex(selectedSegmentIndex)
        let currentButton = buttonAtIndex(index)
        let isPreviousButtonShowAnimation = isButtonTitlePresentation(at: selectedSegmentIndex)
        let isCurrentButtonShowAnimation = isButtonTitlePresentation(at: index)
        
        previousButton?.isUserInteractionEnabled = true
        previousButton?.isSelected = false
        
        currentButton?.isSelected = true
        currentButton?.isUserInteractionEnabled = false
        
//        _selectedSegmentIndex = index
        
        if property.isFontSizeAnimate {
            var scale: CGFloat = 1
            if let selectHeight = previousButton?.titleLabel?.bounds.height, let normalHeight = currentButton?.titleLabel?.bounds.height, let t = previousButton?.transform {
                if normalHeight > 0 && selectHeight > 0 && t.a + t.c > 0 {
                    //缩放大小 ＝ 选中的字体高度 * 仿射变换的缩放系数 / 未选中的字体高度
                    scale = selectHeight * sqrt(t.a * t.a + t.c * t.c) / normalHeight
                }
            }
            
            UIView.animate(withDuration: property.animationDuration,
                           delay: 0,
                           options: .beginFromCurrentState,
                           animations: {
                            self.layoutIndicator()
                            if isPreviousButtonShowAnimation {
                                previousButton?.transform = CGAffineTransform(scaleX: 1 / scale, y: 1 / scale)
                            }
                            if isCurrentButtonShowAnimation {
                                currentButton?.transform = CGAffineTransform(scaleX: scale, y: scale)
                            }
            },
                           completion: { _ in
                            
                            previousButton?.transform = CGAffineTransform.identity
                            currentButton?.transform = CGAffineTransform.identity
                            previousButton?.titleLabel?.font = (previousButton?.isSelected ?? true) ? self.property.selectedFont : self.property.normalFont
                            currentButton?.titleLabel?.font = (currentButton?.isSelected ?? true) ? self.property.selectedFont : self.property.normalFont
            })
            
        } else {
            UIView.animate(withDuration: property.animationDuration, delay: 0, options: .beginFromCurrentState, animations: {
                self.layoutIndicator()
            }, completion: { _ in
                previousButton?.titleLabel?.font = self.property.normalFont
                currentButton?.titleLabel?.font = self.property.normalFont
            })
            
        }
        
        sendActions(for: .valueChanged)
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func setColors() {
        indicatorView.backgroundColor = property.segmentSelectedColor
    }
    
    fileprivate func layoutIndicator() {
        if let button = selectedButton() {
            if property.isLayoutEqual {
                let rect = CGRect(x: button.frame.minX,
                                  y: bounds.height - property.indicatorHeight,
                                  width: button.frame.width,
                                  height: property.indicatorHeight)
                indicatorView.frame = rect
                
            } else {
                if property.isIndicatorFixWidth {
                    let gap = (button.frame.width - property.widthOfIndicator) / 2
                    var rect = CGRect(x: button.frame.minX + gap,
                                      y: bounds.height - property.indicatorHeight - property.bottomGapOfIndicator,
                                      width: property.widthOfIndicator,
                                      height: property.indicatorHeight)
                    if button.frame.width < property.widthOfIndicator {
                        rect = CGRect(x: button.frame.minX, y: bounds.height - property.indicatorHeight - property.bottomGapOfIndicator, width: button.frame.width, height: property.indicatorHeight)
                    }
                    indicatorView.frame = rect
                    
                } else {
                    let rect = CGRect(x: button.frame.minX, y: bounds.height - property.indicatorHeight - property.bottomGapOfIndicator, width: button.frame.width, height: property.indicatorHeight)
                    indicatorView.frame = rect
                }
            }
        }
    }
    
    fileprivate func layoutSeparator() {
        separatorTopLine.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 0.5)
        separatorLine.frame = CGRect(x: 0, y: bounds.height - 0.5, width: bounds.width, height: 0.5)
    }
    
    fileprivate func layoutButtons() {
        if property.isLayoutEqual {
            segmentsContainerView?.frame = bounds
            segmentsContainerView?.contentSize = CGSize(width: frame.width, height: floor(bounds.height))
            let width = frame.width / CGFloat(segmentsButtons.count)
            var beginX: CGFloat = 0
            for index in 0..<segmentsButtons.count {
                if let button = buttonAtIndex(index) {
                    button.sizeToFit()
                    let rect = CGRect(x: beginX, y: 0,
                                      width: width,
                                      height: bounds.height - property.indicatorHeight)
                    button.frame = rect
                    button.isSelected = (index == selectedSegmentIndex)
                    
                    beginX = rect.maxX
                }
            }
            
        } else {
            segmentsContainerView?.frame = bounds
            var originX: CGFloat = property.originalX
            var allWidth: CGFloat = 0
            for index in 0..<segmentsButtons.count {
                if let button = buttonAtIndex(index) {
                    button.sizeToFit()
                    let rect = CGRect(x: originX + property.buttonMargin, y: 0,
                                      width: property.buttonTextMargin*2 + button.frame.width,
                                      height: bounds.height - property.indicatorHeight)
                    
                    button.frame = rect
                    button.isSelected = (index == selectedSegmentIndex)
                    
                    originX = rect.maxX
                    
                    if index == segmentsButtons.count - 1 {
                        allWidth = button.frame.maxX + property.buttonMargin + property.originalX
                    }
                }
            }
            
            if allWidth <= frame.width {
                segmentsContainerView?.contentSize = CGSize(width: frame.width, height: floor(bounds.height))
                originX = (frame.width - (allWidth - (property.buttonMargin + property.originalX) * 2)) / 2
                for index in 0..<segmentsButtons.count {
                    if let button = buttonAtIndex(index) {
                        let rect = CGRect(x: originX, y: 0, width: button.frame.width, height: button.frame.height)
                        
                        button.frame = rect
                        button.isSelected = (index == selectedSegmentIndex)
                        
                        originX = rect.maxX + property.buttonMargin
                    }
                }
                
            } else {
                segmentsContainerView?.contentSize = CGSize(width: allWidth, height: floor(bounds.height))
            }
        }
    }
    
    fileprivate func layoutSelectedOffset(at index: Int) {
        guard let segmentsContainerView = segmentsContainerView,
            let button = buttonAtIndex(index),
            property.isItemScrollEnabled else { return }
        
        var targetX = max(0, button.frame.midX - self.frame.width / 2.0)
        targetX = min(segmentsContainerView.contentSize.width - self.frame.width, targetX)
        targetX = max(0, targetX)
        let point = CGPoint(x: targetX, y: 0)
        segmentsContainerView.setContentOffset(point, animated: true)
    }
    
    fileprivate func insertAllSegments() {
        for index in 0..<items.count {
            addButtonForSegment(index)
        }
        setNeedsLayout()
    }
    
    fileprivate func removeAllSegments() {
        segmentsButtons.forEach { $0.removeFromSuperview() }
        segmentsButtons.removeAll(keepingCapacity: true)
    }
    
    fileprivate func addButtonForSegment(_ index: Int) {
        let button = UIButton(type:.custom)
        button.addTarget(self, action: #selector(willSelected(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(didSelected(_:)), for: .touchUpInside)
        button.backgroundColor = nil
        button.clipsToBounds = true
        button.adjustsImageWhenDisabled = false
        button.adjustsImageWhenHighlighted = false
        button.isExclusiveTouch = true
        button.tag = index
        
        if segmentsContainerView == nil {
            segmentsContainerView = UIScrollView(frame: bounds)
            segmentsContainerView?.showsVerticalScrollIndicator = false
            segmentsContainerView?.showsHorizontalScrollIndicator = false
            segmentsContainerView?.backgroundColor = UIColor.clear
            segmentsContainerView?.isScrollEnabled = property.isItemScrollEnabled
            addSubview(segmentsContainerView!)
            
            self.sendSubview(toBack: segmentsContainerView!)
            
            addSubview(separatorTopLine)
            addSubview(separatorLine)
            segmentsContainerView?.addSubview(indicatorView)
        }
        
        segmentsButtons.append(button)
        segmentsContainerView?.addSubview(button)
    }
    
    fileprivate func buttonAtIndex(_ index: Int) -> UIButton? {
        if 0 <= index && index < segmentsButtons.count {
            return segmentsButtons[index]
        }
        return nil
    }
    
    fileprivate func selectedButton() -> UIButton? {
        return buttonAtIndex(selectedSegmentIndex)
    }
    
    fileprivate func titleForSegmentAtIndex(_ index: Int) -> String? {
        guard 0 <= index && index < items.count else { return nil }
        return items[index]
    }
    
    fileprivate func isButtonTitlePresentation(at position: Int) -> Bool {
        guard 0 <= position && position < items.count else { return false }
        return true
    }
    
    fileprivate func configureSegments() {
        for button in segmentsButtons {
            let segment = button.tag
            assert(segment >= 0, "segment index must greater than 0")
            assert(segment < numberOfSegments, "segment button must exist")
            
            let font = segment == selectedSegmentIndex ? property.selectedFont : property.normalFont
            setFont(font, forSegmentAtIndex: segment)
            
            if let title = titleForSegmentAtIndex(segment) {
                setTitle(title, forSegmentAtIndex: segment)
                setTitleColor(titleColorForButtonState(UIControlState()), forState: UIControlState())
                setTitleColor(titleColorForButtonState(.highlighted), forState: .highlighted)
                setTitleColor(titleColorForButtonState(.selected), forState: .selected)
            }
        }
    }
    
    fileprivate func setFont(_ font: UIFont, forSegmentAtIndex index: Int) {
        let button = buttonAtIndex(index)
        button?.titleLabel?.font = font
    }
    
    fileprivate func setTitle(_ title: String, forSegmentAtIndex index: Int) {
        let button = buttonAtIndex(index)
        
        button?.setTitle(title, for: UIControlState())
        button?.setTitle(title, for: .highlighted)
        button?.setTitle(title, for: .selected)
        button?.setTitle(title, for: .disabled)
    }
    
    fileprivate func setTitleColor(_ color: UIColor, forState state: UIControlState) {
        for button in segmentsButtons {
            button.setTitleColor(color, for: state)
        }
    }
    
    fileprivate func titleColorForButtonState(_ state: UIControlState) -> UIColor {
        switch state {
        case UIControlState():        return property.segmentNormalColor
        case UIControlState.disabled:    return property.segmentDisabledColor
        default:                        return property.segmentSelectedColor
        }
    }
    
    
    // MARK: - Segment Actions
    
    @objc fileprivate func willSelected(_ sender: UIButton) {
        
    }
    
    @objc fileprivate func didSelected(_ sender: UIButton) {
        if selectedSegmentIndex != sender.tag {
            selectedSegmentIndex = sender.tag
            delegate?.tabDidClickToChange()
        }
    }
}
