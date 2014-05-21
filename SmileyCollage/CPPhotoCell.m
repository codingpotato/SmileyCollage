//
//  CPPhotoCell.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotoCell.h"

#import "CPUtility.h"

@interface CPPhotoCell ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIView *maskView;

@property (strong, nonatomic) UIImageView *tickView;

@end

@implementation CPPhotoCell

- (void)showImage:(UIImage *)image {
    if (!self.imageView) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.imageView edgesAlignToView:self.contentView]];
    }
    self.imageView.image = image;
}

- (void)select {
    if (!self.maskView) {
        self.maskView = [[UIView alloc] init];
        self.maskView.backgroundColor = [UIColor whiteColor];
        self.maskView.alpha = 0.2;
        self.maskView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.contentView addSubview:self.maskView];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.maskView edgesAlignToView:self.contentView]];
    }
    
    if (!self.tickView) {
        self.tickView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
        self.tickView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.tickView];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.tickView alignToView:self.contentView attributes:NSLayoutAttributeRight, NSLayoutAttributeBottom, NSLayoutAttributeNotAnAttribute]];
    }
}

- (void)unselect {
    if (self.maskView) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
    }
    if (self.tickView) {
        [self.tickView removeFromSuperview];
        self.tickView = nil;
    }
}

@end
