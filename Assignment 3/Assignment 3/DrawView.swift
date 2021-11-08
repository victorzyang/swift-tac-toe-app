//
//  DrawView.swift
//  Assignment 3
//
//  Created by Victor Yang on 2020-03-22.
//  Copyright © 2020 COMP2601. All rights reserved.
//

import Foundation
import UIKit

class DrawView: UIView{ //inherits from UIView
    var currentLine: Line? //currentLine is an optional
    var currentLines = [NSValue:Line]() //so we can draw multiple lines
    var finishedLines = [Line]() //finishedLines is an array of Line objects
    
    var boardHasBeenDrawn = false //determines if game board has been drawn
    
    //lines used for making the board game
    var upperHorizontalLine: Line?
    var lowerHorizontalLine: Line?
    var leftVerticalLine: Line?
    var rightVerticalLine: Line?
    
    var boardLines = [Line]()
    
    var firstCharIsX = false //determines if first character is an X or an O
    var player1Turn = true //always starts out as player 1's turn
    var player1Char = ""
    var player2Char = ""
    var player1Score = 0
    var player2Score = 0
    var gameIsOver = false
    
    var userDrawnLines = [Line]()
    var lastPoint = CGPoint.zero
    
    var firstPoint = CGPoint.zero
    var endPoint = CGPoint.zero
    var firstPoints = [CGPoint]()
    var endPoints = [CGPoint]()
    //var arrayOfChars = [Character]()
    var arrayOfChars = ["", "", "", "", "", "", "", "", ""]
    var hasGameStarted = false
        
