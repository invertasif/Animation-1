//
//  Brick.swift
//  Animation
//
//  Created by Sanjib Ahmad on 3/9/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import UIKit

enum BrickType: Int {
    case Regular = 0, Hard, SmallerPaddle, LargerPaddle
    
    var hitsRequired: Int {
        switch self {
        case .Regular: fallthrough
        case .SmallerPaddle: fallthrough
        case .LargerPaddle:
            return 1
        case .Hard:
            return 3
        }
    }
    
    var color: UIColor {
        switch self {
        case .Regular:
            return UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        case .SmallerPaddle:
            return UIColor(red: 204/255.0, green: 205/255.0, blue: 153/255.0, alpha: 1.0)
        case .LargerPaddle:
            return UIColor(red: 102/255.0, green: 204/255.0, blue: 102/255.0, alpha: 1.0)
        case .Hard:
            return UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        }
    }
    
    static var count: Int {
        return LargerPaddle.hashValue + 1
    }
}

class Brick: UIView {
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
        
        backgroundColor = type.color
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 2.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateRemoveFromSuperview() {
        UIView.animateWithDuration(0.2,
            animations: {
                self.alpha = 0
            },
            completion: { didComplete in
                self.alpha = 1
                UIView.animateWithDuration(0.2,
                    animations: {
                        self.alpha = 0
                    },
                    completion: { didComplete in
                        self.alpha = 1
                        UIView.animateWithDuration(0.8,
                            animations: {
                                self.alpha = 0
                            },
                            completion: { didComplete in
                                self.removeFromSuperview()
                            }
                        )
                    }
                )
            }
        )
    }
    
    private func colorAlphaDown() {
        var alpha: CGFloat = 1.0
        if let hitsRequired = type?.hitsRequired {
            alpha = CGFloat(1 - (Double(currentHits) / Double(hitsRequired))/2)
        }
        backgroundColor = type?.color.colorWithAlphaComponent(alpha)
    }

}
