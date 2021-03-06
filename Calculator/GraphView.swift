//
//  GraphView.swift
//  Calculator
//
//  Created by Chris Lu on 9/18/15.
//  Copyright © 2015 Bowdoin College. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yValue(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    var scale: CGFloat = 50.0 { didSet { setNeedsDisplay() } }
    var zoom: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    var color: UIColor = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    var origin: CGPoint {
        get {
            var origin = originRealtiveToRealCenter
            origin.x += center.x
            origin.y += center.y
            return origin
        }
        set {
            var origin = newValue
            origin.x -= center.x
            origin.y -= center.y
            originRealtiveToRealCenter = origin
        }
    }
    
    private var originRealtiveToRealCenter: CGPoint = CGPoint() { didSet { setNeedsDisplay() } }
    
    var snapshot: UIView?
    
    weak var dataSource: GraphViewDataSource?
    
    func zoom(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .Began:
            //get current screen
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
        case .Changed:
            //edit frame and origin to fit zoom
            let touchLoc = gesture.locationInView(self)
            snapshot!.frame.size.height *= gesture.scale
            snapshot!.frame.size.width *= gesture.scale
            snapshot!.frame.origin.x = snapshot!.frame.origin.x * gesture.scale + (1 - gesture.scale) * touchLoc.x
            snapshot!.frame.origin.y = snapshot!.frame.origin.y * gesture.scale + (1 - gesture.scale) * touchLoc.y
            gesture.scale = 1.0
            //always remember to reset zoom to 1.0
        case .Ended:
            let changedScale = snapshot!.frame.height/self.frame.height
            scale *= changedScale
            origin.x = origin.x * changedScale + snapshot!.frame.origin.x
            origin.y = origin.y * changedScale + snapshot!.frame.origin.y
            
            //wipe slate clean
            snapshot!.removeFromSuperview()
            snapshot = nil
        default:
            break
        }
    }
    
    func move(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Began:
            //get current screen
            snapshot = self.snapshotViewAfterScreenUpdates(false)
            snapshot!.alpha = 0.8
            self.addSubview(snapshot!)
        case .Changed:
            //edit frame and origin to fit shift
            let touchLoc = gesture.translationInView(self)
            print("(\(touchLoc.x),\(touchLoc.y))")
            snapshot!.center.x += touchLoc.x
            snapshot!.center.y += touchLoc.y
            gesture.setTranslation(CGPointZero, inView: self)
        case .Ended:
            origin.x += snapshot!.frame.origin.x
            origin.y += snapshot!.frame.origin.y
            snapshot!.removeFromSuperview()
            snapshot = nil;
        default:
            break
        }
    }
    
    func doubleTap(gesture: UITapGestureRecognizer) {
        if gesture.state == .Ended {
            origin = gesture.locationInView(self)
        }
    }
    
    override func drawRect(rect: CGRect) {
        AxesDrawer(contentScaleFactor: contentScaleFactor).drawAxesInRect(bounds, origin: origin, pointsPerUnit: scale)
        
        //draw the graph 
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var point = CGPoint()
        var firstPoint = true
        for var i = 0; i <= Int(bounds.size.width * contentScaleFactor); i++ {
            //draw each point given its location
            point.x = CGFloat(i) / contentScaleFactor
            if let yVal = dataSource?.yValue((point.x - origin.x)/scale)
            {
                point.y = origin.y - yVal * scale
                if firstPoint {
                    path.moveToPoint(point)
                    firstPoint = false
                    continue
                }
                path.addLineToPoint(point)
            } else {
                firstPoint = true
            }
        }
        path.stroke()
        
    }
}
