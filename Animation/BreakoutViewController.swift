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
    
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        lazilyCreatedDynamicAnimator.debugEnabled = true
        return lazilyCreatedDynamicAnimator
    }()
    
    let breakoutBehavior = BreakoutBehavior()
    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animator.addBehavior(breakoutBehavior)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createPaddle()
        createBall()
        createBricks()
    }
    
    // MARK: - Gestures
    
    @IBAction func tap(sender: UITapGestureRecognizer) {
        let location = sender.locationInView(gameView)
        print(location)        
    }
    
    // MARK: - Bricks
    
    let brickHeight = 20
    let bricksPerRow = 12
    let brickBackgroundColor = UIColor.blueColor()
    let brickRows = 10
    let topBrickDistanceFromTop = 100
    
    func createBricks() {
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
    
    let paddleSize = CGSize(width: 140, height: 25)
    let paddleColor = UIColor.greenColor()
    var paddleView: UIView?
    
    func createPaddle() {
        var frame = CGRect(origin: CGPointZero, size: paddleSize)
        frame.origin.x = (gameView.bounds.size.width  - paddleSize.width) / 2
        frame.origin.y = gameView.bounds.size.height - paddleSize.height
        
        if paddleView == nil {
            paddleView = UIView(frame: frame)
            paddleView!.backgroundColor = paddleColor
//            gameView.addSubview(paddleView!)
            breakoutBehavior.addPaddle(paddleView!)
        }
    }
    
    // MARK: - Ball
    
    let ballSize = CGSize(width: 20, height: 20)
    let ballColor = UIColor.redColor()
    var ballView: UIView?
    
    func createBall() {
        var frame = CGRect(origin: CGPointZero, size: ballSize)
        frame.origin.x = ((paddleView?.frame.origin.x)! - ballSize.width / 2) + (paddleSize.width / 2)
//        frame.origin.y = (paddleView?.frame.origin.y)! - ballSize.height
        
        if ballView == nil {
            ballView = BallView(frame: frame)
            ballView!.backgroundColor = ballColor
            ballView!.layer.cornerRadius = (ballView?.bounds.width)!/2
            breakoutBehavior.addBall(ballView!)
        }
        
        
    }

}
