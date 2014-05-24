//
//  CPEditViewControllerTransition.m
//  Smiley
//
//  Created by wangyw on 3/9/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPEditViewControllerTransition.h"

#import "CPCollageCell.h"
#import "CPCollageViewController.h"
#import "CPEditViewController.h"

@implementation CPEditViewControllerTransition

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CPCollageViewController *collageViewController = (CPCollageViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CPEditViewController *editViewController = (CPEditViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert(collageViewController && editViewController, @"");
    
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:editViewController];

    // add edit view
    [containerView addSubview:editViewController.view];
    editViewController.view.frame = finalFrame;
    editViewController.view.alpha = 0.0;
    
    // create snapshot for selected face
    UIView *selectedFace = collageViewController.selectedFace;
    UIView *snapshot = [selectedFace snapshotViewAfterScreenUpdates:NO];
    [containerView addSubview:snapshot];
    snapshot.frame = [containerView convertRect:selectedFace.bounds fromView:selectedFace];
    
    // hide selected face
    selectedFace.hidden = YES;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        snapshot.frame = [containerView convertRect:editViewController.faceIndicatorFrame fromView:editViewController.view];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            editViewController.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            [snapshot removeFromSuperview];
            selectedFace.hidden = NO;
            [collageViewController.view removeFromSuperview];
            [transitionContext completeTransition:YES];
        }];
    }];
}

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CPEditViewController *editViewController = (CPEditViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CPCollageViewController *collageViewController = (CPCollageViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert(editViewController && collageViewController, @"");
    
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:collageViewController];
    
    // add collage view
    [containerView addSubview:collageViewController.view];
    collageViewController.view.frame = finalFrame;
    
    // reload selected face
    [collageViewController reloadSelectedFace];
    UIView *selectedFace = collageViewController.selectedFace;
    
    // hide selected face
    selectedFace.hidden = YES;
    
    // create snapshot for selected face
    UIView *snapshot = editViewController.faceSnapshot;
    [containerView addSubview:snapshot];
    snapshot.frame = [containerView convertRect:editViewController.faceIndicatorFrame fromView:editViewController.view];
    
    [editViewController.view removeFromSuperview];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        snapshot.frame = [containerView convertRect:selectedFace.bounds fromView:selectedFace];
    } completion:^(BOOL finished) {
        [snapshot removeFromSuperview];
        selectedFace.hidden = NO;
        [transitionContext completeTransition:YES];
    }];
}

@end
