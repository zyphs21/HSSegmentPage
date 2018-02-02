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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addVYSegmentView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController {
    
    func addVYSegmentView() {
        var property = HSSegmentProperty()
        property.isLayoutEqual = true
        property.isFontSizeAnimate = false
        let segmentMenu = HSSegmentView(items: ["one","two","three","four","five","six"], property: property)
        view.addSubview(segmentMenu)
        segmentMenu.frame = CGRect(x: 0, y: 70, width: UIScreen.main.bounds.width, height: 44)
    }
}
