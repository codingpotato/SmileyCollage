//
//  CPTransparentTransition.m
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPShopViewControllerTransition.h"

#import "CPShopViewController.h"

@implementation CPShopViewControllerTransition

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CPShopViewController *shopViewController = (CPShopViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:shopViewController];
    
    [containerView addSubview:shopViewController.view];
    shopViewController.view.frame = finalFrame;
    
    UIView *snapView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
    [shopViewController.view insertSubview:snapView atIndex:0];
    
    [fromViewController.view removeFromSuperview];
    
    shopViewController.panelViewBottomLayoutConstraint.constant = 0.0;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        [shopViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CPShopViewController *shopViewController = (CPShopViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];

    shopViewController.panelViewBottomLayoutConstraint.constant = -shopViewController.panelView.bounds.size.height;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        [shopViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [shopViewController.view removeFromSuperview];
        [containerView addSubview:toViewController.view];
        toViewController.view.frame = finalFrame;
        [transitionContext completeTransition:YES];
    }];
}

@end
