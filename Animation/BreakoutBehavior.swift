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
        return lazilyCreatedCollisionBehavior
    }()
    
    lazy var gravity: UIGravityBehavior = {
        let lazilyCreatedGravityBehavior = UIGravityBehavior()
        lazilyCreatedGravityBehavior.magnitude = 0.3
        return lazilyCreatedGravityBehavior
    }()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.elasticity = 1.0
        lazilyCreatedBallBehavior.resistance = 0
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
    
    func pushBall(ball: UIView) {
        let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = 0.1
        
        if ballBehavior.angularVelocityForItem(ball) > 0 {
            pushBehavior.angle = -CGFloat.randomRadian()
        } else {
            pushBehavior.angle = CGFloat.randomRadian()
        }
                
        // when push behavior is done acting on its item [ball], remove it from its animator
        // since we don't need it anymore; however since the action captures a pointer back 
        // to itself (pushBehavior), should avoid memory cycle with [unowned pushBehavior]
        pushBehavior.action = { [unowned pushBehavior] in
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
    static func randomRadian() -> CGFloat {
        return CGFloat(arc4random() % UInt32(2 * M_PI * 1000))
    }
}
