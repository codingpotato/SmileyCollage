//
//  CPShopViewControllerTransition.m
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPShopViewControllerTransition.h"

#import "CPShopViewController.h"
#import "CPUtility.h"

@implementation CPShopViewControllerTransition

static const CGFloat g_cornerRadius = 3.0;

static const NSInteger g_snapshotViewTag = 100;
static const NSInteger g_maskViewTag = 200;

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    NSAssert([toViewController isMemberOfClass:[CPShopViewController class]], @"");
    NSArray *glassViews = ((CPShopViewController *)toViewController).glassViews;
    
    // create snapshot view
    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
    snapshotView.frame = finalFrame;
    snapshotView.tag = g_snapshotViewTag;
    [containerView addSubview:snapshotView];
    
    // create mask view
    UIView *maskView = [[UIView alloc] init];
    maskView.alpha = 0.0;
    maskView.backgroundColor = [UIColor blackColor];
    maskView.frame = finalFrame;
    maskView.tag = g_maskViewTag;
    [containerView addSubview:maskView];

    // add toViewController
    toViewController.view.frame = finalFrame;
    [containerView addSubview:toViewController.view];
    [toViewController.view layoutIfNeeded];
    
    // create blured image from fromViewController for all the glass views
    CGRect rectOfGlassViews = CGRectZero;
    for (UIView *glassView in glassViews) {
        if (CGRectEqualToRect(rectOfGlassViews, CGRectZero)) {
            rectOfGlassViews = glassView.frame;
        } else {
            rectOfGlassViews = CGRectUnion(rectOfGlassViews, glassView.frame);
        }
    }
    rectOfGlassViews = [fromViewController.view convertRect:rectOfGlassViews fromView:toViewController.view];
    UIImage *bluredImage = [CPUtility bluredSnapshotForView:fromViewController.view inRect:rectOfGlassViews];
    
    // add glass effect for glass views
    for (UIView *glassView in glassViews) {
        UIView *panelView = [[UIView alloc] init];
        panelView.clipsToBounds = YES;
        panelView.layer.cornerRadius = g_cornerRadius;
        panelView.frame = [toViewController.view convertRect:glassView.bounds fromView:glassView];
        [toViewController.view insertSubview:panelView atIndex:0];
        
        UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:bluredImage];
        bluredImageView.center = [glassView convertPoint:CGPointMake(rectOfGlassViews.origin.x + rectOfGlassViews.size.width / 2, rectOfGlassViews.origin.y + rectOfGlassViews.size.height / 2) fromView:toViewController.view];
        [panelView addSubview:bluredImageView];
    }
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(0.0, rectOfGlassViews.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        maskView.alpha = 0.2;
        toViewController.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    } completion:^(BOOL finished) {
        // remove fromViewController
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    NSAssert([fromViewController isMemberOfClass:[CPShopViewController class]], @"");
    NSArray *glassViews = ((CPShopViewController *)fromViewController).glassViews;
    
    // calculate rect of galss views and remove glass effect for glass views
    CGRect rectOfGlassViews = CGRectZero;
    for (UIView *glassView in glassViews) {
        if (CGRectEqualToRect(rectOfGlassViews, CGRectZero)) {
            rectOfGlassViews = glassView.frame;
        } else {
            rectOfGlassViews = CGRectUnion(rectOfGlassViews, glassView.frame);
        }
    }

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        [containerView viewWithTag:g_maskViewTag].alpha = 0.0;
        fromViewController.view.transform = CGAffineTransformMakeTranslation(0.0, rectOfGlassViews.size.height);
    } completion:^(BOOL finished) {
        // remove snapshot view
        [[containerView viewWithTag:g_snapshotViewTag] removeFromSuperview];
        // remove mask view
        [[containerView viewWithTag:g_maskViewTag] removeFromSuperview];
        // remove fromViewController
        [fromViewController.view removeFromSuperview];
        // add toViewController
        toViewController.view.frame = finalFrame;
        [containerView addSubview:toViewController.view];
        
        [transitionContext completeTransition:YES];
    }];
}

@end
