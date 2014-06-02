//
//  CPHelpViewManager.m
//  SmileyCollage
//
//  Created by wangyw on 4/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPHelpViewManager.h"

#import "CPConfig.h"
#import "CPSettings.h"
#import "CPTouchableView.h"
#import "CPUtility.h"

@interface CPHelpViewManager () <CPTouchableViewDelegate>

@property (weak, nonatomic) UIView *superview;

@property (strong, nonatomic) UIView *helpView;

@property (strong, nonatomic) CPTouchableView *maskView;

@property (strong, nonatomic) UIView *panelView;

@end

@implementation CPHelpViewManager

static const NSTimeInterval g_delayTimeInterval = 5.0;
static const NSTimeInterval g_animationDuration = 0.5;

- (void)showSmileyHelpInSuperview:(UIView *)superview {
    if (![CPSettings isSmileyTapHelpAcknowledged]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, g_delayTimeInterval * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                self.superview = superview;
                [self showHelpMessage:CPLocalizedString(@"CPTapSmileyHelp")];
            });
        });
    }
}

- (void)showCollageHelpInSuperview:(UIView *)superview {
    if (![CPSettings isCollageTapHelpAcknowledged] || ![CPSettings isCollageDragHelpAcknowledged]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, g_delayTimeInterval * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                self.superview = superview;
                NSString *helpMessage = nil;
                if (![CPSettings isCollageTapHelpAcknowledged]) {
                    helpMessage = CPLocalizedString(@"CPTapCollageHelp");
                }
                if (![CPSettings isCollageDragHelpAcknowledged]) {
                    NSString *dragHelpMessage = CPLocalizedString(@"CPDragCollageHelp");
                    helpMessage = helpMessage ? [[helpMessage stringByAppendingString:@"\n"] stringByAppendingString:dragHelpMessage] : dragHelpMessage;
                }
                [self showHelpMessage:helpMessage];
            });
        });
    }
}

- (void)showEditHelpInSuperview:(UIView *)superview {
    if (![CPSettings isEditDragHelpAcknowledged] || ![CPSettings isEditZoomHelpAcknowledged]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, g_delayTimeInterval * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                self.superview = superview;
                NSString *helpMessage = nil;
                if (![CPSettings isEditDragHelpAcknowledged]) {
                    helpMessage = CPLocalizedString(@"CPDragEditHelp");
                }
                if (![CPSettings isEditZoomHelpAcknowledged]) {
                    NSString *dragHelpMessage = CPLocalizedString(@"CPPinchEditHelp");
                    helpMessage = helpMessage ? [[helpMessage stringByAppendingString:@"\n"] stringByAppendingString:dragHelpMessage] : dragHelpMessage;
                }
                [self showHelpMessage:helpMessage];
            });
        });
    }
}

- (void)removeHelpView {
    if (self.helpView) {
        [self.helpView removeFromSuperview];
        self.helpView = nil;
        self.maskView = nil;
        self.panelView = nil;
    }
}

- (void)dealloc {
    [self removeHelpView];
}

- (void)showHelpMessage:(NSString *)helpMessage {
    NSAssert(!self.helpView && !self.maskView && !self.panelView, @"");
    
    self.helpView = [[UIView alloc] init];
    self.helpView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.superview addSubview:self.helpView];
    [self.superview addConstraints:[CPUtility constraintsWithView:self.helpView edgesAlignToView:self.superview]];
    
    self.maskView = [[CPTouchableView alloc] init];
    self.maskView.alpha = 0.0;
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.delegate = self;
    self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.helpView addSubview:self.maskView];
    [self.helpView addConstraints:[CPUtility constraintsWithView:self.maskView edgesAlignToView:self.helpView]];
    
    self.panelView = [[UIView alloc] init];
    self.panelView.clipsToBounds = YES;
    self.panelView.layer.cornerRadius = 5.0;
    self.panelView.translatesAutoresizingMaskIntoConstraints = NO;
    self.panelView.userInteractionEnabled = NO;
    [self.helpView addSubview:self.panelView];
    
    UIView *panelMaskView = [[UIView alloc] init];
    panelMaskView.alpha = 0.93;
    panelMaskView.backgroundColor = [UIColor whiteColor];
    panelMaskView.translatesAutoresizingMaskIntoConstraints = NO;
    panelMaskView.userInteractionEnabled = NO;
    [self.panelView addSubview:panelMaskView];
    [self.panelView addConstraints:[CPUtility constraintsWithView:panelMaskView edgesAlignToView:self.panelView]];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:[CPConfig helpFontName] size:[CPConfig helpFontSize]];
    label.numberOfLines = 0;
    label.text = helpMessage;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.userInteractionEnabled = NO;
    [label sizeToFit];
    [self.panelView addSubview:label];
    [self.panelView addConstraints:[CPUtility constraintsWithView:label edgesAlignToView:self.panelView]];
    
    static const CGFloat inset = 8.0;
    CGFloat width = label.bounds.size.width + inset * 2;
    CGFloat height = label.bounds.size.height + inset * 2;
    [self.panelView addConstraint:[CPUtility constraintWithView:self.panelView width:width]];
    [self.panelView addConstraint:[CPUtility constraintWithView:self.panelView height:height]];
    CGFloat size = (MIN(self.superview.bounds.size.width, self.superview.bounds.size.height) - MAX(width, height)) / 2;
    [self.helpView addConstraint:[CPUtility constraintWithView:self.panelView alignToView:self.helpView attribute:NSLayoutAttributeCenterX constant:-size + arc4random_uniform(size * 2)]];
    [self.helpView addConstraint:[CPUtility constraintWithView:self.panelView alignToView:self.helpView attribute:NSLayoutAttributeCenterY constant:-size + arc4random_uniform(size * 2)]];
    
    [UIView animateWithDuration:g_animationDuration animations:^{
        self.maskView.alpha = 0.2;
    }];
    
    self.panelView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [UIView animateWithDuration:g_animationDuration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.panelView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
}

#pragma maek - CPTouchableViewDelegate implement

- (void)viewIsTouched:(CPTouchableView *)view {
    [UIView animateWithDuration:g_animationDuration animations:^{
        self.maskView.alpha = 0.0;
        self.panelView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    } completion:^(BOOL finished) {
        [self removeHelpView];
    }];
}

@end
