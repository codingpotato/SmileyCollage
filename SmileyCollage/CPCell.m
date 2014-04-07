//
//  CPCell.m
//  Smiley
//
//  Created by wangyw on 3/22/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCell.h"

@interface CPCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CPCell

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    if (!self.imageView.superview) {
        [self.contentView addSubview:self.imageView];
        [self pinFrameOfView:self.imageView];
    }
}

- (void)pinFrameOfView:(UIView *)view {
    [self.contentView addConstraints:@[
                                       [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0],
                                       [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
                                       ]];
}

#pragma mark - lazy init

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}

@end
