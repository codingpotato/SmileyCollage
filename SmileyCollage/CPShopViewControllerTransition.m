//
//  CPTransparentTransition.m
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

static const NSInteger g_snapshotViewTag = 1;
static const NSInteger g_maskViewTag = 2;
static const NSInteger g_maskOfTableViewTag = 3;
static const NSInteger g_maskOfRestoreButtonTag = 4;
static const NSInteger g_maskOfCancelButtonTag = 5;

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CPShopViewController *shopViewController = (CPShopViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:shopViewController];
    
    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:NO];
    snapshotView.frame = finalFrame;
    snapshotView.tag = g_snapshotViewTag;
    [containerView addSubview:snapshotView];
    
    UIView *maskView = [[UIView alloc] init];
    maskView.alpha = 0.0;
    maskView.backgroundColor = [UIColor blackColor];
    maskView.frame = finalFrame;
    maskView.tag = g_maskViewTag;
    [containerView addSubview:maskView];
     
    UIImage *bluredImage = [CPUtility bluredSnapshotForView:fromViewController.view inRect:shopViewController.panelView.frame];
    [fromViewController.view removeFromSuperview];
    
    shopViewController.view.frame = finalFrame;
    [containerView addSubview:shopViewController.view];
    
    shopViewController.view.transform = CGAffineTransformMakeTranslation(0.0, shopViewController.panelView.bounds.size.height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        maskView.alpha = 0.2;
        shopViewController.view.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    } completion:^(BOOL finished) {
        {
            UIView *maskOfTableView = [[UIView alloc] init];
            maskOfTableView.clipsToBounds = YES;
            maskOfTableView.layer.cornerRadius = g_cornerRadius;
            maskOfTableView.frame = [containerView convertRect:shopViewController.maskOfTableView.bounds fromView:shopViewController.maskOfTableView];
            maskOfTableView.tag = g_maskOfTableViewTag;
            [containerView insertSubview:maskOfTableView aboveSubview:snapshotView];
            
            UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:bluredImage];
            bluredImageView.center = [shopViewController.maskOfTableView convertPoint:shopViewController.panelView.center fromView:shopViewController.view];
            [maskOfTableView addSubview:bluredImageView];
        }
        
        {
            UIView *maskOfRestoreButton = [[UIView alloc] init];
            maskOfRestoreButton.clipsToBounds = YES;
            maskOfRestoreButton.layer.cornerRadius = g_cornerRadius;
            maskOfRestoreButton.frame = [containerView convertRect:shopViewController.maskOfRestoreButton.bounds fromView:shopViewController.maskOfRestoreButton];
            maskOfRestoreButton.tag = g_maskOfRestoreButtonTag;
            [containerView insertSubview:maskOfRestoreButton aboveSubview:snapshotView];
            
            UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:bluredImage];
            bluredImageView.center = [shopViewController.maskOfRestoreButton convertPoint:shopViewController.panelView.center fromView:shopViewController.view];
            [maskOfRestoreButton addSubview:bluredImageView];
        }
        
        {
            UIView *maskOfCancelButton = [[UIView alloc] init];
            maskOfCancelButton.clipsToBounds = YES;
            maskOfCancelButton.layer.cornerRadius = g_cornerRadius;
            maskOfCancelButton.frame = [containerView convertRect:shopViewController.maskOfCancelButton.bounds fromView:shopViewController.maskOfCancelButton];
            maskOfCancelButton.tag = g_maskOfCancelButtonTag;
            [containerView insertSubview:maskOfCancelButton aboveSubview:snapshotView];
            
            UIImageView *bluredImageView = [[UIImageView alloc] initWithImage:bluredImage];
            bluredImageView.center = [shopViewController.maskOfCancelButton convertPoint:shopViewController.panelView.center fromView:shopViewController.view];
            [maskOfCancelButton addSubview:bluredImageView];
        }
        
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    CPShopViewController *shopViewController = (CPShopViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    CGRect finalFrame  = [transitionContext finalFrameForViewController:toViewController];
    
    [[containerView viewWithTag:g_maskOfTableViewTag] removeFromSuperview];
    [[containerView viewWithTag:g_maskOfRestoreButtonTag] removeFromSuperview];
    [[containerView viewWithTag:g_maskOfCancelButtonTag] removeFromSuperview];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        [containerView viewWithTag:g_maskViewTag].alpha = 0.0;
        shopViewController.view.transform = CGAffineTransformMakeTranslation(0.0, shopViewController.panelView.bounds.size.height);
    } completion:^(BOOL finished) {
        [[containerView viewWithTag:g_snapshotViewTag] removeFromSuperview];
        [[containerView viewWithTag:g_maskViewTag] removeFromSuperview];
        [shopViewController.view removeFromSuperview];
        
        toViewController.view.frame = finalFrame;
        [containerView addSubview:toViewController.view];
        
        [transitionContext completeTransition:YES];
    }];
}

@end
