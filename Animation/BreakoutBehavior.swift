//
//  BreakoutBehavior.swift
//  Animation
//
//  Created by Sanjib Ahmad on 2/17/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior {
    lazy var collidor: UICollisionBehavior = {
        let lazilyCreatedCollisionBehavior = UICollisionBehavior()
//        lazilyCreatedCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        return lazilyCreatedCollisionBehavior
    }()
    
    lazy var gravity: UIGravityBehavior = {
        let lazilyCreatedGravityBehavior = UIGravityBehavior()
        lazilyCreatedGravityBehavior.magnitude = 0.1
        return lazilyCreatedGravityBehavior
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.elasticity = 1.0
        lazilyCreatedBallBehavior.resistance = 0
        lazilyCreatedBallBehavior.friction = 0.5
        lazilyCreatedBallBehavior.allowsRotation = true
        return lazilyCreatedBallBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collidor)
        addChildBehavior(ballBehavior)
    }
    
    // MARK: - Boundaries
    
    func addBoundary(path: UIBezierPath, named name: String) {
        collidor.removeBoundaryWithIdentifier(name)
        collidor.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBoundary(named name: String) {
        collidor.removeBoundaryWithIdentifier(name)
    }
    
    // MARK: - Ball
    
    func pushBall(ball: Ball) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        let linearVelocity = ballBehavior.linearVelocityForItem(ball)
        
        // If the device screen resolution height is too large, 
        // the default magnitude 0.1 will not cause the ball to 
        // have enough velocity to reach the bricks or even if
        // it does, will result in poor gameplay
        // iPhone   5, 5s   320 × 568
        //          6       375 × 667
        //          6+      414 × 736
        // iPad     2       1024 x 768
        //          Air     2048 x 1536
        //          Pro     2732 x 2048
        
        let referenceViewHeight = dynamicAnimator?.referenceView?.bounds.size.height
        if referenceViewHeight > 568 {
            pushBehavior.magnitude = 0.2
        } else if referenceViewHeight > 736 {
            pushBehavior.magnitude = 0.3
        } else if referenceViewHeight > 768 {
            pushBehavior.magnitude = 0.35
        } else if referenceViewHeight > 1536 {
            pushBehavior.magnitude = 0.4
        } else {
            pushBehavior.magnitude = 0.15
        }
        
        // linearVelocity zero means ball at resting state on paddle
        if linearVelocity == CGPointZero {
            let lower =  CGFloat(((90-15) * M_PI)/180)
            let upper = CGFloat(((90+15) * M_PI)/180)
            pushBehavior.angle = CGFloat.randomRadian(lower, upper)
        } else {
            // derive the opposite angle from current velocity
            let currentAngle = Double(atan2(linearVelocity.y, linearVelocity.x));
            let oppositeAngle = CGFloat((currentAngle + M_PI) % (2 * M_PI))
            
            // add 30 degrees variation for random
            let lower = oppositeAngle - CGFloat.degreeToRadian(30)
            let upper = oppositeAngle + CGFloat.degreeToRadian(30)
            pushBehavior.angle = CGFloat.randomRadian(lower, upper)
        }
        
        // when push behavior is done acting on its item [ball], remove it from its animator
        // since we don't need it anymore; however since the action captures a pointer back 
        // to itself (pushBehavior), should avoid memory cycle with [unowned pushBehavior]
        pushBehavior.action = { [unowned pushBehavior] in
            pushBehavior.removeItem(ball)
            pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)        
    }
    
    func addBall(ball: UIView) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        gravity.addItem(ball)
        collidor.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: UIView) {
        gravity.removeItem(ball)
        collidor.removeItem(ball)
        ballBehavior.removeItem(ball)
        ball.removeFromSuperview()        
    }
}

private extension CGFloat {
    static func randomRadian(lower: CGFloat = 0, _ upper: CGFloat = CGFloat(2 * M_PI)) -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (upper - lower) + lower
    }
    
    static func degreeToRadian(degree: Double) -> CGFloat {
        return CGFloat((degree * M_PI)/180)
    }
}
