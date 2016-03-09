//
//  Brick.swift
//  Animation
//
//  Created by Sanjib Ahmad on 3/9/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

class Brick: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.grayColor()
        
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2.0
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
