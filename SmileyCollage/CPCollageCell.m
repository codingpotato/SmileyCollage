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

- (void)initCell {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.activityIndicatorView];
    [self.contentView addConstraints:[CPUtility constraintsWithView:self.activityIndicatorView centerAlignToView:self.contentView]];
    [self.activityIndicatorView startAnimating];
}

- (void)showImage:(UIImage *)image animated:(BOOL)animated {
    if (self.activityIndicatorView) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        self.activityIndicatorView = nil;
    }
    
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        self.imageViewWidthConstraint = [CPUtility constraintWithView:self.imageView alignToView:self.contentView attribute:NSLayoutAttributeWidth];
        self.imageViewHeightConstraint = [CPUtility constraintWithView:self.imageView alignToView:self.contentView attribute:NSLayoutAttributeHeight];
        [self.contentView addConstraints:@[[CPUtility constraintWithView:self.imageView alignToView:self.contentView attribute:NSLayoutAttributeCenterX], [CPUtility constraintWithView:self.imageView alignToView:self.contentView attribute:NSLayoutAttributeCenterY], self.imageViewWidthConstraint, self.imageViewHeightConstraint]];
    }
    
    self.imageView.image = image;
    if (animated) {
        self.imageViewWidthConstraint.constant = -self.contentView.bounds.size.width;
        self.imageViewHeightConstraint.constant = -self.contentView.bounds.size.height;
        [self.contentView layoutIfNeeded];
        self.imageViewWidthConstraint.constant = 0.0;
        self.imageViewHeightConstraint.constant = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            [self.contentView layoutIfNeeded];
        }];
    }
}

@end
