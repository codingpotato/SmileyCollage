//
//  CPReversableTransition.m
//  SmileyCollage
//
//  Created by wangyw on 4/8/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPReversableTransition.h"

@interface CPReversableTransition ()

@property (nonatomic) BOOL reverse;

@end

@implementation CPReversableTransition

- (id)initWithReverse:(BOOL)reverse {
    self = [super init];
    if (self) {
        self.reverse = reverse;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.reverse) {
        [self animateReverseTransition:transitionContext];
    } else {
        [self animateForwardTransition:transitionContext];
    }
}

- (void)animateForwardTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(NO, @"");
}

- (void)animateReverseTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(NO, @"");
}

@end
