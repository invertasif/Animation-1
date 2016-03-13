//
//  Brick.swift
//  Animation
//
//  Created by Sanjib Ahmad on 3/9/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

enum BrickType: Int {
    case Regular = 0, SmallerPaddle, LargerPaddle, AddBall, Hard
    
    var hitsRequired: Int {
        switch self {
        case .Regular: fallthrough
        case .SmallerPaddle: fallthrough
        case .LargerPaddle: fallthrough
        case .AddBall:
            return 1
        case .Hard:
            return 3
        }
    }
    
    var color: UIColor {
        switch self {
        case .Regular:
            return UIColor(red: 177/255.0, green: 160/255.0, blue: 164/255.0, alpha: 1.0)
        case .SmallerPaddle:
            return UIColor(red: 225/255.0, green: 232/255.0, blue: 111/255.0, alpha: 1.0)
        case .LargerPaddle:
            return UIColor(red: 194/255.0, green: 231/255.0, blue: 112/255.0, alpha: 1.0)
        case .AddBall:
            return UIColor(red: 217/255.0, green: 133/255.0, blue: 149/255.0, alpha: 1.0)
        case .Hard:
            return UIColor(red: 127/255.0, green: 106/255.0, blue: 110/255.0, alpha: 1.0)
        }
    }
    
    static var count: Int {
        return Hard.hashValue + 1
    }
}

class Brick: UIView {
    let padding: CGFloat = 3.0
    var currentAlphaLevel: CGFloat = 1.0
    
    var currentHits = 0 {
        didSet {
            if type?.hitsRequired > 1 {
                colorAlphaDown()
            }
        }
    }
    var type: BrickType?

    init(frame: CGRect, type: BrickType) {
        super.init(frame: frame)
        self.type = type
        opaque = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func colorAlphaDown() {
        currentAlphaLevel = CGFloat(1 - Double(currentHits + 1) * 0.10)
        alpha = currentAlphaLevel
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(rect: CGRect(x: bounds.origin.x + padding, y: bounds.origin.y + padding, width: bounds.size.width - padding * 2, height: bounds.size.height - padding * 2))
        type?.color.set()
        path.fill()
    }

}
