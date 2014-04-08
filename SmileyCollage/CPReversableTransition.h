//
//  CPReversableTransition.h
//  SmileyCollage
//
//  Created by wangyw on 4/8/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPReversableTransition : NSObject <UIViewControllerAnimatedTransitioning>

- (id)initWithReverse:(BOOL)reverse;

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@end
