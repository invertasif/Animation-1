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
        
        lazilyCreatedCollisionBehavior.translatesReferenceBoundsIntoBoundary = true
        
        return lazilyCreatedCollisionBehavior
    }()
    
    let gravity = UIGravityBehavior()
    
    lazy var ballBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBallBehavior = UIDynamicItemBehavior()
        lazilyCreatedBallBehavior.elasticity = 1.0
        lazilyCreatedBallBehavior.resistance = 0
        return lazilyCreatedBallBehavior
    }()
    
    struct BoundaryNames {
        static let PaddleBoundary = "Paddle Boundary"
        static let BrickBoundary = "Brick Boundary"
    }
    
    override init() {
        super.init()
        addChildBehavior(gravity)
        addChildBehavior(collidor)
        addChildBehavior(ballBehavior)
    }
    
    func syncPaddle(view: UIView) {        
        let paddleBoundary = UIBezierPath(ovalInRect: view.frame)
        addBoundary(paddleBoundary, named: BoundaryNames.PaddleBoundary)
    }
    
    func addBoundary(path: UIBezierPath, named name: String) {
        collidor.removeBoundaryWithIdentifier(name)
        collidor.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBoundary(named name: String) {
        collidor.removeBoundaryWithIdentifier(name)
    }
    
    func addPaddle(paddle: UIView) {
        dynamicAnimator?.referenceView?.addSubview(paddle)
        collidor.addItem(paddle)
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
