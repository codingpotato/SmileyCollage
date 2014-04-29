//
//  CPTransparentTransition.m
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPActionSheetTransition.h"

#import "CPActionSheetViewController.h"
#import "CPUtility.h"

@implementation CPActionSheetTransition

static const CGFloat g_cornerRadius = 3.0;

static const NSInteger g_snapshotViewTag = 100;
static const NSInteger g_maskViewTag = 200;
static const NSInteger g_firstGlassViewTag = 300;

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    NSAssert([toViewController conformsToProtocol:@protocol(CPActionSheetViewController)], @"");
    NSArray *glassViews = ((id<CPActionSheetViewController>)toViewController).glassViews;
    
    // create snapshot view
    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
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
    
    // remove fromViewController
    [fromViewController.view removeFromSuperview];
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(0.0, rectOfGlassViews.size.height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        maskView.alpha = 0.2;
        toViewController.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    } completion:^(BOOL finished) {
        // add glass effect for glass views
        NSInteger tag = g_firstGlassViewTag;
        for (UIView *glassView in glassViews) {
            UIView *panelView = [[UIView alloc] init];
            panelView.clipsToBounds = YES;
            panelView.layer.cornerRadius = g_cornerRadius;
            panelView.frame = [containerView convertRect:glassView.bounds fromView:glassView];
            panelView.tag = tag;
            [containerView insertSubview:panelView aboveSubview:snapshotView];
            
            UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:bluredImage];
            bluredImageView.center = [glassView convertPoint:CGPointMake(rectOfGlassViews.origin.x + rectOfGlassViews.size.width / 2, rectOfGlassViews.origin.y + rectOfGlassViews.size.height / 2) fromView:toViewController.view];
            [panelView addSubview:bluredImageView];
            tag++;
        }
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    NSAssert([fromViewController conformsToProtocol:@protocol(CPActionSheetViewController)], @"");
    NSArray *glassViews = ((id<CPActionSheetViewController>)fromViewController).glassViews;
    
    // calculate rect of galss views and remove glass effect for glass views
    CGRect rectOfGlassViews = CGRectZero;
    NSInteger tag = g_firstGlassViewTag;
    for (UIView *glassView in glassViews) {
        if (CGRectEqualToRect(rectOfGlassViews, CGRectZero)) {
            rectOfGlassViews = glassView.frame;
        } else {
            rectOfGlassViews = CGRectUnion(rectOfGlassViews, glassView.frame);
        }
        
        [[containerView viewWithTag:tag] removeFromSuperview];
        tag++;
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