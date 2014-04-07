//
//  CPStitchEditTransition.h
//  Smiley
//
//  Created by wangyw on 3/9/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPStitchEditTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL fromStitchToEdit;

@property (nonatomic) CGRect stitchCellFrame;

@end
