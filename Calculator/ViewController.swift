//
//  ViewController.swift
//  Calculator
//
//  Created by Chris Lu on 4/2/15.
//  Copyright (c) 2015 Bowdoin College. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var Display: UILabel!
    
    var userIsInTheMiddleOfTypingNumber = false;
    
    var brain = CalculatorBrain()

    @IBAction func undoAction(sender: AnyObject) {
        //if user is in the middle of typing, backspace
        if userIsInTheMiddleOfTypingNumber
        {
            if (count(Display.text!) > 1)
            {
                Display.text = dropLast(Display.text!)
            }
            else
            {//if last digit, then just set to 0
                Display.text = "0"
            }
        }
        //if not, then undo the last action
        else
        {
            //undo operation returns the new value to display and whether or not now the user is currently typing
            let (preValue, contTyping) = brain.undoOp()
            if (preValue != nil)
            {
                if contTyping == 1
                {
                    userIsInTheMiddleOfTypingNumber = true
                    Display.text = preValue!
                }
                else
                {
                Display.text = preValue!
                }
            }
            else
            {
                displayValue = 0
            }
        }
    }
    
    //resets everything in calculator
    @IBAction func clearCalc(sender: UIButton) {
        brain.clearCalc()
        userIsInTheMiddleOfTypingNumber = false
        displayValue = 0;
    }
    
    //set the variable feature to the number in the display
    @IBAction func setVariable(sender: UIButton) {
        //user no longer typing current number
        userIsInTheMiddleOfTypingNumber = false
        let value = displayValue
        brain.setVariable(value)
        //re evaluate to go back to last evaluation before variable set
        if let result = brain.evaluate()
        {
            Display.text = result
        }
        else
        {
            displayValue = 0
        }
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if let result = brain.pushOperand("M")
        {
            Display.text = result
        }
        else
        {
            displayValue = 0
        }
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingNumber{
            Display.text = Display.text! + digit
        }
        else{
            Display.text = digit
            userIsInTheMiddleOfTypingNumber = true;
        }
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingNumber{
            Enter()
        }
        if let operation = sender.currentTitle
        {
            if let result = brain.performOperation(operation)
            {
                Display.text = result
            }
            else
            {
                displayValue = 0
            }
        }
    }

    @IBAction func Enter() {
        userIsInTheMiddleOfTypingNumber = false;
        if let result = brain.pushOperand(displayValue)
        {
            Display.text = result;
        }
        else
        {
            displayValue = 0
        }
    }
    var displayValue: Double{
        get {
            return NSNumberFormatter().numberFromString(Display.text!)!.doubleValue
        }
        set {
            Display.text = "\(newValue)"
        }
    }
}
