//
//  CPStitchEditTransition.m
//  Smiley
//
//  Created by wangyw on 3/9/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPStitchEditTransition.h"

@implementation CPStitchEditTransition

static NSTimeInterval g_transitionDuration = 0.3;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return g_transitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    CGFloat size = MIN(finalFrame.size.width, finalFrame.size.height);

    if (self.fromStitchToEdit) {
        self.stitchCellFrame = [containerView convertRect:self.stitchCellFrame fromView:fromViewController.view];
        
        [containerView addSubview:toViewController.view];
        toViewController.view.frame = finalFrame;
        
        toViewController.view.transform = CGAffineTransformMakeScale(self.stitchCellFrame.size.width / size, self.stitchCellFrame.size.height / size);
        toViewController.view.center = CGPointMake(self.stitchCellFrame.origin.x + self.stitchCellFrame.size.width / 2, self.stitchCellFrame.origin.y + self.stitchCellFrame.size.height / 2);
        
        [UIView animateWithDuration:g_transitionDuration delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:6.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            toViewController.view.center = CGPointMake(finalFrame.origin.x + finalFrame.size.width / 2, finalFrame.origin.y + finalFrame.size.height / 2);
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    } else {
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        toViewController.view.frame = finalFrame;
        [UIView animateWithDuration:g_transitionDuration delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:6.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromViewController.view.transform = CGAffineTransformMakeScale(self.stitchCellFrame.size.width / size, self.stitchCellFrame.size.height / size);
            fromViewController.view.center = CGPointMake(self.stitchCellFrame.origin.x + self.stitchCellFrame.size.width / 2, self.stitchCellFrame.origin.y + self.stitchCellFrame.size.height / 2);
        } completion:^(BOOL finished) {
            [fromViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
