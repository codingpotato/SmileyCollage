//
//  CPTransitionManager.m
//  Smiley
//
//  Created by wangyw on 3/9/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPTransitionManager.h"

#import "CPStitchEditTransition.h"
#import "CPEditViewController.h"
#import "CPStitchViewController.h"

@interface CPTransitionManager ()

@property (strong, nonatomic) CPStitchEditTransition *stitchEditTransition;

@end

@implementation CPTransitionManager

#pragma mark - UINavigationControllerDelegate implement

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([fromVC isMemberOfClass:[CPStitchViewController class]] && [toVC isMemberOfClass:[CPEditViewController class]]) {
        return self.stitchEditTransition;
    } else {
        return nil;
    }
}

#pragma mark - lazy init

- (CPStitchEditTransition *)stitchEditTransition {
    if (!_stitchEditTransition) {
        _stitchEditTransition = [[CPStitchEditTransition alloc] init];
    }
    return _stitchEditTransition;
}

@end
