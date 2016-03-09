//
//  Ball.swift
//  Animation
//
//  Created by Sanjib Ahmad on 2/17/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

class Ball: UIView {

    // iOS 9 specific
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .Ellipse
    }

    
}
