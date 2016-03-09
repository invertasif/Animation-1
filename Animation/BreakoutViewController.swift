//
//  BreakoutViewController.swift
//  Animation
//
//  Created by Sanjib Ahmad on 2/2/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

class BreakoutViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate {
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        lazilyCreatedDynamicAnimator.debugEnabled = true
        return lazilyCreatedDynamicAnimator
    }()
    
    func dynamicAnimatorDidPause(animator: UIDynamicAnimator) {
        print("dynamicAnimatorDidPause")
    }
    
    private let breakoutBehavior = BreakoutBehavior()
    
    struct BoundaryNames {
        static let GameViewLeftBoundary = "Game View Left Boundary"
        static let GameViewTopBoundary = "Game View Top Boundary"
        static let GameViewRightBoundary = "Game View Right Boundary"
        static let PaddleBoundary = "Paddle Boundary"
        static let BrickBoundary = "Brick Boundary"
    }
    
    struct Constants {
        static let GameOverText = "Game Over"
    }
    
    // used for identifying colliding bricks and removing from superview
    var bricks = [String:UIView]()
    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakoutBehavior)
        breakoutBehavior.collidor.collisionDelegate = self
        breakoutBehavior.collidor.action = { 
            if let ballView = self.ball {
                if !CGRectIntersectsRect(ballView.frame, self.gameView.frame) {
                    self.breakoutBehavior.removeBall(ballView)
                    self.ball = nil
                    self.gameOver()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()        
        createPaddle()
        createBall()
        createBricks()
        addGameViewBoundary()
    }
    
    // MARK: - Gestures
    @IBOutlet var panGesture: UIPanGestureRecognizer!
    
    @IBAction func tap(gesture: UITapGestureRecognizer) {
        if let ball = ball {
            breakoutBehavior.pushBall(ball)
        }
    }
    
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(gameView)

            if let paddle = paddle, ball = ball {
                if translation.x > 0 {
                    paddle.moveRight()
                } else if translation.x < 0 {
                    paddle.moveLeft()
                }
                
                // Specs page 5: 23. Be careful not to move your paddle boundary right on 
                // top of a bouncing ball or the ball might get trapped inside your paddle.
                if CGRectIntersectsRect(paddle.frame, ball.frame) {
                    breakoutBehavior.ballBehavior.action = { [unowned self] in
                        if !CGRectIntersectsRect(paddle.frame, ball.frame) {
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
    
    // MARK: - Start / Restart game
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var startGameLabel: UILabel!
    
    @IBAction func startGame(sender: UITapGestureRecognizer) {
        startView.hidden = true
        
        gameView.userInteractionEnabled = true
        panGesture.enabled = true
    }
    
    private func gameOver() {
        gameView.userInteractionEnabled = false
        panGesture.enabled = false
        
        startView.hidden = false
        startGameLabel.text = Constants.GameOverText
        
        removePaddle()
        removeAllBricks()
        
        createPaddle()
        createBall()
        createBricks()
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
    private let bricksPerRow = 8
    private let brickBackgroundColor = UIColor.blueColor()
    private let brickRows = 5
    private let topBrickDistanceFromTop = 100
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        if let identifier = identifier as? String {
            if let brick = bricks[identifier] {
                removeBrickWithAnimation(identifier, brick: brick)
            }
        }
    }
    
    private func removeAllBricks() {
        for (identifier, brick) in bricks {
            breakoutBehavior.removeBoundary(named: identifier)
            brick.removeFromSuperview()
        }
        bricks = [String:UIView]()
    }
    
    private func removeBrickWithAnimation(identifier: String, brick: UIView) {
        bricks.removeValueForKey(identifier)
        breakoutBehavior.removeBoundary(named: identifier)
        UIView.animateWithDuration(0.2,
            animations: {
                brick.alpha = 0
            },
            completion: { didComplete in
                brick.alpha = 1
                UIView.animateWithDuration(0.2,
                    animations: {
                        brick.alpha = 0
                    },
                    completion: { didComplete in
                        brick.alpha = 1
                        UIView.animateWithDuration(0.8,
                            animations: {
                                brick.alpha = 0
                            },
                            completion: { didComplete in
                                brick.removeFromSuperview()
                            }
                        )
                    }
                )
            }
        )
    }
    
    private func createBricks() {
        guard bricks.isEmpty else { return }
        
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
                let brickPath = UIBezierPath(rect: brick.frame)
                let brickIdentifier = BoundaryNames.BrickBoundary + "\(row).\(column)"
                breakoutBehavior.addBoundary(brickPath, named: brickIdentifier)
                bricks[brickIdentifier] = brick
            }
        }
    }
    
    // MARK: - Paddle
    
    private var paddle: Paddle?
    
    private func createPaddle() {        
        if paddle == nil {
            paddle = Paddle(referenceView: gameView)
            gameView.addSubview(paddle!)
            syncPaddle()
        }
    }
    
    private func removePaddle() {
        breakoutBehavior.removeBoundary(named: BoundaryNames.PaddleBoundary)
        paddle?.removeFromSuperview()
        paddle = nil
    }
    
    private func syncPaddle() {
        if let paddleView = paddle {
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
    private var ball: UIView?
    
    private func createBall() {
        var frame = CGRect(origin: CGPointZero, size: ballSize)
        frame.origin.x = ((paddle?.frame.origin.x)! - ballSize.width / 2) + ((paddle?.frame.size.width)! / 2)
        frame.origin.y = (paddle?.frame.origin.y)! - ballSize.height
        
        if ball == nil {
            ball = Ball(frame: frame)
            ball!.backgroundColor = ballColor
            ball!.layer.cornerRadius = (ball?.bounds.width)!/2
            breakoutBehavior.addBall(ball!)
        }
    }
}
