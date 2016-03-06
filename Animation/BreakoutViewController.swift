//
//  BreakoutViewController.swift
//  Animation
//
//  Created by Sanjib Ahmad on 2/2/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate {
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        lazilyCreatedDynamicAnimator.debugEnabled = true
        return lazilyCreatedDynamicAnimator
    }()
    private let breakoutBehavior = BreakoutBehavior()
    
    struct BoundaryNames {
        static let GameViewLeftBoundary = "Game View Left Boundary"
        static let GameViewTopBoundary = "Game View Top Boundary"
        static let GameViewRightBoundary = "Game View Right Boundary"
        static let PaddleBoundary = "Paddle Boundary"
        static let BrickBoundary = "Brick Boundary"
    }
    
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
        createBall()
//        createBricks()
        addGameViewBoundary()
    }
    
    // MARK: - Gestures
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        if let ballView = ballView {
            breakoutBehavior.pushBall(ballView)
        }
    }
    
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(gameView)

            if let paddleView = paddleView, ballView = ballView {
                if translation.x > 0 {
                    paddleView.moveRight()
                } else if translation.x < 0 {
                    paddleView.moveLeft()
                }
                
                // Specs page 5: 23. Be careful not to move your paddle boundary right on 
                // top of a bouncing ball or the ball might get trapped inside your paddle.
                if CGRectIntersectsRect(paddleView.frame, ballView.frame) {
                    print("ball collided")
                    breakoutBehavior.ballBehavior.action = {
                        if !CGRectIntersectsRect(paddleView.frame, ballView.frame) {
                            self.syncPaddle()
                        }
                    }
                } else {
                    syncPaddle()
                }
            }
            
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
    }
    
    // MARK: - Game view
    @IBOutlet weak var gameView: UIView!
    
    private func addGameViewBoundary() {
        let gameViewPathLeft = UIBezierPath()
        gameViewPathLeft.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.size.height))
        gameViewPathLeft.addLineToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        
        let gameViewPathTop = UIBezierPath()
        gameViewPathTop.moveToPoint(CGPoint(x: gameView.bounds.origin.x, y: gameView.bounds.origin.y))
        gameViewPathTop.addLineToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.origin.y))
        
        let gameViewPathRight = UIBezierPath()
        gameViewPathRight.moveToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.origin.y))
        gameViewPathRight.addLineToPoint(CGPoint(x: gameView.bounds.size.width, y: gameView.bounds.size.height))
                
        breakoutBehavior.addBoundary(gameViewPathLeft, named: BoundaryNames.GameViewLeftBoundary)
        breakoutBehavior.addBoundary(gameViewPathTop, named: BoundaryNames.GameViewTopBoundary)
        breakoutBehavior.addBoundary(gameViewPathRight, named: BoundaryNames.GameViewRightBoundary)
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
            gameView.addSubview(paddleView!)            
            syncPaddle()
        }
    }
    
    private func syncPaddle() {
        if let paddleView = paddleView {
            // Why ovalInRect?
            // Specs, page 5: 26. You might want to make the bezier path boundary
            // for your paddle be an oval (even if the paddle itself still looks
            // like a rectangle). It makes the bouncing ball come off the paddle
            // more interestingly.
            let paddleBoundary = UIBezierPath(ovalInRect: paddleView.frame)
            breakoutBehavior.addBoundary(paddleBoundary, named: BoundaryNames.PaddleBoundary)
        }
    }
    
    // MARK: - Ball
    
    private let ballSize = CGSize(width: 20, height: 20)
    private let ballColor = UIColor.redColor()
    private var ballView: UIView?
    
    private func createBall() {
        var frame = CGRect(origin: CGPointZero, size: ballSize)
        frame.origin.x = ((paddleView?.frame.origin.x)! - ballSize.width / 2) + ((paddleView?.frame.size.width)! / 2)
        frame.origin.y = (paddleView?.frame.origin.y)! - ballSize.height
        
        if ballView == nil {
            ballView = BallView(frame: frame)
            ballView!.backgroundColor = ballColor
            ballView!.layer.cornerRadius = (ballView?.bounds.width)!/2
            breakoutBehavior.addBall(ballView!)
        }
    }
}
