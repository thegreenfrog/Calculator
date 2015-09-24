//
//  DescriptionViewController.swift
//  Calculator
//
//  Created by Chris Lu on 9/21/15.
//  Copyright © 2015 Bowdoin College. All rights reserved.
//

import UIKit

class DescriptionViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.text = text
        }
    }
    
    var text: String = "" {
        didSet {
            textView?.text = text
        }
    }

}
