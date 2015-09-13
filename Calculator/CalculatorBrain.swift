//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Chris Lu on 4/10/15.
//  Copyright (c) 2015 Bowdoin College. All rights reserved.
//

import Foundation

class CalculatorBrain{
    
    //enum that has types for any kind of element inserted into calculator
    private enum Op: Printable
    {
        case Operand(Double)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) -> Double)
        
        var description: String{
            get{
                switch self{
                case .Variable(let name):
                    return "\(name)"
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return "\(symbol)"
                case .BinaryOperation(let symbol, _, _):
                    return "\(symbol)"
                }
            }
        }
        
        var precedence: Int{
            get{
                switch self{
                case .BinaryOperation(_, let precedence, _):
                    return precedence
                default:
                    return Int.max
                }
            }
        }
    }
    
    private var description = String()
    
    private var opStack = [Op]()
    
    private  var knownOps = [String:Op]()
    
    private var variableValues = [String: Double]()
    
    init(){
        knownOps["×"] = Op.BinaryOperation("×", 2, *)
        knownOps["+"] = Op.BinaryOperation("+", 1, +)
        knownOps["−"] = Op.BinaryOperation("−", 1, {$1 - $0})
        knownOps["÷"] = Op.BinaryOperation("÷", 2, {$1 / $0})
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["±"] = Op.UnaryOperation("-", -)
    }
    
    var program: AnyObject{//guaranteed to be a PropertyList
        get{
            return opStack.map {$0.description}
        }
        set{
            if let opSymbols = newValue as? Array<String>{
                var newOpStack = [Op]()
                for opSymbol in opSymbols{
                    if let op = knownOps[opSymbol]{
                        newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue{
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op{
            case .Variable(let name):
                if let val = variableValues[name]
                {
                    return(val, remainingOps)
                }
                else
                {
                    return (nil, remainingOps)
                }
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result
                {
                    return(operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result{
                        return(operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    private func buildDesc(ops: [Op]) -> (result: String, restOp: [Op], precedence: Int?)
    {
        if !ops.isEmpty
        {
            var remainingOp = ops
            let op = remainingOp.removeLast()
            switch op{
            case .Variable(let name):
                return ("\(name)", remainingOp, op.precedence)
            case .Operand(let operand):
                return ("\(operand)", remainingOp, op.precedence)
            case .UnaryOperation(let uOp, _):
                let unaryOp = buildDesc(remainingOp)
                var unaryResult = unaryOp.result
                if op.precedence > unaryOp.precedence {
                    unaryResult = "(\(unaryResult))"
                }
                return ("\(uOp) \(unaryResult) ", remainingOp, op.precedence)
            case .BinaryOperation(let bOp, _, _):
                let rightOp = buildDesc(remainingOp)
                var rightResult = rightOp.result
                let leftOp = buildDesc(rightOp.restOp)
                var leftResult = leftOp.result
                if op.precedence > rightOp.precedence {
                    rightResult = "(\(rightResult))"
                }
                if op.precedence > leftOp.precedence {
                    leftResult = "(\(leftResult))"
                }
                return ("\(leftResult) \(bOp) \(rightResult)", leftOp.restOp, op.precedence)
            }
        }
        else
        {
            return ("?", ops, Int.max)
        }
    }
    
    func evaluate() -> String?
    {
        let (result, remainder) = evaluate(opStack)
        //build the string
        let equation = buildDesc(opStack)
        description = equation.result
        println("\(description)")
        if let anyErr = evaluateAndReportErrors()
        {
            return anyErr
        }
        else
        {
            return "\(result!)";
        }
    }
    
    //recursive function to find errors in expression
    //removes last element, figures out its type (operand or operator), and tests its value and 
    //placement relative to other elements of the stack to see if the expression is valid
    //return tuple in form (valid?, error message if false or "value" if true, value calculated so far from expression, remaining opStack)
    private func findErrors(ops: [Op]) -> (result: Bool, type: String, value: Double?, restOp: [Op])
    {
        if !ops.isEmpty
        {
            var remainingOp = ops
            let op = remainingOp.removeLast()
            switch op{
            case .Variable(let name):
                if let value = variableValues[name]
                {
                    return (true, "value", value, remainingOp)
                }
                return (false, "no variable value set", nil, remainingOp)
            case .Operand(let operand):
                return (true, "value", operand, remainingOp)
            case .UnaryOperation(_, let uOp):
                let unaryOp = findErrors(remainingOp)
                if (unaryOp.result)
                {
                    if unaryOp.value < 0
                    {
                        return (false, "square root of negative number invalid", nil, remainingOp)
                    }
                    else
                    {
                        return (true, "value", uOp(unaryOp.value!), remainingOp)
                    }
                }
                else
                {
                    return (false, "\(unaryOp.type)", nil, remainingOp)
                }
            case .BinaryOperation(let sign, _, let bOp):
                //look to the left and right of the operator to find any errors
                //if none exists, ensure that both are values
                let rightOp = findErrors(remainingOp)
                let leftOp = findErrors(rightOp.restOp)
                if rightOp.result && leftOp.result
                {
                    if sign == "÷"
                    {
                        if rightOp.value == 0
                        {
                            return (false, "cannot divide by 0", nil, leftOp.restOp)
                        }
                    }
                    
                    return (true, "value", bOp(leftOp.value!, rightOp.value!), leftOp.restOp)
                }
                else
                {
                    if !rightOp.result
                    {
                        return (false, "\(rightOp.type)", nil, rightOp.restOp)
                    }
                    return (false, "\(leftOp.type)", nil, leftOp.restOp)
                }
            }
        }
        else
        {
            return (false, "missing operand", nil, ops)
        }

    }
    
    //parent function used to find any errors in the expression
    func evaluateAndReportErrors() -> String?
    {
        //mimick evaluate(), but do not pass back description
        //immediatley return when find error
        let errmsg = findErrors(opStack)
        if errmsg.result
        {
            return nil
        }
        else
        {
            return "\(errmsg.type)"
        }
    }
    
    //push a value to the stack
    func pushOperand(operand: Double) -> String?
    {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    //push variable to stack
    func pushOperand(operand: String) -> String?
    {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    
    //add operator to stack and evaluate expression
    func performOperation(symbol: String) -> String?
    {
        if let operation = knownOps[symbol]{
            opStack.append(operation)
        }
        return evaluate()
    }
    
    //function to set variable to display value
    func setVariable(value: Double)
    {
        variableValues["M"] = value
    }
    
    //return saved variable value
    func getVariable() -> Double?
    {
        if let value = variableValues["M"]
        {
            return value
        }
        else
        {//return nil if no value set for variable
            return nil
        }
    }
    
    //clear data structures
    func clearCalc()
    {
        opStack = []
        variableValues = [:]
    }

    //undo the last operation
    func undoOp() -> (String?, Int)
    {
        if !opStack.isEmpty
        {
            opStack.removeLast()
            if !opStack.isEmpty
            {
                //get the last element
                let lastVal = opStack.removeLast()
                //if the last element is an operator, push back onto stack and return result
                switch lastVal{
                case .Variable(_):
                    return (evaluate(), 0)
                case .UnaryOperation(_, _):
                    opStack.append(lastVal)
                    return (evaluate(), 0)
                case .BinaryOperation(_, _, _):
                    opStack.append(lastVal)
                    return (evaluate(), 0)
                case .Operand(let number):
                    return ("\(number)", 1)
                }
            }
            //return nil
        }
        //future: pass a message that says nothing to undo?
        return (nil, 0)
    }
}