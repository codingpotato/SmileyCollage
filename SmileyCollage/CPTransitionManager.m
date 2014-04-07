//
//  CPTransitionManager.m
//  Smiley
//
//  Created by wangyw on 3/9/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPTransitionManager.h"

#import "CPEditViewController.h"
#import "CPSmileyViewController.h"
#import "CPCollageViewController.h"

#import "CPStitchEditTransition.h"

@implementation CPTransitionManager

#pragma mark - UINavigationControllerDelegate implement

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    if ([fromVC isMemberOfClass:[CPCollageViewController class]] && [toVC isMemberOfClass:[CPEditViewController class]]) {
        CPCollageViewController *stitchViewController = (CPCollageViewController *)fromVC;
        CPStitchEditTransition *stitchEditTransition = [[CPStitchEditTransition alloc] init];
        stitchEditTransition.fromStitchToEdit = YES;
        stitchEditTransition.stitchCellFrame = stitchViewController.frameOfSelectedCell;
        return stitchEditTransition;
    } else if ([fromVC isMemberOfClass:[CPEditViewController class]] && [toVC isMemberOfClass:[CPCollageViewController class]]) {
        CPCollageViewController *stitchViewController = (CPCollageViewController *)toVC;
        CPStitchEditTransition *stitchEditTransition = [[CPStitchEditTransition alloc] init];
        stitchEditTransition.fromStitchToEdit = NO;
        stitchEditTransition.stitchCellFrame = stitchViewController.frameOfSelectedCell;
        return stitchEditTransition;
    } else {
        return nil;
    }
}

@end
