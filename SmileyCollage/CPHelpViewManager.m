//
//  CPHelpViewManager.m
//  SmileyCollage
//
//  Created by wangyw on 4/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPHelpViewManager.h"

#import "CPSettings.h"
#import "CPUtility.h"

@interface CPHelpViewManager ()

@property (strong, nonatomic) NSMutableArray *helpViews;

@property (strong, nonatomic) UIView *smileyNotFoundHelpView;

@end

@implementation CPHelpViewManager

static const NSUInteger g_maxHelpViews = 2;

static const NSTimeInterval g_delayTimeInterval = 5.0;
static const NSTimeInterval g_animationDuration = 0.3;

- (void)showSmileyNotFoundHelpWithDelayInView:(UIView *)view {
    if (!self.smileyNotFoundHelpView) {
        self.smileyNotFoundHelpView = [[UIView alloc] init];
        self.smileyNotFoundHelpView.backgroundColor = [UIColor yellowColor];
        self.smileyNotFoundHelpView.layer.cornerRadius = 2.0;
        self.smileyNotFoundHelpView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.smileyNotFoundHelpView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        self.smileyNotFoundHelpView.layer.shadowOpacity = 0.8;
        self.smileyNotFoundHelpView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"Take photos with smiley faces everyday.\n\nCollage them with Smiley Collage";
        [label sizeToFit];
        [self.smileyNotFoundHelpView addSubview:label];
        
        static const CGFloat labelInset = 5.0;
        [self.smileyNotFoundHelpView addConstraints:@[[CPUtility constraintWithView:label alignToView:self.smileyNotFoundHelpView attribute:NSLayoutAttributeLeft constant:labelInset], [CPUtility constraintWithView:label alignToView:self.smileyNotFoundHelpView attribute:NSLayoutAttributeTop constant:labelInset], [CPUtility constraintWithView:label alignToView:self.smileyNotFoundHelpView attribute:NSLayoutAttributeRight constant:-labelInset], [CPUtility constraintWithView:label alignToView:self.smileyNotFoundHelpView attribute:NSLayoutAttributeBottom constant:-labelInset]]];
        
        [view addSubview:self.smileyNotFoundHelpView];
        [view addConstraints:[CPUtility constraintsWithView:self.smileyNotFoundHelpView centerAlignToView:view]];
    }
}

- (void)removeSmileyNotFoundHelp {
    if (self.smileyNotFoundHelpView) {
        [self.smileyNotFoundHelpView removeFromSuperview];
        self.smileyNotFoundHelpView = nil;
    }
}

- (void)showSmileyHelpWithDelayInView:(UIView *)view {
    if (![CPSettings isSmileyTapAcknowledged]) {
        [self performSelector:@selector(showSmileyHelpInView:) withObject:view afterDelay:g_delayTimeInterval];
    }
}

- (void)showCollageHelpWithDelayInView:(UIView *)view {
    if (![CPSettings isCollageTapAcknowledged] || ![CPSettings isCollageDragAcknowledged]) {
        [self performSelector:@selector(showCollageHelpInView:) withObject:view afterDelay:g_delayTimeInterval];
    }
}

- (void)showEditHelpWithDelayInView:(UIView *)view {
    if (![CPSettings isEditDragAcknowledged] || ![CPSettings isEditZoomHelpAcknowledged]) {
        [self performSelector:@selector(showEditHelpInView:) withObject:view afterDelay:g_delayTimeInterval];
    }
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self removeSmileyNotFoundHelp];
    for (UIView *helpView in self.helpViews) {
        [helpView removeFromSuperview];
    }
}

- (void)showSmileyHelpInView:(UIView *)view {
    if (![CPSettings isSmileyTapAcknowledged]) {
        [self showHelp:@"Tap to select smiley" inView:view];
    }
    [self performSelector:@selector(removeHelpViewsWithAnimation) withObject:nil afterDelay:g_delayTimeInterval];
}


- (void)showCollageHelpInView:(UIView *)view {
    if (![CPSettings isCollageTapAcknowledged]) {
        [self showHelp:@"Tap to edit photo" inView:view];
    }
    if (![CPSettings isCollageDragAcknowledged]) {
        [self showHelp:@"Drag to exchange position" inView:view];
    }
    [self performSelector:@selector(removeHelpViewsWithAnimation) withObject:nil afterDelay:g_delayTimeInterval];
}

- (void)showEditHelpInView:(UIView *)view {
    if (![CPSettings isEditDragAcknowledged]) {
        [self showHelp:@"Drag to move photo" inView:view];
    }
    if (![CPSettings isEditZoomHelpAcknowledged]) {
        [self showHelp:@"Pinch to zoom in / out" inView:view];
    }
    [self performSelector:@selector(removeHelpViewsWithAnimation) withObject:nil afterDelay:g_delayTimeInterval];
}

- (void)showHelp:(NSString *)helpMessage inView:(UIView *)view {
    UIView *helpView = [[UIView alloc] init];
    helpView.backgroundColor = [UIColor yellowColor];
    helpView.layer.cornerRadius = 2.0;
    helpView.layer.shadowColor = [UIColor blackColor].CGColor;
    helpView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    helpView.layer.shadowOpacity = 0.8;
    helpView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = helpMessage;
    [label sizeToFit];
    [helpView addSubview:label];
    
    static const CGFloat labelInset = 5.0;
    [helpView addConstraints:@[[CPUtility constraintWithView:label alignToView:helpView attribute:NSLayoutAttributeLeft constant:labelInset], [CPUtility constraintWithView:label alignToView:helpView attribute:NSLayoutAttributeTop constant:labelInset], [CPUtility constraintWithView:label alignToView:helpView attribute:NSLayoutAttributeRight constant:-labelInset], [CPUtility constraintWithView:label alignToView:helpView attribute:NSLayoutAttributeBottom constant:-labelInset]]];
    
    [view addSubview:helpView];
    static const CGFloat helpViewInset = 10.0;
    [view addConstraint:[CPUtility constraintWithView:helpView attribute:NSLayoutAttributeCenterX alignToView:view attribute:NSLayoutAttributeRight constant:-(label.bounds.size.width / 2 + labelInset + helpViewInset)]];
    if (self.helpViews.count > 0) {
        [view addConstraint:[CPUtility constraintWithView:helpView attribute:NSLayoutAttributeTop alignToView:self.helpViews.lastObject attribute:NSLayoutAttributeBottom constant:helpViewInset]];
    } else {
        [view addConstraint:[CPUtility constraintWithView:helpView alignToView:view attribute:NSLayoutAttributeCenterY]];
    }
    [self.helpViews addObject:helpView];

    helpView.transform = CGAffineTransformMakeScale(0.0, 1.0);
    [UIView animateWithDuration:g_animationDuration animations:^{
        helpView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (void)removeHelpViewsWithAnimation {
    for (UIView *helpView in self.helpViews) {
        [UIView animateWithDuration:g_animationDuration animations:^{
            helpView.transform = CGAffineTransformMakeScale(0.0, 1.0);
        } completion:^(BOOL finished) {
            [helpView removeFromSuperview];
        }];
    }
    self.helpViews = nil;
}

#pragma mark - lazy init

- (NSMutableArray *)helpViews {
    if (!_helpViews) {
        _helpViews = [[NSMutableArray alloc] initWithCapacity:g_maxHelpViews];
    }
    return _helpViews;
}

@end
