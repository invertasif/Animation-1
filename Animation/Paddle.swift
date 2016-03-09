//
//  Paddle.swift
//  Animation
//
//  Created by Sanjib Ahmad on 3/3/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import Foundation

class Paddle: UIView {
    private let minAcceptableSpeed = 5
    private let maxAcceptableSpeed = 200
    private let minAcceptableWidth = 20
    private let maxAcceptableWidth = 200
    private let height: Int = 15
    
    // width and speed vars are set as implicity unwrapped optionals
    // these depend on referenceView and we are guaranteeing that they
    // will be set during initialization
    // speed is measured in points of the referenceView (UIView)
    private var currentSpeed: Int!
    private var availableSpeed: [Int]!
    private var currentWidth: Int!
    private var availableWidth: [Int]!
    
    private let color = UIColor.greenColor()    
    private var referenceView: UIView!
    
    init(referenceView: UIView) {
        super.init(frame: CGRectZero)
        
        self.referenceView = referenceView
        
        // init width first, because speed will depend on width
        // width:
        initAvailableWidth()
        setDefaultWidth()
        // speed:
        initAvailableSpeed()
        setDefaultSpeed()
        
        print("availableWidth: \(availableWidth)")
        print("availableSpeed: \(availableSpeed)")
        
        print("current width: \(currentWidth)")
        print("current speed: \(currentSpeed)")
        
        frame = CGRect(origin: CGPointZero, size: CGSize(width: Double(currentWidth), height: Double(height)))
        
        // divide referenceView width by 2 to get the center position
        // that's where the paddle should be approximately centered
        // the paddle width is a factor of referenceView width so the exact
        // position is derived by getOriginXFromCenterX
        frame.origin.x = getOriginXFromCenterX(referenceView.bounds.size.width/2)
        frame.origin.y = referenceView.bounds.size.height - CGFloat(height)
        
        backgroundColor = color
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveLeft() {
        guard canPaddleMoveLeft() else { return }
        UIView.animateWithDuration(0.0,
            delay: 0.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.center = CGPoint(x: self.center.x - CGFloat(self.currentSpeed), y: self.center.y)
            },
            completion: nil
        )
    }
    
    func moveRight() {
        guard canPaddleMoveRight() else { return }
        UIView.animateWithDuration(0.0,
            delay: 0.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                self.center = CGPoint(x: self.center.x + CGFloat(self.currentSpeed), y: self.center.y)
            },
            completion: nil
        )
    }
    
    func decreaseSpeed() {
        if let currentIndex = availableSpeed.indexOf(currentSpeed) where currentIndex - 1 >= 0 {
            currentSpeed = availableSpeed[currentIndex-1]
        }
    }
    
    func increaseSpeed() {
        if let currentIndex = availableSpeed.indexOf(currentSpeed) where currentIndex + 1 <= availableSpeed.count - 1 {
            currentSpeed = availableSpeed[currentIndex+1]
        }
    }
    
    func decreaseWidth() {
        if let currentIndex = availableWidth.indexOf(currentWidth) where currentIndex - 1 >= 0 {
            currentWidth = availableWidth[currentIndex-1]
            initAvailableSpeed()
            setDefaultSpeed()
            resizePaddle()
        }
    }
    
    func increaseWidth() {
        if let currentIndex = availableWidth.indexOf(currentWidth) where currentIndex + 1 <= availableWidth.count - 1 {
            currentWidth = availableWidth[currentIndex+1]
            initAvailableSpeed()
            setDefaultSpeed()
            resizePaddle()
        }
    }
    
    private func resizePaddle() {
        let centerBeforeWidthChange = center
        let originBeforeWidthChange = frame.origin
        frame = CGRect(origin: CGPointZero, size: CGSize(width: Double(currentWidth), height: Double(height)))
        frame.origin.x = getOriginXFromCenterX(centerBeforeWidthChange.x)
        frame.origin.y = originBeforeWidthChange.y
    }
    
    func setRandomWidth() {
        currentWidth = availableWidth[availableWidth.count.random()]
    }
    
    func setRandomSpeed() {
        currentSpeed = availableSpeed[availableSpeed.count.random()]
    }
    
    func setDefaultWidth() {
        // picking an approx mid value from availableWidth
        // ceil produces best results for paddle width after testing on various devices
        let approxMidIndex = Int(ceil(Double(availableWidth.count-1)/2))
        currentWidth = availableWidth[approxMidIndex]
    }
    
    func setDefaultSpeed() {
        // picking an approx mid value from availableSpeeed
        // floor produces best results for paddle speed after testing on various devices
        let approxMidIndex = Int(floor(Double(availableSpeed.count-1)/2))
        currentSpeed = availableSpeed[approxMidIndex]
        
//        currentSpeed = availableSpeed[0]
        currentSpeed = 12
        
    }
    
    private func initAvailableWidth() {
        var availableWidth = [Int]()
        for width in Int(referenceView.bounds.size.width).factors() {
            if minAcceptableWidth...maxAcceptableWidth ~= width {
                availableWidth.append(width)
            }
        }
        self.availableWidth = availableWidth
    }
    
    private func initAvailableSpeed() {
        var availableSpeed = [Int]()
        for speed in currentWidth.factors() {
            if minAcceptableSpeed...maxAcceptableSpeed ~= speed {
                availableSpeed.append(speed)
            }
        }
        self.availableSpeed = availableSpeed
    }
    
    private func canPaddleMoveLeft() -> Bool {
        let paddleLeftEdge = floor(center.x - CGFloat(currentWidth/2))
        let referenceViewLeftEdge = floor(referenceView.bounds.origin.x)
        if paddleLeftEdge <= referenceViewLeftEdge {
            return false
        }
        return true
    }
    
    private func canPaddleMoveRight() -> Bool {
        let paddleRightEdge = ceil(center.x + CGFloat(currentWidth/2))
        let referenceViewRightEdge = ceil(referenceView.bounds.width)
        if paddleRightEdge >= referenceViewRightEdge {
            return false
        }
        return true
    }
    
    private func getOriginXFromCenterX(centerX: CGFloat) -> CGFloat {
        let numberOfPaddleWidthsThatCoverReferenceViewWidth = referenceView.bounds.size.width / CGFloat(currentWidth)
        
        return floor(numberOfPaddleWidthsThatCoverReferenceViewWidth / (referenceView.bounds.width/centerX)) * CGFloat(currentWidth)
    }
}

private extension Int {
    func random() -> Int {
        return Int(arc4random() % UInt32(self))
    }
    
    func factors(currentStep currentStep: Int = 1, var steps: [Int] = [Int]()) -> [Int] {
        if currentStep == self {
            steps.append(currentStep)
        } else {
            if self % currentStep == 0 {
                steps.append(currentStep)
            }
            return factors(currentStep: currentStep + 1, steps: steps)
        }
        return steps
    }
}