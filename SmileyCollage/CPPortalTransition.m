//
//  CPPortalTransition.m
//  SmileyCollage
//
//  Created by wangyw on 4/8/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPortalTransition.h"

@implementation CPPortalTransition

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    // add to view
    [containerView addSubview:toViewController.view];
    toViewController.view.frame = finalFrame;

    // create left and right snapshot
    CGRect leftFrame = finalFrame;
    leftFrame.size.width /= 2;
    UIView *leftSnapshot = [fromViewController.view resizableSnapshotViewFromRect:leftFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    CGRect rightFrame = finalFrame;
    rightFrame.size.width /= 2;
    rightFrame.origin.x += rightFrame.size.width;
    UIView *rightSnapshot = [fromViewController.view resizableSnapshotViewFromRect:rightFrame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    
    // remove from view
    [fromViewController.view removeFromSuperview];

    leftSnapshot.frame = leftFrame;
    rightSnapshot.frame = rightFrame;
    [containerView addSubview:leftSnapshot];
    [containerView addSubview:rightSnapshot];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        leftSnapshot.frame = CGRectOffset(leftFrame, -leftFrame.size.width, 0.0);
        rightSnapshot.frame = CGRectOffset(rightFrame, rightFrame.size.width, 0.0);
    } completion:^(BOOL finished) {
        [leftSnapshot removeFromSuperview];
        [rightSnapshot removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    // add to view
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    toViewController.view.frame = finalFrame;
    
    // create left and right snapshot
    CGRect leftFrame = finalFrame;
    leftFrame.size.width /= 2;
    UIView *leftSnapshot = [toViewController.view resizableSnapshotViewFromRect:leftFrame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    CGRect rightFrame = finalFrame;
    rightFrame.size.width /= 2;
    rightFrame.origin.x += rightFrame.size.width;
    UIView *rightSnapshot = [toViewController.view resizableSnapshotViewFromRect:rightFrame afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    
    leftSnapshot.frame = CGRectOffset(leftFrame, -leftFrame.size.width, 0.0);
    rightSnapshot.frame = CGRectOffset(rightFrame, rightFrame.size.width, 0.0);
    [containerView addSubview:leftSnapshot];
    [containerView addSubview:rightSnapshot];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        leftSnapshot.frame = leftFrame;
        rightSnapshot.frame = rightFrame;
    } completion:^(BOOL finished) {
        [leftSnapshot removeFromSuperview];
        [rightSnapshot removeFromSuperview];
        [fromViewController.view removeFromSuperview];
        
        [transitionContext completeTransition:YES];
    }];
}

@end
