//
//  UIDynamicAnimatorBridgingHeader.h
//  Dropit
//
//  Created by Sanjib Ahmad on 2/27/16.
//  Copyright © 2016 Object Coder. All rights reserved.
//

#ifndef UIDynamicAnimatorBridgingHeader_h
#define UIDynamicAnimatorBridgingHeader_h

@import UIKit;

@interface UIDynamicAnimator (AAPLDebugInterfaceOnly)

// Used in BreakoutViewController.swift file:
// lazilyCreatedDynamicAnimator.debugEnabled = true
@property (nonatomic, getter=isDebugEnabled) BOOL debugEnabled;
@end

#endif /* UIDynamicAnimatorBridgingHeader_h */



