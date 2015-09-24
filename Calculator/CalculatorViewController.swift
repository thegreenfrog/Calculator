 //
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Chris Lu on 4/2/15.
//  Copyright (c) 2015 Bowdoin College. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var Display: UILabel!
    @IBOutlet weak var decimalButton: UIButton!
    
    var userIsInTheMiddleOfTypingNumber = false;
    
    var decimalPlaced = false;
    
    var brain = CalculatorBrain()

    @IBAction func negativeVal(sender: UIButton) {
        if !userIsInTheMiddleOfTypingNumber {
            if displayValue == 0 {
                Display.text! = "-"
                return
            }
            //treat negative sign as an action
            if let operation = sender.currentTitle
            {
                if let result = brain.performOperation(operation).result
                {
                    Display.text = result
                }
                else
                {
                    displayValue = 0
                }
            }
            
        }
        else {
            Display.text! = "-" + Display.text!
        }
        
    }
    
    @IBAction func undoAction(sender: AnyObject) {
        //if user is in the middle of typing, backspace
        if userIsInTheMiddleOfTypingNumber
        {
            if ((Display.text!).characters.count > 1)
            {
                Display.text = String((Display.text!).characters.dropLast())
            }
            else
            {//if last digit, then just set to 0
                Display.text = "0"
                userIsInTheMiddleOfTypingNumber = false
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
        displayValue = 0
    }
    
    //set the variable feature to the number in the display
    @IBAction func setVariable(sender: UIButton) {
        //user no longer typing current number
        userIsInTheMiddleOfTypingNumber = false
        let value = displayValue
        brain.setVariable(value)
        //re evaluate to go back to last evaluation before variable set
        if let result = brain.evaluate().result
        {
            Display.text = result
        }
        else
        {
            displayValue = 0
        }
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if let result = brain.pushOperand("M").result
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
            if sender == decimalButton {
                if decimalPlaced {
                    return
                }
                decimalPlaced = true
            }
            Display.text = Display.text! + digit
        }
        else{
            userIsInTheMiddleOfTypingNumber = true
            if sender == decimalButton {
                Display.text = "0."
                decimalPlaced = true
            }
            if Display.text! == "-" {
                Display.text! = Display.text! + digit
                return
            }
            Display.text = digit
            
        }
    }

    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingNumber{
            Enter()
        }
        if let operation = sender.currentTitle
        {
            if let result = brain.performOperation(operation).result
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
        if let result = brain.pushOperand(displayValue).result
        {
            Display.text = result
        }
        else
        {
            displayValue = 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let intermediate = destination as? UINavigationController {
            destination = intermediate.visibleViewController
        }
        if let dvc = destination as? GraphViewController {
            if let equation = brain.returnDesc() {
                dvc.desc = equation
                dvc.program = brain.program
                dvc.title = brain.returnDesc() == "" ? "Graph" : brain.returnDesc()
            }
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

