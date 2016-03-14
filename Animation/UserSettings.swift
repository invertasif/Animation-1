//
//  UserSettings.swift
//  Animation
//
//  Created by Sanjib Ahmad on 3/11/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

import Foundation

// Required Tasks
// 5. Your game should be designed to support at least 4 different variables
// that control the way your game is played (e.g. number of bricks, ball
// bounciness, number of bouncing balls, a gravitational pull, special bricks
// that cause interesting behavior, etc.).

class UserSettings {
    static let sharedInstance = UserSettings()
    
    // Prevents creation of UserSettings instance
    // UserSettings is meant to be used as a static class
    private init() {}
    
    // Required Tasks
    // 8. Your game-play configurations must persist between application launchings.
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private struct Defaults {
        static let GravityMagnitude: CGFloat = 0.25
        static let BallBehaviorElasticity: CGFloat = 1.00
        static let NumberOfBalls = 2
        static let NumberOfTotalBricks = 18
        static let NumberOfSpecialBricks = 6
        static let SpecialBrickSmallerPaddleEnabled = true
        static let SpecialBrickLargerPaddleEnabled = true
        static let SpecialBrickAddBallEnabled = true
        static let SpecialBrickHardEnabled = true
    }
    
    private struct Keys {
        static let GravityMagnitude = "Gravity Magnitude"
        static let BallBehaviorElasticity = "Ball Behavior Elasticity"
        static let NumberOfBalls = "Number of Bouncing Balls"
        static let NumberOfTotalBricks = "Number of Total Bricks"
        static let NumberOfSpecialBricks = "Number of Special Bricks"
        static let SpecialBrickSmallerPaddleEnabled = "Special Brick Smaller Paddle Enabled"
        static let SpecialBrickLargerPaddleEnabled = "Special Brick Larger Paddle Enabled"
        static let SpecialBrickAddBallEnabled = "Special Brick Add Ball Enabled"
        static let SpecialBrickHardEnabled = "Special Brick Hard Enabled"
    }
    
    var gravity: CGFloat {
        get {
            if let gravity = userDefaults.valueForKey(Keys.GravityMagnitude) as? CGFloat {
                return gravity
            } else {
                self.gravity = Defaults.GravityMagnitude
                return self.gravity
            }
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.GravityMagnitude)
            // though NSUserDefaults will automatically save the data
            // always call synchronize(), especially for testing
            // since the call isn't expensive
            userDefaults.synchronize()
        }
    }
    
    var elasticity: CGFloat {
        get {
            if let elasticity = userDefaults.valueForKey(Keys.BallBehaviorElasticity) as? CGFloat {
                return elasticity
            } else {
                self.elasticity = Defaults.BallBehaviorElasticity
                return self.elasticity
            }
        }
        set {
            userDefaults.setValue(newValue, forKey: Keys.BallBehaviorElasticity)
            userDefaults.synchronize()
        }
    }
    
    var numberOfBalls: Int {
        get {
            if userDefaults.integerForKey(Keys.NumberOfBalls) != 0 {
                return userDefaults.integerForKey(Keys.NumberOfBalls)
            } else {
                self.numberOfBalls = Defaults.NumberOfBalls
                return self.numberOfBalls
            }
        }
        set {
            userDefaults.setInteger(newValue, forKey: Keys.NumberOfBalls)
            userDefaults.synchronize()
        }
    }
    
    var numberOfTotalBricks: Int {
        get {
            if userDefaults.integerForKey(Keys.NumberOfTotalBricks) != 0 {
                return userDefaults.integerForKey(Keys.NumberOfTotalBricks)
            } else {
                self.numberOfTotalBricks = Defaults.NumberOfTotalBricks
                return self.numberOfTotalBricks
            }
        }
        set {
            userDefaults.setInteger(newValue, forKey: Keys.NumberOfTotalBricks)
            userDefaults.synchronize()
        }
    }
    
    var numberOfSpecialBricks: Int {
        get {
            if userDefaults.integerForKey(Keys.NumberOfSpecialBricks) != 0 {
                return userDefaults.integerForKey(Keys.NumberOfSpecialBricks)
            } else {
                self.numberOfSpecialBricks = Defaults.NumberOfSpecialBricks
                return self.numberOfSpecialBricks
            }
        }
        set {
            userDefaults.setInteger(newValue, forKey: Keys.NumberOfSpecialBricks)
            userDefaults.synchronize()
        }
    }
    
    var specialBrickSmallerPaddleEnabled: Bool {
        get {
            if let specialBrickSmallerPaddleEnabled = userDefaults.valueForKey(Keys.SpecialBrickSmallerPaddleEnabled) as? Bool {
                return specialBrickSmallerPaddleEnabled
            } else {
                self.specialBrickSmallerPaddleEnabled = Defaults.SpecialBrickSmallerPaddleEnabled
                return self.specialBrickSmallerPaddleEnabled
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.SpecialBrickSmallerPaddleEnabled)
            userDefaults.synchronize()
        }
    }
    
    var specialBrickLargerPaddleEnabled: Bool {
        get {
            if let specialBrickLargerPaddleEnabled = userDefaults.valueForKey(Keys.SpecialBrickLargerPaddleEnabled) as? Bool {
                return specialBrickLargerPaddleEnabled
            } else {
                self.specialBrickLargerPaddleEnabled = Defaults.SpecialBrickLargerPaddleEnabled
                return self.specialBrickLargerPaddleEnabled
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.SpecialBrickLargerPaddleEnabled)
            userDefaults.synchronize()
        }
        
    }
    
    var specialBrickAddBallEnabled: Bool {
        get {
            if let specialBrickAddBallEnabled = userDefaults.valueForKey(Keys.SpecialBrickAddBallEnabled) as? Bool {
                return specialBrickAddBallEnabled
            } else {
                self.specialBrickAddBallEnabled = Defaults.SpecialBrickAddBallEnabled
                return self.specialBrickAddBallEnabled
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.SpecialBrickAddBallEnabled)
            userDefaults.synchronize()
        }
        
    }
    
    var specialBrickHardEnabled: Bool {
        get {
            if let specialBrickHardEnabled = userDefaults.valueForKey(Keys.SpecialBrickHardEnabled) as? Bool {
                return specialBrickHardEnabled
            } else {
                self.specialBrickHardEnabled = Defaults.SpecialBrickHardEnabled
                return self.specialBrickHardEnabled
            }
        }
        set {
            userDefaults.setBool(newValue, forKey: Keys.SpecialBrickHardEnabled)
            userDefaults.synchronize()
        }
    }
    
}