    @IBInspectable var finishedLineColor: UIColor = UIColor.black{ //@IBInspectable keyword declares the var to be of a type whose value might be set in the inspector window of the interface builder
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var currentLineColor: UIColor = UIColor.red{
        didSet{
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineThickness: CGFloat = 10{
        didSet{
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.doubleTap(_:))) //the linking between the gesture recognizer and the action method that will be called is through the #selector()
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawView.tap(_:))) //second gesture recognizer that will allow a user to select a line by tapping on it
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer) //fixes the problem of firing both the tap and doubleTap gesture actions
        addGestureRecognizer(tapRecognizer)
    }
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer){
        print("I got a double tap")
        if(gameIsOver==true){ //only reset everything when the game is over
            userDrawnLines.removeAll(keepingCapacity: false)
            firstPoints.removeAll(keepingCapacity: false)
            endPoints.removeAll(keepingCapacity: false)
            boardLines.removeAll(keepingCapacity: false)
            arrayOfChars = ["", "", "", "", "", "", "", "", ""]
            hasGameStarted = false
            boardHasBeenDrawn = false
            player1Turn = true //resets so that it is player1's turn
            gameIsOver=false
            setNeedsDisplay()
        }
    }
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer){
        print("I got a tap")
        setNeedsDisplay()
    }
    
    func strokeLine(line: Line){
        //Use BezierPath to draw lines
        let path = UIBezierPath();
        path.lineWidth = lineThickness;
        path.lineCapStyle = CGLineCap.round;
        
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke(); //actually draw the path
    }
    
    func updateStatus(){ //print the status of the game to the output
        var gameBoard = "";
        for i in 0 ..< arrayOfChars.count{
            if(arrayOfChars[i]==""){
                gameBoard+=" "
            }
            gameBoard += arrayOfChars[i]
            
            if(i%3==2){
                gameBoard += "\n"
            }else{
                gameBoard += "|"
            }
        }
        print(gameBoard)
    }
    
    func printResults(player: Int){ //prints out which player won the round
        var player1Text = "Player 1 Score: "
        var player2Text = "Player 2 Score: "
        
        if(player==1){
            player1Score += 1
        }else if(player==2){
            player2Score += 1
        }
        
        player1Text += String(player1Score)
        player2Text += String(player2Score)
        
        let player1ResultStr : NSString = NSString(string: player1Text)
        let player2ResultStr : NSString = NSString(string: player2Text)
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        
        let attributes: NSDictionary = [
            NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            NSAttributedString.Key.paragraphStyle: paraStyle,
            NSAttributedString.Key.obliqueness: 0.1,
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!
        ]
        
        player1ResultStr.draw(in: CGRect(x: 10.0, y: 60.0, width: 300.0, height: 48.0), withAttributes: attributes as? [NSAttributedString.Key : Any])
        player2ResultStr.draw(in: CGRect(x: 10.0, y: 80.0, width: 300.0, height: 48.0), withAttributes: attributes as? [NSAttributedString.Key : Any])
    }
    
    func hasGameBeenWon(){ //checks if game has been won
        for i in 0 ..< 3{
            if (arrayOfChars[i*3]==(arrayOfChars[i*3+1]) && arrayOfChars[i*3]==(arrayOfChars[i*3+2]) && arrayOfChars[i*3]=="X") {
                //covers X's horizontal victories
                if(i==0){
                    strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: (upperHorizontalLine!.begin.y+leftVerticalLine!.begin.y)/2), end: CGPoint(x: upperHorizontalLine!.end.x, y: (upperHorizontalLine!.begin.y+leftVerticalLine!.begin.y)/2)))
                }else if(i==1){
                    strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: (upperHorizontalLine!.begin.y+lowerHorizontalLine!.begin.y)/2), end: CGPoint(x: upperHorizontalLine!.end.x, y: (upperHorizontalLine!.begin.y+lowerHorizontalLine!.begin.y)/2)))
                }else{
                    strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: (lowerHorizontalLine!.begin.y+leftVerticalLine!.end.y)/2), end: CGPoint(x: upperHorizontalLine!.end.x, y: (lowerHorizontalLine!.begin.y+leftVerticalLine!.end.y)/2)))
                }
                
                if(player1Char=="X"){
                    printResults(player: 1)
                }else{
                    printResults(player: 2)
                }
                gameIsOver = true
            } else if (arrayOfChars[i*3]==(arrayOfChars[i*3+1]) && arrayOfChars[i*3]==(arrayOfChars[i*3+2]) && arrayOfChars[i*3]=="O") {
                //covers O's horizontal victories
                if(i==0){
                    strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: (upperHorizontalLine!.begin.y+leftVerticalLine!.begin.y)/2), end: CGPoint(x: upperHorizontalLine!.end.x, y: (upperHorizontalLine!.begin.y+leftVerticalLine!.begin.y)/2)))
                }else if(i==1){
                    strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: (upperHorizontalLine!.begin.y+lowerHorizontalLine!.begin.y)/2), end: CGPoint(x: upperHorizontalLine!.end.x, y: (upperHorizontalLine!.begin.y+lowerHorizontalLine!.begin.y)/2)))
                }else{
                    strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: (lowerHorizontalLine!.begin.y+leftVerticalLine!.end.y)/2), end: CGPoint(x: upperHorizontalLine!.end.x, y: (lowerHorizontalLine!.begin.y+leftVerticalLine!.end.y)/2)))
                }
                
                if(player1Char=="O"){
                    printResults(player: 1)
                }else{
                    printResults(player: 2)
                }
                gameIsOver = true
            } else if (arrayOfChars[i]==(arrayOfChars[3+i]) && arrayOfChars[i]==(arrayOfChars[6+i]) && arrayOfChars[i]=="X") {
                //covers X's vertical victories
                if(i==0){
                    strokeLine(line: Line(begin: CGPoint(x: (upperHorizontalLine!.begin.x+leftVerticalLine!.begin.x)/2, y: leftVerticalLine!.begin.y), end: CGPoint(x: (upperHorizontalLine!.begin.x+leftVerticalLine!.begin.x)/2, y: leftVerticalLine!.end.y)))
                }else if(i==1){
                    strokeLine(line: Line(begin: CGPoint(x: (leftVerticalLine!.begin.x+rightVerticalLine!.begin.x)/2, y: leftVerticalLine!.begin.y), end: CGPoint(x: (leftVerticalLine!.begin.x+rightVerticalLine!.begin.x)/2, y: leftVerticalLine!.end.y)))
                }else{
                    strokeLine(line: Line(begin: CGPoint(x: (rightVerticalLine!.begin.x+upperHorizontalLine!.end.x)/2, y: leftVerticalLine!.begin.y), end: CGPoint(x: (rightVerticalLine!.begin.x+upperHorizontalLine!.end.x)/2, y: leftVerticalLine!.end.y)))
                }
                
                if(player1Char=="X"){
                    printResults(player: 1)
                }else{
                    printResults(player: 2)
                }
                gameIsOver = true
            } else if (arrayOfChars[i]==(arrayOfChars[3+i]) && arrayOfChars[i]==(arrayOfChars[6+i]) && arrayOfChars[i]=="O") {
                //covers O's vertical victories
                if(i==0){
                    strokeLine(line: Line(begin: CGPoint(x: (upperHorizontalLine!.begin.x+leftVerticalLine!.begin.x)/2, y: leftVerticalLine!.begin.y), end: CGPoint(x: (upperHorizontalLine!.begin.x+leftVerticalLine!.begin.x)/2, y: leftVerticalLine!.end.y)))
                }else if(i==1){
                    strokeLine(line: Line(begin: CGPoint(x: (leftVerticalLine!.begin.x+rightVerticalLine!.begin.x)/2, y: leftVerticalLine!.begin.y), end: CGPoint(x: (leftVerticalLine!.begin.x+rightVerticalLine!.begin.x)/2, y: leftVerticalLine!.end.y)))
                }else{
                    strokeLine(line: Line(begin: CGPoint(x: (rightVerticalLine!.begin.x+upperHorizontalLine!.end.x)/2, y: leftVerticalLine!.begin.y), end: CGPoint(x: (rightVerticalLine!.begin.x+upperHorizontalLine!.end.x)/2, y: leftVerticalLine!.end.y)))
                }
                
                if(player1Char=="O"){
                    printResults(player: 1)
                }else{
                    printResults(player: 2)
                }
                gameIsOver = true
            }
        }
        
        if(arrayOfChars[0]==(arrayOfChars[4])
                && arrayOfChars[0]==(arrayOfChars[8])
                && arrayOfChars[0]=="X"){
            //covers 1st X diagonal victory
            strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: leftVerticalLine!.begin.y), end: CGPoint(x: lowerHorizontalLine!.end.x, y: rightVerticalLine!.end.y)))
            
            if(player1Char=="X"){
                printResults(player: 1)
            }else{
                printResults(player: 2)
            }
            gameIsOver = true
        }

        if(arrayOfChars[0]==(arrayOfChars[4])
                && arrayOfChars[0]==arrayOfChars[8]
                && arrayOfChars[0]==("O")){
            //covers 1st O diagonal victory
            strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.begin.x, y: leftVerticalLine!.begin.y), end: CGPoint(x: lowerHorizontalLine!.end.x, y: rightVerticalLine!.end.y)))
            
            if(player1Char=="O"){
                printResults(player: 1)
            }else{
                printResults(player: 2)
            }
            gameIsOver = true
        }

        if(arrayOfChars[2]==(arrayOfChars[4])
                && arrayOfChars[2]==(arrayOfChars[6])
                && arrayOfChars[2]==("X")){
            //covers 2nd X diagonal victory
            strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.end.x, y: rightVerticalLine!.begin.y), end: CGPoint(x: lowerHorizontalLine!.begin.x, y: leftVerticalLine!.end.y)))
            
            if(player1Char=="X"){
                printResults(player: 1)
            }else{
                printResults(player: 2)
            }
            gameIsOver = true
        }

        if(arrayOfChars[2]==(arrayOfChars[4])
                && arrayOfChars[2]==(arrayOfChars[6])
                && arrayOfChars[2]=="O"){
            //covers 2nd O diagonal victory
            strokeLine(line: Line(begin: CGPoint(x: upperHorizontalLine!.end.x, y: rightVerticalLine!.begin.y), end: CGPoint(x: lowerHorizontalLine!.begin.x, y: leftVerticalLine!.end.y)))
            
            if(player1Char=="O"){
                printResults(player: 1)
            }else{
                printResults(player: 2)
            }
            gameIsOver = true
        }
        
        var isResultADraw = true;
        for char in 0 ..< arrayOfChars.count{
            if(arrayOfChars[char]==""){
                isResultADraw = false
            }
        }
        
        if(isResultADraw==true){
            printResults(player: 0)
            gameIsOver = true
            
            let drawLabel : NSString = "Draw"
            let paraStyle = NSMutableParagraphStyle()
            paraStyle.lineSpacing = 6.0
            
            let attributes: NSDictionary = [
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                NSAttributedString.Key.paragraphStyle: paraStyle,
                NSAttributedString.Key.obliqueness: 0.1,
                NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!
            ]
            drawLabel.draw(in: CGRect(x: 10.0, y: 100.0, width: 300.0, height: 48.0), withAttributes: attributes as? [NSAttributedString.Key : Any])
            //self.view.addSubview(drawLabel)
        }
    }
    
    func drawnWithinBorders(beginPoint: CGPoint, endPoint: CGPoint) -> Bool{
        if(beginPoint.x < leftVerticalLine!.begin.x && beginPoint.y < upperHorizontalLine!.begin.y){ //check if in top left corner
            if(arrayOfChars[0]=="" && player1Turn==true){
                arrayOfChars[0] = player1Char
                return true;
            }else if(arrayOfChars[0]=="" && player1Turn==false){
                arrayOfChars[0] = player2Char
                return true;
            }
        }else if(beginPoint.x > leftVerticalLine!.begin.x && beginPoint.x < rightVerticalLine!.begin.x && beginPoint.y < upperHorizontalLine!.begin.y){ //check if in middle column of top row
            if(arrayOfChars[1]=="" && player1Turn==true){
                arrayOfChars[1] = player1Char
                return true;
            }else if(arrayOfChars[1]=="" && player1Turn==false){
                arrayOfChars[1] = player2Char
                return true;
            }
        }else if(beginPoint.x > rightVerticalLine!.begin.x && beginPoint.y < upperHorizontalLine!.begin.y){ //check if in top right corner
            if(arrayOfChars[2]=="" && player1Turn==true){
                arrayOfChars[2] = player1Char
                return true;
            }else if(arrayOfChars[2]=="" && player1Turn==false){
                arrayOfChars[2] = player2Char
                return true;
            }
        }else if(beginPoint.x < leftVerticalLine!.begin.x && beginPoint.y > upperHorizontalLine!.begin.y && endPoint.y < lowerHorizontalLine!.begin.y){ //check if in left column of middle row
            if(arrayOfChars[3]=="" && player1Turn==true){
                arrayOfChars[3] = player1Char
                return true;
            }else if(arrayOfChars[3]=="" && player1Turn==false){
                arrayOfChars[3] = player2Char
                return true;
            }
        }else if(beginPoint.x > leftVerticalLine!.begin.x && beginPoint.x < rightVerticalLine!.begin.x && beginPoint.y > upperHorizontalLine!.begin.y && endPoint.y < lowerHorizontalLine!.begin.y){ //check if in middle column of middle row
            if(arrayOfChars[4]=="" && player1Turn==true){
                arrayOfChars[4] = player1Char
                return true;
            }else if(arrayOfChars[4]=="" && player1Turn==false){
                arrayOfChars[4] = player2Char
                return true;
            }
        }else if(beginPoint.x > rightVerticalLine!.begin.x && beginPoint.y > upperHorizontalLine!.begin.y && endPoint.y < lowerHorizontalLine!.begin.y){ //check if in right column of middle row
            if(arrayOfChars[5]=="" && player1Turn==true){
                arrayOfChars[5] = player1Char
                return true;
            }else if(arrayOfChars[5]=="" && player1Turn==false){
                arrayOfChars[5] = player2Char
                return true;
            }
        }else if(beginPoint.x < leftVerticalLine!.begin.x && beginPoint.y > lowerHorizontalLine!.begin.y){ //check if in bottom left corner
            if(arrayOfChars[6]=="" && player1Turn==true){
                arrayOfChars[6] = player1Char
                return true;
            }else if(arrayOfChars[6]=="" && player1Turn==false){
                arrayOfChars[6] = player2Char
                return true;
            }
        }else if(beginPoint.x > leftVerticalLine!.begin.x && beginPoint.x < rightVerticalLine!.begin.x && beginPoint.y > lowerHorizontalLine!.begin.y){ //check if in middle column of bottom row
            if(arrayOfChars[7]=="" && player1Turn==true){
                arrayOfChars[7] = player1Char
                return true;
            }else if(arrayOfChars[7]=="" && player1Turn==false){
                arrayOfChars[7] = player2Char
                return true;
            }
        }else if(beginPoint.x > rightVerticalLine!.begin.x && beginPoint.y > lowerHorizontalLine!.begin.y){ //check if in bottom right corner
            if(arrayOfChars[8]=="" && player1Turn==true){
                arrayOfChars[8] = player1Char
                return true;
            }else if(arrayOfChars[8]=="" && player1Turn==false){
                arrayOfChars[8] = player2Char
                return true;
            }
        }
        return false;
    }
    
    func compareHorizontalLines(line1: Line, line2: Line) -> Bool{
        if(((abs(line1.begin.x-line2.begin.x) <= 5 && abs(line1.end.x-line2.end.x) <= 5) || (abs(line1.begin.x-line2.end.x) <= 5 && abs(line1.end.x-line2.begin.x) <= 5)) && ((abs(line1.begin.y-line2.begin.y) <= abs(line1.end.y-line2.end.y)+2) || ((abs(line1.begin.y-line2.end.y) <= abs(line1.end.y-line2.begin.y)+2)))){
                return true;
        }
        return false;
    }
    
    func compareVerticalLines(vLine1: Line, vLine2: Line, hLine1: Line, hLine2: Line) -> Bool{
        if((abs(vLine1.begin.y-vLine2.begin.y) <= 5 && abs(vLine1.end.y-vLine2.end.y) <= 5) || (abs(vLine1.begin.y-vLine2.end.y) <= 5 && abs(vLine1.end.y-vLine2.begin.y) <= 5)){
            
            print("Condition 1 for vertical lines is satisfied") //debug
            
            if(((vLine1.begin.x >= hLine1.begin.x && vLine1.begin.x <= hLine1.end.x) || (vLine1.begin.x >= hLine1.end.x && vLine1.begin.x <= hLine1.begin.x)) && (vLine1.begin.y < hLine1.begin.y) && (vLine1.end.y > hLine2.begin.y) && (((vLine2.begin.x >= hLine1.begin.x) && (vLine2.begin.x <= hLine1.end.x)) || ((vLine2.begin.x >= hLine1.end.x) && (vLine2.begin.x <= hLine1.begin.x))) && (vLine2.begin.y < hLine1.begin.y) && (vLine2.end.y > hLine2.begin.y)){
                
                print("Condition 2 for vertical lines is satisfied") //debug
                if(((vLine2.begin.x-vLine1.begin.x <= (vLine2.end.x-vLine1.end.x)+2) || ((vLine2.begin.x-vLine1.end.x <= (vLine2.end.x-vLine1.begin.x)+2)))){
                    
                        print("Condition 3 for vertical lines is satisfied") //debug
                        return true;
                }
                
            }
        }
        
        return false;
    }
    
    override func draw(_ rect: CGRect) {
        
        //print(boardHasBeenDrawn); //debugging
        
        guard let context = UIGraphicsGetCurrentContext() else{
            return
        }
        
        if(boardHasBeenDrawn == false){
            //draw the finished lines
            finishedLineColor.setStroke() //set colour to draw
            for line in finishedLines{
                strokeLine(line: line);
            }
            
            //draw current line if it exists
            /*if let line = currentLine{
            }*/
            for (_,line) in currentLines{
                currentLineColor.setStroke()
                strokeLine(line: line)
            }
            
            if(finishedLines.count > 0){
                for i in 0 ..< finishedLines.count-1{
                    for j in i+1 ..< finishedLines.count{
                        let horizontalLine1 = finishedLines[i];
                        let horizontalLine2 = finishedLines[j];
                        
                        //first check the horizontal lines
                        if(compareHorizontalLines(line1: horizontalLine1, line2: horizontalLine2)==true){
                            //print("These are horizontal lines")
                            for a in 0 ..< finishedLines.count-1{
                                for b in a+1 ..< finishedLines.count{
                                    let verticalLine1 = finishedLines[a];
                                    let verticalLine2 = finishedLines[b];
                                    
                                    //then check the vertical lines
                                    if(compareVerticalLines(vLine1: verticalLine1, vLine2: verticalLine2, hLine1: horizontalLine1, hLine2: horizontalLine2)==true){
                                            print("These are vertical lines")
                                            boardHasBeenDrawn = true;
                                            if(horizontalLine2.begin.y-horizontalLine1.begin.y > 0){
                                                if(horizontalLine1.begin.x<horizontalLine1.end.x){
                                                    upperHorizontalLine = horizontalLine1
                                                }else{
                                                    upperHorizontalLine = Line(begin: CGPoint(x: horizontalLine1.end.x, y: horizontalLine1.end.y), end: CGPoint(x: horizontalLine1.begin.x, y: horizontalLine1.begin.y))
                                                }
                                                
                                                if(horizontalLine2.begin.x<horizontalLine2.end.x){
                                                    lowerHorizontalLine = horizontalLine2
                                                }else{
                                                    lowerHorizontalLine = Line(begin: CGPoint(x: horizontalLine2.end.x, y: horizontalLine2.end.y), end: CGPoint(x: horizontalLine2.begin.x, y: horizontalLine2.begin.y))
                                                }
                                                
                                            }else{
                                                if(horizontalLine2.begin.x<horizontalLine2.end.x){
                                                    upperHorizontalLine = horizontalLine2
                                                }else{
                                                    upperHorizontalLine = Line(begin: CGPoint(x: horizontalLine2.end.x, y: horizontalLine2.end.y), end: CGPoint(x: horizontalLine2.begin.x, y: horizontalLine2.begin.y))
                                                }
                                                
                                                if(horizontalLine1.begin.x<horizontalLine1.end.x){
                                                    lowerHorizontalLine = horizontalLine1
                                                }else{
                                                    lowerHorizontalLine = Line(begin: CGPoint(x: horizontalLine1.end.x, y: horizontalLine1.end.y), end: CGPoint(x: horizontalLine1.begin.x, y: horizontalLine1.begin.y))
                                                }
                                                
                                            }
                                        
                                            if(verticalLine2.begin.x-verticalLine1.begin.x > 0){
                                                if(verticalLine1.begin.y<verticalLine1.end.y){
                                                    leftVerticalLine = verticalLine1
                                                }else{
                                                    leftVerticalLine = Line(begin: CGPoint(x: verticalLine1.end.x, y: verticalLine1.end.y), end: CGPoint(x: verticalLine1.begin.x, y: verticalLine1.begin.y))
                                                }
                                                
                                                if(verticalLine2.begin.y<verticalLine2.end.y){
                                                    rightVerticalLine = verticalLine2
                                                }else{
                                                    rightVerticalLine = Line(begin: CGPoint(x: verticalLine2.end.x, y: verticalLine2.end.y), end: CGPoint(x: verticalLine2.begin.x, y: verticalLine2.begin.y))
                                                }
                                                
                                            }else{
                                                if(verticalLine2.begin.y<verticalLine2.end.y){
                                                    leftVerticalLine = verticalLine2
                                                }else{
                                                    leftVerticalLine = Line(begin: CGPoint(x: verticalLine2.end.x, y: verticalLine2.end.y), end: CGPoint(x: verticalLine2.begin.x, y: verticalLine2.begin.y))
                                                }
                                                
                                                if(verticalLine1.begin.y<verticalLine1.end.y){
                                                    rightVerticalLine = verticalLine1
                                                }else{
                                                    rightVerticalLine = Line(begin: CGPoint(x: verticalLine1.end.x, y: verticalLine1.end.y), end: CGPoint(x: verticalLine1.begin.x, y: verticalLine1.begin.y))
                                                }
                                                
                                            }
                                        
                                            boardLines.append(upperHorizontalLine!)
                                            boardLines.append(lowerHorizontalLine!)
                                            boardLines.append(leftVerticalLine!)
                                            boardLines.append(rightVerticalLine!)
                                            
                                            print("\t|\t|\t");
                                            print("\t|\t|\t");
                                            print("\t|\t|\t");
                                            break;
                                    }
                                }
                                if(boardHasBeenDrawn==true){
                                    break;
                                }
                            }
                            if(boardHasBeenDrawn==true){
                                break;
                            }
                        }
                        
                        if(boardHasBeenDrawn==true){
                            break;
                        }
                    }
                }
            }
            
        }else{ //enable user to draw either an X or an O
            
            for line in userDrawnLines{
                context.move(to: line.begin) //draw line from last point to current point
                context.addLine(to: line.end)
            }
            
            context.strokePath()
            
            /*strokeLine(line: upperHorizontalLine!)
            strokeLine(line: lowerHorizontalLine!)
            strokeLine(line: leftVerticalLine!)
            strokeLine(line: rightVerticalLine!)*/
            
            for i in 0 ..< boardLines.count{
                strokeLine(line: boardLines[i])
            }
            
            /*print("Upper horizontal line is: ")
            print(upperHorizontalLine!.begin)
            print(upperHorizontalLine!.end)
            print("Lower horizontal line is: ")
            print(lowerHorizontalLine!.begin)
            print(lowerHorizontalLine!.end)
            print("Left vertical line is: ")
            print(leftVerticalLine!.begin)
            print(leftVerticalLine!.end)
            print("Right vertical line is: ")
            print(rightVerticalLine!.begin)
            print(rightVerticalLine!.end)*/
            
            if(firstPoints.count > 0 && firstPoints.count==endPoints.count){
                var nextPlayerCanGo = false;
                var isCharValid = false;
                var removePointsForX = false;
                
                for i in 0 ..< firstPoints.count{
                    if(abs(firstPoints[i].x-endPoints[i].x) <= 2 && abs(firstPoints[i].y-endPoints[i].y) <= 2){ //determines if a circle is drawn
                        print("A circle has been drawn")
                        if(hasGameStarted==false || (player1Turn==true && player1Char=="O") || (player1Turn==false && player2Char=="O")){
                            if(hasGameStarted==false){
                                player1Char = "O";
                                player2Char = "X";
                                hasGameStarted = true
                            }
                            if(drawnWithinBorders(beginPoint: firstPoints[i], endPoint: endPoints[i]) == true){ //determines if O was drawn in game board
                                    
                                    firstPoints.remove(at: i)
                                    endPoints.remove(at: i)
                                    player1Turn = !player1Turn;
                                    break;
                            }
                        }
                    }else{
                        if(abs(firstPoints[i].x-endPoints[i].x) > 1 && abs(firstPoints[i].y-endPoints[i].y) > 1){ //determine if a line is drawn for an X
                            print("A possible line for X has been drawn")
                            isCharValid = true;
                            for j in i+1 ..< firstPoints.count{
                                if((abs(firstPoints[i].x-firstPoints[j].x) <= 5 && abs(endPoints[i].x-endPoints[j].x) <= 5) || (abs(firstPoints[i].x-endPoints[j].x) <= 5 && abs(endPoints[i].x-firstPoints[j].x) <= 5)){ //determines if an X is drawn
                                    print("An X has been drawn")
                                    if(hasGameStarted==false || (player1Turn==true && player1Char=="X") || (player1Turn==false && player2Char=="X")){
                                        if(hasGameStarted==false){
                                            player1Char = "X"
                                            player2Char = "O"
                                            hasGameStarted = true
                                        }
                                        if(drawnWithinBorders(beginPoint: firstPoints[i], endPoint: endPoints[i]) == true){
                                                removePointsForX=true;
                                                
                                                player1Turn = !player1Turn;
                                                nextPlayerCanGo = true
                                                //remove elements from array if "successful"
                                                break;
                                        }
                                    }
                                }
                                if(removePointsForX==true){
                                    firstPoints.remove(at: i)
                                    endPoints.remove(at: i)
                                    firstPoints.remove(at: j-1)
                                    endPoints.remove(at: j-1)
                                    removePointsForX = false
                                }
                            }
                            
                        }
                        
                    }
                    if(nextPlayerCanGo==false && isCharValid==false){
                        firstPoints.remove(at: i) //remove points if user draws something invalid
                        endPoints.remove(at: i)
                    }
                }
            }
            updateStatus() //updates game board on output each time
            hasGameBeenWon()
        }
        
    }
    
    //Should change up the following override touch functions for drawing lines and circles
    
    //Override Touch Functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function) //for debugging
        for touch in touches{
            let location = touch.location(in: self); //get location in view co-ordinate
            if(boardHasBeenDrawn == false){
                let newLine = Line(begin: location, end: location)
                let key = NSValue(nonretainedObject: touch)
                currentLines[key] = newLine
            }else{
                //print("Debugging");
                //currentLine = Line(begin: location, end: location); //draw a line
                lastPoint = location
                print(lastPoint)
                firstPoints.append(location)
            }
        }
        /*let touch = touches.first!; //get first touch event and unwrap optional
        let location = touch.location(in: self); //get location in view co-ordinate
        */
        setNeedsDisplay(); //this view needs to be updated
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print(#function) //for debugging
        for touch in touches{
            let location = touch.location(in: self);
            if(boardHasBeenDrawn == false){
                let key = NSValue(nonretainedObject: touch)
                currentLines[key]!.end = location //updates the end location
                setNeedsDisplay(); //this view needs to be updated
            }else{
                print("Debugging");
                currentLine = Line(begin: lastPoint, end: location)
                finishedLines.append(currentLine!)
                userDrawnLines.append(currentLine!)
                lastPoint = location
                
                setNeedsDisplay(); //this view needs to be updated
            }
        }
        /*let touch = touches.first!;
        let location = touch.location(in: self);
        if(boardHasBeenDrawn == false){
            currentLine!.end = location; //updates the end location
        }*/
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function) //for debugging
        for touch in touches{
            let location = touch.location(in: self);
            if(boardHasBeenDrawn == false){
                let key = NSValue(nonretainedObject: touch);
                currentLines[key] = Line(begin: currentLines[key]!.begin, end: location);
                if(currentLines[key] != nil){
                    finishedLines.append(currentLines[key]!)
                    currentLines.removeValue(forKey: key)
                }
            }else{
                print("Debugging");
                currentLine = Line(begin: currentLine!.begin, end: location);
                if(currentLine != nil){
                    finishedLines.append(currentLine!)
                    userDrawnLines.append(currentLine!)
                    print(location)
                    endPoints.append(location)
                }
            }
        }
        //let touch = touches.first!;
        //let location = touch.location(in: self);
        print("Has board been drawn?");
        print(boardHasBeenDrawn);
        setNeedsDisplay(); //this view needs to be updated
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        print(#function) //for debugging
        _=finishedLines.popLast();
        //finishedLines.removeLast()
        _=userDrawnLines.popLast()
        firstPoints.removeLast()
        endPoints.removeLast()
        _=boardLines.popLast()
    }
}
