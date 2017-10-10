//
//  ViewController.swift
//  HSSegmentPage
//
//  Created by Hanson on 2017/10/10.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var titleArray = ["Test1", "Test2", "Test3"]
    var viewControllerArray: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addVC()
        
        let viewPage = HSSegmentPage(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64))
        viewPage.delegate = self
        viewPage.setUp()
        viewPage.slidePageScrollViewToPosition(index: 0)
        view.addSubview(viewPage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func addVC() {
        let vc1 = TestViewController()
        vc1.color = UIColor.cyan
        viewControllerArray.append(vc1)
        let vc2 = TestViewController()
        vc2.color = UIColor.brown
        viewControllerArray.append(vc2)
        let vc3 = TestViewController()
        vc3.color = UIColor.blue
        viewControllerArray.append(vc3)
    }
}

extension ViewController: HSSegmentPageDelegate {
    func slideSegmentNumberOfTab() -> Int {
        return titleArray.count
    }

    func slideSegmentViewOfTab(index: Int) -> UIView {
        return viewControllerArray[index].view
    }

    func slideSegmentTitlesOfTab(index: Int) -> String {
        return titleArray[index]
    }

    func childViewControllerDidApppear(index: Int) {
    }
}

