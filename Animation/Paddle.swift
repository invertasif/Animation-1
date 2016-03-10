//
//  Paddle.swift
//  Animation
//
//  Created by Sanjib Ahmad on 3/3/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import Foundation

class Paddle: UIImageView {
    private let minAcceptableSpeed = 8
    private let maxAcceptableSpeed = 200
    private let minAcceptableWidth = 20
    private let maxAcceptableWidth = 200
    private let height = 15.0
    
    // width and speed vars are set as implicity unwrapped optionals
    // these depend on referenceView and we are guaranteeing that they
    // will be set during initialization
    // speed is measured in points of the referenceView (UIView)
    private var currentSpeed: Int!
    private var availableSpeed: [Int]!
    private var currentWidth: Int!
    private var availableWidth: [Int]!    
    private var referenceView: UIView!
    
    init(referenceView: UIView) {
        super.init(frame: CGRectZero)
        self.referenceView = referenceView
        
        backgroundColor = UIColor(red: 102/255.0, green: 153/255.0, blue: 204/255.0, alpha: 1.0)
        layer.cornerRadius = CGFloat(height / 2.5)
        
        layer.borderColor = UIColor(red: 0/255.0, green: 51/255.0, blue: 102/255.0, alpha: 1.0).CGColor
        layer.borderWidth = 1.7
        
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move(velocity: CGPoint) {
        UIView.animateWithDuration(0.0,
            delay: 0.0,
            options: [UIViewAnimationOptions.AllowUserInteraction, UIViewAnimationOptions.CurveEaseIn],
            animations: {
                self.center = self.getCenterForVelocity(velocity)
            },
            completion: nil
        )
    }
    
    private func getCenterForVelocity(velocity: CGPoint) -> CGPoint {
        var newCenter = CGPoint(x: self.center.x + velocity.x/20, y: self.center.y)
        
        let paddleLeftEdgeAtNewCenter = floor(newCenter.x - CGFloat(currentWidth/2))
        let paddleRightEdgeAtNewCenter = ceil(newCenter.x + CGFloat(currentWidth/2))
        
        let referenceViewLeftEdge = floor(referenceView.bounds.origin.x)
        let referenceViewRightEdge = ceil(referenceView.bounds.width)
        
        if paddleLeftEdgeAtNewCenter <= referenceViewLeftEdge {
            newCenter.x = floor(CGFloat(currentWidth/2))
        } else if paddleRightEdgeAtNewCenter >= referenceViewRightEdge {
            newCenter.x = ceil(referenceView.bounds.width - CGFloat(currentWidth/2))
        }
        return newCenter
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
    
    func setDefaultWidth() {
        // picking an approx mid value from availableWidth
        // ceil produces best results for paddle width after testing on various devices
        let approxMidIndex = Int(ceil(Double(availableWidth.count-1)/2))
        currentWidth = availableWidth[approxMidIndex]
    }
    
    func setDefaultSpeed() {
        currentSpeed = availableSpeed[0]
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