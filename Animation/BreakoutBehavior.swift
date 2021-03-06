//
//  BreakoutBehavior.swift
//  Animation
//
//  Created by Sanjib Ahmad on 2/17/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

// Hints
// 8. You might find it good for the clarity of your code to create 
// a BreakoutBehavior subclass of UIDynamicBehavior which uses 
// addChildBehavior to add the collision behavior, dynamic item 
// behavior, et. al., to itself.

class BreakoutBehavior: UIDynamicBehavior {

    // Hints
    // 9. Your BreakoutBehavior could manage lots of behavior-oriented 
    // stuff like the push, the brick and paddle boundaries, and the 
    // behavior of the bouncing ball(s).
    
    lazy var collidor: UICollisionBehavior = {
        let lazilyCreatedCollisionBehavior = UICollisionBehavior()
        return lazilyCreatedCollisionBehavior
    }()
    
    lazy var gravity: UIGravityBehavior = {
        let lazilyCreatedGravityBehavior = UIGravityBehavior()
        
        lazilyCreatedGravityBehavior.magnitude = UserSettings.sharedInstance.gravity
        lazilyCreatedGravityBehavior.gravityDirection = CGVector(dx: 0.0, dy: UserSettings.sharedInstance.gravity * 0.5)
        return lazilyCreatedGravityBehavior
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.elasticity = UserSettings.sharedInstance.elasticity
        lazilyCreatedBallBehavior.resistance = 0.0
        lazilyCreatedBallBehavior.friction = 0.1
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
    
    private struct Device {
        struct iPhone5s {
            static let Width: CGFloat = 320.0
            static let Height: CGFloat = 568.0
        }
        struct iPhone6 {
            static let Width: CGFloat = 375.0
            static let Height: CGFloat = 667.0
        }
        struct iPhone6Plus {
            static let Width: CGFloat = 414.0
            static let Height: CGFloat = 736.0
        }
        struct iPad2 {
            static let Width: CGFloat = 768.0
            static let Height: CGFloat = 1024.0
        }
        struct iPadAir {
            static let Width: CGFloat = 1536.0
            static let Height: CGFloat = 2048.0
        }
        struct iPadPro {
            static let Width: CGFloat = 2048.0
            static let Height: CGFloat = 2732.0
        }
    }
    
    // MARK: - Ball
    
    // Hints
    // 15. The push that your tap gesture must generate is just an instantaneous 
    // UIPushBehavior, nothing more. You’ll have to set it up with an appropriate 
    // magnitude for the size of your bouncing ball.
    
    func pushBall(ball: Ball) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        let linearVelocity = ballBehavior.linearVelocityForItem(ball)
        
        let referenceViewHeight = dynamicAnimator?.referenceView?.bounds.size.height
        if referenceViewHeight > Device.iPhone5s.Height {
            pushBehavior.magnitude = 0.2
        } else if referenceViewHeight > Device.iPhone6Plus.Height {
            pushBehavior.magnitude = 0.3
        } else if referenceViewHeight > Device.iPad2.Height {
            pushBehavior.magnitude = 0.35
        } else if referenceViewHeight > Device.iPadAir.Height {
            pushBehavior.magnitude = 0.4
        } else {
            pushBehavior.magnitude = 0.15
        }
        
        // derive the opposite angle from current velocity
        let currentAngle = Double(atan2(linearVelocity.y, linearVelocity.x))
        let oppositeAngle = CGFloat((currentAngle + M_PI) % (2 * M_PI))
        
        // add 30 degrees variation for random
        let lower = oppositeAngle - CGFloat.degreeToRadian(30)
        let upper = oppositeAngle + CGFloat.degreeToRadian(30)
        pushBehavior.angle = CGFloat.randomRadian(lower, upper)
        
        // when push behavior is done acting on its item [ball], remove it from its animator
        // since we don't need it anymore; however since the action captures a pointer back 
        // to itself (pushBehavior), should avoid memory cycle with [unowned pushBehavior]
        pushBehavior.action = { [unowned pushBehavior] in
            pushBehavior.removeItem(ball)
            pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)        
    }
    
    func pushRestoredBall(ball: Ball) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        
        if let linearVelocity = ball.linearVelocity where linearVelocity != CGPointZero {
            pushBehavior.magnitude = 0.1
            
            pushBehavior.angle = CGFloat(atan2(linearVelocity.y, linearVelocity.x))
            
            pushBehavior.action = { [unowned pushBehavior] in
                pushBehavior.removeItem(ball)
                pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
            }
            addChildBehavior(pushBehavior)
        }
    }
    
    func pushBallFromPaddle(ball: Ball) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        
        let referenceViewHeight = dynamicAnimator?.referenceView?.bounds.size.height
        if referenceViewHeight > Device.iPhone5s.Height {
            pushBehavior.magnitude = 0.2
        } else if referenceViewHeight > Device.iPhone6Plus.Height {
            pushBehavior.magnitude = 0.3
        } else if referenceViewHeight > Device.iPad2.Height {
            pushBehavior.magnitude = 0.35
        } else if referenceViewHeight > Device.iPadAir.Height {
            pushBehavior.magnitude = 0.4
        } else {
            pushBehavior.magnitude = 0.15
        }
        
        let lower =  CGFloat(((90-15) * M_PI)/180)
        let upper = CGFloat(((90+15) * M_PI)/180)
        pushBehavior.angle = CGFloat.randomRadian(lower, upper)
        
        pushBehavior.action = { [unowned pushBehavior] in
            pushBehavior.removeItem(ball)
            pushBehavior.dynamicAnimator?.removeBehavior(pushBehavior)
        }
        addChildBehavior(pushBehavior)
    }
    
    func addBall(ball: Ball) {
        dynamicAnimator?.referenceView?.addSubview(ball)
        gravity.addItem(ball)
        collidor.addItem(ball)
        ballBehavior.addItem(ball)
    }
    
    func removeBall(ball: Ball) {
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
