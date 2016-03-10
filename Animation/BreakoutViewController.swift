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
//        lazilyCreatedDynamicAnimator.debugEnabled = true
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
    var bricks = [String:Brick]()
    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakoutBehavior)
        breakoutBehavior.collidor.collisionDelegate = self
        breakoutBehavior.collidor.action = { [unowned self] in
            for ball in self.balls {
                if !CGRectIntersectsRect(ball.frame, self.gameView.frame) {
                    self.removeBall(ball)
                }
            }
            if self.balls.count == 0 {
                self.gameOver()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()        
        createPaddle()
        createBricks()
        addGameViewBoundary()
    }
    
    // MARK: - Gestures
    @IBOutlet var movePaddleGesture: UIPanGestureRecognizer!
    @IBOutlet var pushBallGesture: UITapGestureRecognizer!
    
    
    // MARK: - Start / Restart game
    @IBOutlet weak var startView: UIView!
    @IBOutlet weak var startGameLabel: UILabel!
    
    @IBAction func startGame(sender: UITapGestureRecognizer) {
        startView.hidden = true
        
        gameView.userInteractionEnabled = true
        pushBallGesture.enabled = true
        movePaddleGesture.enabled = true
        
        createBall()
    }
    
    private func gameOver() {
        gameView.userInteractionEnabled = false
        movePaddleGesture.enabled = false
        pushBallGesture.enabled = false
        
        startView.hidden = false
        startGameLabel.text = Constants.GameOverText
        
        removePaddle()
        removeAllBricks()
        
        createPaddle()
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
    
    private let brickHeight = 30
    private let bricksPerRow = 6
    private let brickBackgroundColor = UIColor.blueColor()
    private let brickRows = 4
    private let topBrickDistanceFromTop = 100
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
        if let identifier = identifier as? String {
            if let brick = bricks[identifier], brickType = brick.type {
                brick.currentHits++
                if brick.currentHits >= brickType.hitsRequired {
                    bricks.removeValueForKey(identifier)
                    breakoutBehavior.removeBoundary(named: identifier)
                    brick.animateRemoveFromSuperview()
                    
                    // run any special function the brick is identified with
                    switch brickType {
                    case .SmallerPaddle:
                        paddle?.decreaseWidth()
                        syncPaddle()
                    case .LargerPaddle:
                        paddle?.increaseWidth()
                        syncPaddle()
                    case .AddBall:
                        createBall()
                    default:break
                    }
                }
            }
        }
    }
    
    private func removeAllBricks() {
        for (identifier, brick) in bricks {
            breakoutBehavior.removeBoundary(named: identifier)
            brick.removeFromSuperview()
        }
        bricks = [String:Brick]()
    }
    
    private func createBricks() {
        guard bricks.isEmpty else { return }
        
        let maxSpecialBricks = 6
        var specialBricksMatrix = [(row: Int, col: Int)]()
        repeat {
            let randomRow = (brickRows).random()
            let randomCol = (bricksPerRow).random()
            let doesContainRandomPosition = specialBricksMatrix.contains({ (position: (row: Int, col: Int)) -> Bool in
                if position.row == randomRow && position.col == randomCol {
                    return true
                } else {
                    return false
                }
            })
            if doesContainRandomPosition == false {
                specialBricksMatrix.append((row: randomRow, col: randomCol))
            }
        } while specialBricksMatrix.count < maxSpecialBricks
//        print(specialBricksMatrix)
        
        let brickWidth = gameView.bounds.size.width / CGFloat(bricksPerRow)
        
        for row in 0 ..< brickRows {
            for column in 0 ..< bricksPerRow {
                var frame = CGRect(origin: CGPointZero, size: CGSize(width: brickWidth, height: CGFloat(brickHeight)))
                frame.origin = CGPoint(x: column * Int(brickWidth), y: (row * brickHeight) + topBrickDistanceFromTop )
                
                let doesContainRandomPosition = specialBricksMatrix.contains({ (position: (row: Int, col: Int)) -> Bool in
                    if position.row == row && position.col == column {
                        return true
                    } else {
                        return false
                    }
                })
                
                var brick: Brick!
                if doesContainRandomPosition == true {
                    let randomSpecialBrickTypeIndex = (BrickType.count - 1).random() + 1
                    if let brickType = BrickType(rawValue: randomSpecialBrickTypeIndex) {
                        brick = Brick(frame: frame, type: brickType)
                    } else {
                        brick = Brick(frame: frame, type: .Regular)
                    }
                } else {
                    brick = Brick(frame: frame, type: .Regular)
                }
                
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
    
    @IBAction func movePaddle(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let velocity = gesture.velocityInView(gameView)
            if let paddle = paddle {
                paddle.move(velocity)
                
                // Specs page 5: 23. Be careful not to move your paddle boundary right on
                // top of a bouncing ball or the ball might get trapped inside your paddle.
                for ball in balls {
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
            }
            
            gesture.setTranslation(CGPointZero, inView: gameView)
        default: break
        }
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
    private var balls = [Ball]()
    
    private func createBall() {
        if balls.count == 0 {
            var frame = CGRect(origin: CGPointZero, size: ballSize)
            frame.origin.x = ((paddle?.frame.origin.x)! - ballSize.width / 2) + ((paddle?.frame.size.width)! / 2)
            frame.origin.y = (paddle?.frame.origin.y)! - ballSize.height
            
            let ball = Ball(frame: frame)
            breakoutBehavior.addBall(ball)
            balls.append(ball)
        } else {
            let lastBall = balls.last
            var frame = CGRect(origin: CGPointZero, size: ballSize)
            frame.origin.x = (lastBall?.frame.origin.x)!
            frame.origin.y = (lastBall?.frame.origin.y)!
            
            let ball = Ball(frame: frame)
            breakoutBehavior.addBall(ball)
            breakoutBehavior.pushBall(ball)
            balls.append(ball)
        }
    }
        
    private func removeBall(ball: Ball) {
        breakoutBehavior.removeBall(ball)
        balls.removeObject(ball)
    }
    
    @IBAction func pushBall(gesture: UITapGestureRecognizer) {
        for ball in balls {
            breakoutBehavior.pushBall(ball)
        }
    }
}

private extension Int {
    func random() -> Int {
        return Int(arc4random() % UInt32(self))
    }
}

private extension Array {
    mutating func removeObject<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {  //in old swift use enumerate(self)
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }}