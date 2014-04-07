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
#import "CPSmileyViewController.h"

#import "CPCollageToEditTransition.h"

@implementation CPTransitionManager

#pragma mark - UINavigationControllerDelegate implement

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([fromVC isMemberOfClass:[CPCollageViewController class]] && [toVC isMemberOfClass:[CPEditViewController class]]) {
        return [[CPCollageToEditTransition alloc] initWithShowEditViewController:YES];
    } else if ([fromVC isMemberOfClass:[CPEditViewController class]] && [toVC isMemberOfClass:[CPCollageViewController class]]) {
        return [[CPCollageToEditTransition alloc] initWithShowEditViewController:NO];
    } else {
        return nil;
    }
}

@end
