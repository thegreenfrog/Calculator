//
//  DescriptionViewController.swift
//  Calculator
//
//  Created by Chris Lu on 9/14/15.
//  Copyright (c) 2015 Bowdoin College. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate, GraphViewDataSource {
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "zoom:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "move:"))
            let tap = UITapGestureRecognizer(target: graphView, action: "doubleTap:")
            tap.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tap)
            //add double tap
        }
    }
    
    var desc: String?
    
    var program: AnyObject {
        get {
            return calBrain.program
        }
        set {
            calBrain.program = newValue
        }
    }
    
    private var calBrain = CalculatorBrain()
    
    
    func yValue(x: CGFloat) -> CGFloat?{
        //put the x value in the variable location and evaluate
        calBrain.setVariable(Double(x))
        let (y, valid) = calBrain.evaluate()
        if valid {
            return CGFloat((NSNumberFormatter().numberFromString(y!)!.floatValue))
        }
        return nil
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return graphView
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.destinationViewController as? DescriptionViewController {
            if let ppc = identifier.popoverPresentationController {
                ppc.delegate = self
                
            }
            if (desc != nil) {
                identifier.text = desc!
            }
            
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}