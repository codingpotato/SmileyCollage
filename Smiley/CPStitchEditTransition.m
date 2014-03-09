//
//  CPStitchEditTransition.m
//  Smiley
//
//  Created by wangyw on 3/9/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPStitchEditTransition.h"

#import "CPStitchViewController.h"

@implementation CPStitchEditTransition

static NSTimeInterval g_transitionDuration = 0.5;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return g_transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CPStitchViewController *fromViewController = (CPStitchViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect fromFrame = [fromViewController frameOfSelectFaceInView:containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    [containerView addSubview:toViewController.view];
    toViewController.view.frame = finalFrame;
    toViewController.view.transform = CGAffineTransformMakeScale(fromFrame.size.width / finalFrame.size.width, fromFrame.size.height / finalFrame.size.height);
    toViewController.view.center = CGPointMake(fromFrame.origin.x + fromFrame.size.width / 2, fromFrame.origin.y + fromFrame.size.height / 2);
    
    [UIView animateWithDuration:g_transitionDuration delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:6.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        toViewController.view.center = CGPointMake(finalFrame.origin.x + finalFrame.size.width / 2, finalFrame.origin.y + finalFrame.size.height / 2);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
