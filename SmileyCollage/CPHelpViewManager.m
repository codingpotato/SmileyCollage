//
//  CPHelpViewManager.m
//  SmileyCollage
//
//  Created by wangyw on 4/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPHelpViewManager.h"

#import "CPSettings.h"
#import "CPTouchableView.h"
#import "CPUtility.h"

@interface CPHelpViewManager () <CPTouchableViewDelegate>

@property (strong, nonatomic) UIView *helpView;

@property (strong, nonatomic) CPTouchableView *maskView;

@property (strong, nonatomic) UIView *panelView;

@property (nonatomic) BOOL helpShown;

@end

@implementation CPHelpViewManager

static const NSTimeInterval g_minDelayTimeInterval = 5.0;
static const NSTimeInterval g_maxDelayTimeInterval = 10.0;
static const NSTimeInterval g_helpShownTimeInterval = 10.0;
static const NSTimeInterval g_animationDuration = 0.5;

- (void)showSmileyHelpInView:(UIView *)view rect:(CGRect)rect {
    if (![CPSettings isSmileyTapHelpAcknowledged]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (arc4random_uniform(g_maxDelayTimeInterval - g_minDelayTimeInterval) + g_minDelayTimeInterval) * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [self showHelpViewInView:view];
                [self showHelpMessage:@"Tap to select smiley" inView:view rect:rect];
                [self performSelector:@selector(removeHelpViewWithAnimation) withObject:nil afterDelay:g_helpShownTimeInterval];
            });
        });
    }
}

- (void)showCollageHelpInView:(UIView *)view rect:(CGRect)rect {
    if (![CPSettings isCollageTapHelpAcknowledged] || ![CPSettings isCollageDragHelpAcknowledged]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (arc4random_uniform(g_maxDelayTimeInterval - g_minDelayTimeInterval) + g_minDelayTimeInterval) * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [self showHelpViewInView:view];
                
                NSString *helpMessage = nil;
                if (![CPSettings isCollageTapHelpAcknowledged]) {
                    helpMessage = @"Tap to edit photo";
                }
                if (![CPSettings isCollageDragHelpAcknowledged]) {
                    NSString *dragHelpMessage = @"Drag to exchange position";
                    helpMessage = helpMessage ? [[helpMessage stringByAppendingString:@"\n"] stringByAppendingString:dragHelpMessage] : dragHelpMessage;
                }
                [self showHelpMessage:helpMessage inView:view rect:rect];
                
                [self performSelector:@selector(removeHelpViewWithAnimation) withObject:nil afterDelay:g_helpShownTimeInterval];
            });
        });
    }
}

- (void)showEditHelpInView:(UIView *)view rect:(CGRect)rect {
    if (![CPSettings isEditDragHelpAcknowledged] || ![CPSettings isEditZoomHelpAcknowledged]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (arc4random_uniform(g_maxDelayTimeInterval - g_minDelayTimeInterval) + g_minDelayTimeInterval) * NSEC_PER_SEC);
            dispatch_after(time, dispatch_get_main_queue(), ^{
                [self showHelpViewInView:view];
                
                NSString *helpMessage = nil;
                if (![CPSettings isEditDragHelpAcknowledged]) {
                    helpMessage = @"Drag to move photo";
                }
                if (![CPSettings isEditZoomHelpAcknowledged]) {
                    NSString *dragHelpMessage = @"Pinch to zoom in/out";
                    helpMessage = helpMessage ? [[helpMessage stringByAppendingString:@"\n"] stringByAppendingString:dragHelpMessage] : dragHelpMessage;
                }
                [self showHelpMessage:helpMessage inView:view rect:rect];
                
                [self performSelector:@selector(removeHelpViewWithAnimation) withObject:nil afterDelay:g_helpShownTimeInterval];
            });
        });
    }
}

- (void)removeHelpView {
    if (self.helpShown) {
        self.helpShown = NO;
        [self.helpView removeFromSuperview];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)dealloc {
    [self removeHelpView];
}

- (void)showHelpViewInView:(UIView *)view {
    NSAssert(!self.helpView, @"");
    NSAssert(!self.maskView, @"");
    
    self.helpShown = YES;
    
    self.helpView = [[UIView alloc] init];
    self.helpView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:self.helpView];
    [view addConstraints:[CPUtility constraintsWithView:self.helpView edgesAlignToView:view]];
    
    self.maskView = [[CPTouchableView alloc] init];
    self.maskView.alpha = 0.0;
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.delegate = self;
    self.maskView.frame = self.helpView.bounds;
    self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.helpView addSubview:self.maskView];
    [self.helpView addConstraints:[CPUtility constraintsWithView:self.maskView edgesAlignToView:self.helpView]];
    
    [UIView animateWithDuration:g_animationDuration animations:^{
        self.maskView.alpha = 0.2;
    }];
}

- (void)showHelpMessage:(NSString *)helpMessage inView:(UIView *)view rect:(CGRect)rect {
    NSAssert(!self.panelView, @"");
    
    self.panelView = [[UIView alloc] init];
    self.panelView.backgroundColor = [UIColor whiteColor];
    self.panelView.clipsToBounds = YES;
    self.panelView.layer.cornerRadius = 3.0;
    [self.helpView addSubview:self.panelView];
    
    UIView *maskView = [[UIView alloc] init];
    maskView.alpha = 0.4;
    maskView.backgroundColor = [UIColor whiteColor];
    [self.panelView addSubview:maskView];
    
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:18.0];
    label.numberOfLines = 0;
    label.text = helpMessage;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor darkGrayColor];
    [label sizeToFit];
    [self.panelView addSubview:label];
    
    static const CGFloat inset = 8.0;
    CGFloat left = rect.origin.x + arc4random_uniform(rect.size.width);
    CGFloat top = rect.origin.y + arc4random_uniform(rect.size.height);
    CGFloat width = label.bounds.size.width + inset * 2;
    CGFloat height = label.bounds.size.height + inset * 2;
    
    if (left < inset) {
        left = inset;
    }
    if (top < inset) {
        top = inset;
    }
    if (left + width > view.bounds.origin.x + view.bounds.size.width - inset) {
        left = view.bounds.origin.x + view.bounds.size.width - width - inset;
    }
    if (top + height > view.bounds.origin.y + view.bounds.size.height - inset) {
        top = view.bounds.origin.y + view.bounds.size.height - height - inset;
    }
    
    self.panelView.frame = CGRectMake(left, top, width, height);
    maskView.frame = self.panelView.bounds;
    label.frame = self.panelView.bounds;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[CPUtility bluredSnapshotForView:view inRect:self.panelView.frame]];
    imageView.frame = self.panelView.bounds;
    [self.panelView insertSubview:imageView belowSubview:maskView];
    
    self.panelView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    [UIView animateWithDuration:g_animationDuration delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.panelView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:nil];
}

- (void)removeHelpViewWithAnimation {
    if (self.helpShown) {
        self.helpShown = NO;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [UIView animateWithDuration:g_animationDuration animations:^{
            self.maskView.alpha = 0.0;
            self.panelView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        } completion:^(BOOL finished) {
            [self.helpView removeFromSuperview];
            self.helpView = nil;
            self.maskView = nil;
            self.panelView = nil;
        }];
    }
}

#pragma maek - CPTouchableViewDelegate implement

- (void)viewIsTouched:(CPTouchableView *)view {
    [self removeHelpViewWithAnimation];
}

@end
