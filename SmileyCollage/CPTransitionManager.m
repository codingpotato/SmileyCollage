//
//  CPTransitionManager.m
//  Smiley
//
//  Created by wangyw on 3/9/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPTransitionManager.h"

#import "CPCollageViewController.h"
#import "CPEditViewController.h"
#import "CPShopViewController.h"
#import "CPSmileyViewController.h"

#import "CPCollageToEditTransition.h"
#import "CPPortalTransition.h"
#import "CPShopViewControllerTransition.h"

@implementation CPTransitionManager

#pragma mark - UINavigationControllerDelegate implement

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([fromVC isMemberOfClass:[CPSmileyViewController class]] && [toVC isMemberOfClass:[CPCollageViewController class]]) {
        return [[CPPortalTransition alloc] initWithReverse:NO];
    } else if ([fromVC isMemberOfClass:[CPCollageViewController class]] && [toVC isMemberOfClass:[CPSmileyViewController class]]) {
        return [[CPPortalTransition alloc] initWithReverse:YES];
    } else if ([fromVC isMemberOfClass:[CPCollageViewController class]] && [toVC isMemberOfClass:[CPEditViewController class]]) {
        return [[CPCollageToEditTransition alloc] initWithReverse:NO];
    } else if ([fromVC isMemberOfClass:[CPEditViewController class]] && [toVC isMemberOfClass:[CPCollageViewController class]]) {
        return [[CPCollageToEditTransition alloc] initWithReverse:YES];
    } else if ([fromVC isMemberOfClass:[CPCollageViewController class]] && [toVC isMemberOfClass:[CPShopViewController class]]) {
        return [[CPShopViewControllerTransition alloc] initWithReverse:NO];
    } else if ([fromVC isMemberOfClass:[CPShopViewController class]] && [toVC isMemberOfClass:[CPCollageViewController class]]) {
        return [[CPShopViewControllerTransition alloc] initWithReverse:YES];
    } else {
        return nil;
    }
}

@end
