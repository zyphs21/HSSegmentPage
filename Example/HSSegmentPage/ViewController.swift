//
//  ViewController.swift
//  HSSegmentPage
//
//  Created by zyphs21 on 02/02/2018.
//  Copyright (c) 2018 zyphs21. All rights reserved.
//

import UIKit
import HSSegmentPage

class ViewController: UIViewController {

    private let exampleArray: [String] = ["one","two","three","four","five","six"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addVYSegmentView()
        addVYSegmentView2()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

extension ViewController {
    
    func addVYSegmentView() {
        var property = HSSegmentProperty()
        property.isLayoutEqual = true
        property.isFontSizeAnimate = false
        let segmentMenu = HSSegmentView(items: exampleArray, property: property)
        view.addSubview(segmentMenu)
        segmentMenu.frame = CGRect(x: 0, y: 70, width: UIScreen.main.bounds.width, height: 44)
    }
    
    func addVYSegmentView2() {
        var property = HSSegmentProperty()
        property.isLayoutEqual = true
        property.isFontSizeAnimate = true
        property.segmentSelectedColor = UIColor.cyan
        property.selectedFont = UIFont.systemFont(ofSize: 18)
        let segmentMenu = HSSegmentView(items: exampleArray, property: property)
        view.addSubview(segmentMenu)
        segmentMenu.frame = CGRect(x: 0, y: 120, width: UIScreen.main.bounds.width, height: 44)
    }
}
