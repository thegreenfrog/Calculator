//
//  DescriptionViewController.swift
//  Calculator
//
//  Created by Chris Lu on 9/14/15.
//  Copyright (c) 2015 Bowdoin College. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var DescriptionDisplay: UILabel! {
        didSet {
            DescriptionDisplay.text = desc
        }
    }
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "zoom:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "move:"))
            
            //add double tap
        }
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return graphView
    }
    
    var desc: String = "" {
        didSet {
            DescriptionDisplay?.text = desc
        }
    }
    
}