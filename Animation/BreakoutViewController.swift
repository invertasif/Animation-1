//
//  BreakoutViewController.swift
//  Animation
//
//  Created by Sanjib Ahmad on 2/2/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate {
    @IBOutlet weak var gameView: UIView!
    
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        lazilyCreatedDynamicAnimator.debugEnabled = true
        return lazilyCreatedDynamicAnimator
    }()
    private let breakoutBehavior = BreakoutBehavior()
        
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakoutBehavior)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createPaddle()
//        createBall()
//        createBricks()
    }
    
    // MARK: - Gestures
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
//        let location = gesture.locationInView(gameView)
//        print(location)
        
//        paddleView?.increaseSpeed()
//        paddleView?.decreaseSpeed()
        
//        paddleView?.increaseWidth()
//        paddleView?.decreaseWidth()
        
    }
    
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(gameView)

            if translation.x > 0 {
                paddleView?.moveRight()
            } else if translation.x < 0 {
                paddleView?.moveLeft()
            }
            
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }    
    
    // MARK: - Bricks
    
    private let brickHeight = 20
    private let bricksPerRow = 12
    private let brickBackgroundColor = UIColor.blueColor()
    private let brickRows = 10
    private let topBrickDistanceFromTop = 100
    
    private func createBricks() {
        let brickWidth = gameView.bounds.size.width / CGFloat(bricksPerRow)
        
        for row in 0 ..< brickRows {
            for column in 0 ..< bricksPerRow {
                var frame = CGRect(origin: CGPointZero, size: CGSize(width: brickWidth, height: CGFloat(brickHeight)))
                frame.origin = CGPoint(x: column * Int(brickWidth), y: (row * brickHeight) + topBrickDistanceFromTop )
                let brick = UIView(frame: frame)
                brick.backgroundColor = brickBackgroundColor
                brick.layer.borderColor = UIColor.whiteColor().CGColor
                brick.layer.borderWidth = 0.5
                gameView.addSubview(brick)
            }
        }
    }
    
    // MARK: - Paddle
    
    private var paddleView: PaddleView?
    
    private func createPaddle() {        
        if paddleView == nil {
            paddleView = PaddleView(referenceView: gameView)
//            gameView.addSubview(paddleView!)
            breakoutBehavior.addPaddle(paddleView!)
        }
    }
    
    // MARK: - Ball
    
    private let ballSize = CGSize(width: 20, height: 20)
    private let ballColor = UIColor.redColor()
    private var ballView: UIView?
    
    private func createBall() {
        var frame = CGRect(origin: CGPointZero, size: ballSize)
        frame.origin.x = ((paddleView?.frame.origin.x)! - ballSize.width / 2) + ((paddleView?.frame.size.width)! / 2)
//        frame.origin.y = (paddleView?.frame.origin.y)! - ballSize.height
        
        if ballView == nil {
            ballView = BallView(frame: frame)
            ballView!.backgroundColor = ballColor
            ballView!.layer.cornerRadius = (ballView?.bounds.width)!/2
            breakoutBehavior.addBall(ballView!)
        }
    }
}
