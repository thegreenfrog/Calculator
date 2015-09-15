//
//  DescriptionViewController.swift
//  Calculator
//
//  Created by Chris Lu on 9/14/15.
//  Copyright (c) 2015 Bowdoin College. All rights reserved.
//

import UIKit

class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var DescriptionDisplay: UILabel!
    
    var desc: String?
    
    override func viewDidLoad() {
        if (desc != nil) {
            DescriptionDisplay.text! = desc!
        }
        
    }
}