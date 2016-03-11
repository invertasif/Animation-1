//
//  Ball.swift
//  Animation
//
//  Created by Sanjib Ahmad on 2/17/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

class Ball: UIImageView {
    // used for restoring game state
    var linearVelocity: CGPoint?
    
    // iOS 9 specific
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = frame.width / 2.0
        image = UIImage(named: "ball")
        backgroundColor = UIColor(red: 243/255.0, green: 41/255.0, blue: 56/255.0, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
