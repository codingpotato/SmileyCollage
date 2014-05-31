//
//  CPCollageCell.m
//  Smiley
//
//  Created by wangyw on 3/22/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCollageCell.h"

#import "CPUtility.h"

@interface CPCollageCell ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSLayoutConstraint *imageViewWidthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewHeightConstraint;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CPCollageCell

- (void)showActivityIndicatorView {
    [self removeActivityIndicatorView];
    [self removeImageView];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.activityIndicatorView];
    [self.contentView addConstraints:[CPUtility constraintsWithView:self.activityIndicatorView centerAlignToView:self.contentView]];
    [self.activityIndicatorView startAnimating];
}

- (void)showImage:(UIImage *)image animated:(BOOL)animated {
    [self removeActivityIndicatorView];
    
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        self.imageViewWidthConstraint = [CPUtility constraintWithView:self.imageView alignToView:self.contentView attribute:NSLayoutAttributeWidth];
        self.imageViewHeightConstraint = [CPUtility constraintWithView:self.imageView alignToView:self.contentView attribute:NSLayoutAttributeHeight];
        [self.contentView addConstraints:@[self.imageViewWidthConstraint, self.imageViewHeightConstraint]];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.imageView centerAlignToView:self.contentView]];
    }
    
    self.imageView.image = image;
    if (animated) {
        self.imageViewWidthConstraint.constant = -self.contentView.bounds.size.width + 1;
        self.imageViewHeightConstraint.constant = -self.contentView.bounds.size.height + 1;
        [self.contentView layoutIfNeeded];
        self.imageViewWidthConstraint.constant = 0.0;
        self.imageViewHeightConstraint.constant = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            [self.contentView layoutIfNeeded];
        }];
    }
}

- (void)removeActivityIndicatorView {
    if (self.activityIndicatorView) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
}

- (void)removeImageView {
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
}

@end
